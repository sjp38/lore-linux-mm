Date: Wed, 27 Jun 2007 12:52:42 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH/RFC 10/11] Shared Policy: per cpuset shared file policy
 control
Message-Id: <20070627125242.f195b5ce.pj@sgi.com>
In-Reply-To: <1182965584.4948.13.camel@localhost>
References: <20070625195224.21210.89898.sendpatchset@localhost>
	<20070625195335.21210.82618.sendpatchset@localhost>
	<20070625141031.904935b5.pj@sgi.com>
	<1182965584.4948.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com, ak@suse.de, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

> If my patches eventually go in, I'd agree with this.  I was trying to be
> a good doobee and not add code that wasn't needed.

The ifdef's are added code -- added source code.

For a body of code that's as big as the Linux kernel, and changing
at the speed of Andrew's Enter key, I worry more about keeping the
source code as easy to read as possible, than I do about the last
few bytes of kernel text size.

The success of Linux is far more constrained by the limitations of
human neurons than by the limitations of dynamic RAM chips.

> 	[[ ! -f $cpuset/shared_file_policy ]] || echo 1 >$cpuset/...

Sure - you can code that - that 'shared_file_policy' file is your baby,
and you know how best to care for it.

But it leads to others writing code that doesn't have this [[ ! -f
... ]] guard, which code works fine ... for a while.  Works long
enough to get good and buried in three layers of cruft, leading to
a problem costing someone hours or days to unravel, when it finally
hits a machine lacking that file.

I'd sure like to see that ifdef gone.  I wish I had the time now to
go stamp out that other ifdef in kernel/cpuset.c as well.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
