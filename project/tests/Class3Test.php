<?php

namespace SKluck\CircleCoverage;

use PHPUnit\Framework\TestCase;

class Class3Test extends TestCase
{
    public function testOne()
    {
        $this->assertSame(1, (new Class3)->one());
    }
}
