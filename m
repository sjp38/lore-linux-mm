Subject: Re: 2.5.70-mm4
From: Paul Larson <plars@linuxtestproject.org>
In-Reply-To: <20030603231827.0e635332.akpm@digeo.com>
References: <20030603231827.0e635332.akpm@digeo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 04 Jun 2003 10:52:19 -0500
Message-Id: <1054741940.8438.175.camel@plars>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2003-06-04 at 01:18, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.70/2.5.70-mm4/
A couple of issues:

Hangs on boot unless I use acpi=off, but I don't believe this is unique
to -mm.  I've seen this on plain 2.5 kernels on and off before with this
8-way and others like it.  AFAIK the acpi issues are ongoing and still
being worked, but please let me know if there's any information I can
gather other than what's already out there that would assist in fixing
these.

I pulled the latest cvs of LTP and started a make on it.  The make
finished but when I tried to do anything I realized that it was
completely hung.  NMI was on but no messages over the serial console. 
I'll turn off preempt and turn on debug eventlog and see if that
provides any other useful information.  Is anyone else seeing this
happen?  I had seen similar hangs in -mm2 and was told that ext3 might
be the cuplrit and to wait for -mm3.  I didn't get a chance to try -mm3.

Thanks,
Paul Larson


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
