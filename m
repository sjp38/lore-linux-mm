Subject: Re: Unable to boot 2.6.0-test1-mm2 (mm1 is OK) on RH 9.0.93
	(Severn)
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <1058887517.1668.16.camel@spc9.esa.lanl.gov>
References: <1058887517.1668.16.camel@spc9.esa.lanl.gov>
Content-Type: text/plain
Message-Id: <1058981039.1668.107.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Date: 23 Jul 2003 11:23:59 -0600
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2003-07-22 at 09:25, Steven Cole wrote:
> I get this error when trying to boot 2.6.0-test1-mm2 using the new Red
> Hat beta (Severn).  2.6.0-test2-mm2 runs successfully on a couple of
> other test boxes of mine.
> 
> VFS: Cannot open root device "hda1" or unknown-block(0,0)
> Please append a correct "root=" boot option
> Kernel panic: VFS: Unable to mount root fs on unknown-block(0,0)

After reading a recent thread on lkml, I changed the "root=" thusly:

image=/boot/vmlinuz-2.6.0-test1-mm2
        label=2.6.0-test1mm2
        read-only
        append="devfs=nomount hdc=ide-scsi root=/dev/hda1"

to this
        append="devfs=nomount hdc=ide-scsi root=0301"

And now 2.6.0-test1-mm2 boots and runs.

Steven


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
