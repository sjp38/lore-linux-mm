Message-ID: <024b01c56913$da7987e0$0f01a8c0@max>
From: "Richard Purdie" <rpurdie@rpsys.net>
References: <20050516130048.6f6947c1.akpm@osdl.org> <20050516210655.E634@flint.arm.linux.org.uk> <030401c55a6e$34e67cb0$0f01a8c0@max> <20050516163900.6daedc40.akpm@osdl.org> <20050602220213.D3468@flint.arm.linux.org.uk>
Subject: Re: 2.6.12-rc4-mm2
Date: Sat, 4 Jun 2005 15:43:57 +0100
MIME-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Russell King <rmk@arm.linux.org.uk>, Andrew Morton <akpm@osdl.org>
Cc: Wolfgang Wander <wwc@rentec.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Russell King:
> I'm not sure what happened with this, but there's someone reporting that
> -rc5-mm1 doesn't work.  Unfortunately, there's not a lot to go on:
>
> http://lists.arm.linux.org.uk/pipermail/linux-arm-kernel/2005-May/029188.html
>
> Could be unrelated for all I know.

One more data point. Booting 2.6.12-rc5-mm1 shows:

Linux version 2.6.12-rc5-mm1-3.5.3-snapshot-20050604 (richard@tim) (gcc 
version 3.4.3) #1 Sat Jun 4 15:32:28 BST 2005
CPU: XScale-PXA255 [69052d06] revision 6 (ARMv5TE)
CPU0: D VIVT undefined 5 cache
CPU0: I cache: 32768 bytes, associativity 32, 32 byte lines, 32 sets
CPU0: D cache: 32768 bytes, associativity 32, 32 byte lines, 32 sets
Machine: SHARP Husky
Ignoring unrecognised tag 0x00000000
Memory policy: ECC disabled, Data cache writeback
Memory clock: 99.53MHz (*27)
Run Mode clock: 199.07MHz (*2)
Turbo Mode clock: 398.13MHz (*2.0, active)
Built 1 zonelists
Kernel command line: console=ttyS0,115200n8 console=tty1 noinitrd 
root=/dev/mtdblock2 rootfstype=jffs2
PID hash table entries: 512 (order: 9, 8192 bytes)
Console: colour dummy device 80x30
Dentry cache hash table entries: 16384 (order: 4, 65536 bytes)
Inode-cache hash table entries: 8192 (order: 3, 32768 bytes)
Memory: 64MB = 64MB total
Memory: 62208KB available (2104K code, 410K data, 76K init)
Mount-cache hash table entries: 512
CPU: Testing write buffer coherency: ok

Then stops dead (have to pull the battery to reset).

This will probably be what's referred to in the above email.

Richard 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
