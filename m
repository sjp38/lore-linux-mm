Date: Mon, 03 Feb 2003 16:09:38 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH 2.5.59-mm6] Speed up task exit
Message-ID: <91720000.1044310178@baldur.austin.ibm.com>
In-Reply-To: <20030203134719.0a416c3b.akpm@digeo.com>
References: <64880000.1043786464@baldur.austin.ibm.com>
 <20030203134719.0a416c3b.akpm@digeo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--On Monday, February 03, 2003 13:47:19 -0800 Andrew Morton
<akpm@digeo.com> wrote:

> Sorry David, I just haven't had time to play with this.  I did some quick
> testing on uniprocessor shell-script-intensive loads and saw no
> bottom-line change at all.
> 
> What load did you test with?

I used a simple test program that forks a null child and waits for it to
exit.  It does it multiple times (default 100) and times the aggregate
time, then computes an average.

Like I said, I saw roughly 10% improvement in that test with my patch.

I'm surprised that shell scripts wouldn't show an improvement.  I expected
they'd be more sensitive to exit performance, given how they highlighted
the performance issues with shared page tables.

My original reason for attacking clear_all_pages was because it kept
showing up in my profiling as significant, and a quick examination of it
looked like it had significant overhead that could be eliminated by keeping
a few reference counts.

Dave

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
