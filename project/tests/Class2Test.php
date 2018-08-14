<?php

namespace SKluck\CircleCoverage;

use PHPUnit\Framework\TestCase;

class Class2Test extends TestCase
{
    public function testOne()
    {
        $this->assertSame(1, (new Class2)->one());
    }
}
