Message-ID: <3D77B28F.488933FB@zip.com.au>
Date: Thu, 05 Sep 2002 12:37:51 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: 2.5.33-mm3 dbench hang and 2.5.33 page allocation failures
References: <1031250156.2799.86.camel@spc9.esa.lanl.gov> <1031253714.1990.116.camel@spc9.esa.lanl.gov>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Cole <elenstev@mesatop.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Steven Cole wrote:
> 
> On Thu, 2002-09-05 at 12:22, Steven Cole wrote:
> > On Thu, 2002-09-05 at 12:03, Andrew Morton wrote:
> 
> > > That sounds like a race-leading-to-deadlock.  Feeding the SYSRQ-T
> > > output into ksymoops is about the only way you have of diagnosing that
> > > I'm afraid.
> >
> > I have CONFIG_MAGIC_SYSRQ=y for 2.5.33-mm3, so I'll reboot and try to
> > get some useful information.
> 
> It looks like I'll have to set up a serial console to capture anything
> useful from sysrq-t.  I got 2.5.33-mm1 to hang at dbench 16.  The box
> responds to sysrq commands, but nothing really happens.  I tested
> sysrq-s before I stared dbench, and that worked OK.  But now even with
> sysrq-e and sysrq-i, the system still reports dbench and pdflush with
> sysrq-t.  And sysrq-s doesn't finish.  I managed to save the output of
> sysrq-p by typing that into a file manually.  I'll have to wait until
> the test box recovers from sysrq-b to feed that into ksymoops since I'm
> using by test box as the build box now.

grr.  I run dbench all night, so any insight you can get into this
would be appreciated.  (I've had a few hangs, but they're due
to bust disk drivers, aic7xxx not handling IO errors correctly, etc)

> BTW, the note in Documentation/sysrq.txt about not needing to enable
> /proc/sys/kernel/sysrq anymore appears to be incorrect.  I had to set
> this to 1 as it was set to 0 on boot.

grep your initscripts.  Some distros turn it off by hand.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
