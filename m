Subject: [2.6.0-test1-mm1] Compile varnings
From: Christian Axelsson <smiler@lanil.mine.nu>
Content-Type: text/plain
Message-Id: <1058387502.13489.2.camel@sm-wks1.lan.irkk.nu>
Mime-Version: 1.0
Date: 16 Jul 2003 22:31:42 +0200
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here is an i2c related warning:

CC      drivers/i2c/i2c-dev.o
drivers/i2c/i2c-dev.c: In function `show_dev':
drivers/i2c/i2c-dev.c:121: warning: unsigned int format, different type
arg (arg 3)

Note that this one is still here:

  AS      arch/i386/boot/setup.o
arch/i386/boot/setup.S: Assembler messages:
arch/i386/boot/setup.S:165: Warning: value 0x37ffffff truncated to
0x37ffffff

-- 
Christian Axelsson
smiler@lanil.mine.nu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
