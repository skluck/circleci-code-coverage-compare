#!/usr/bin/env php
<?php

if (!isset($argv[1])) {
    fwrite(STDERR, "Please provide the path to your clover XML test coverage.\n");
    exit(1);
}

$cloverFile = $argv[1];

if (!file_exists($cloverFile)) {
    fwrite(STDERR, "Missing coverage file in clover format. Expected: $cloverFile\n");
    exit(1);
}

$xml = new SimpleXMLElement(file_get_contents($cloverFile));

$metrics = $xml->xpath('/coverage/project/metrics');
if (!$metrics) {
    // Output may sometimes not include overall project summary
    $metrics = $xml->xpath('*/package/*/metrics');
}

$conditionals = $coveredConditionals = 0;
$statements   = $coveredStatements = 0;
$methods      = $coveredMethods = 0;

foreach ($metrics as $metric) {
    $conditionals        += (int) $metric['conditionals'];
    $coveredConditionals += (int) $metric['coveredconditionals'];

    $statements        += (int) $metric['statements'];
    $coveredStatements += (int) $metric['coveredstatements'];

    $methods        += (int) $metric['methods'];
    $coveredMethods += (int) $metric['coveredmethods'];
}

// See calculation: https://confluence.atlassian.com/pages/viewpage.action?pageId=79986990

$tCovered = $coveredConditionals + $coveredStatements + $coveredMethods;
$t        = $conditionals + $statements + $methods;

if ($tCovered === 0) {
    $actualCoverage = 0;
} else {
    $actualCoverage = ($tCovered / $t) * 100;
}

echo sprintf('%0.2f', $actualCoverage);
