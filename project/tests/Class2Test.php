<?php

namespace SKluck\CircleCoverage;

use PHPUnit\Framework\TestCase;

class Class2Test extends TestCase
{
    public function testOne()
    {
        $this->assertSame(1, (new Class2)->one());
    }

    public function testTwo()
    {
        $this->assertSame(2, (new Class2)->two());
    }

    public function testThree()
    {
        $this->assertSame(3, (new Class2)->three());
    }
}
