<?php

namespace SKluck\CircleCoverage;

use PHPUnit\Framework\TestCase;

class Class1Test extends TestCase
{
    public function testOne()
    {
        $this->assertSame(1, (new Class1)->one());
    }
    public function testTwo()
    {
        $this->assertSame(2, (new Class1)->two());
    }
}
