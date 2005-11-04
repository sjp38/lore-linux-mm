From: Rob Landley <rob@landley.net>
Subject: Re: [patch] swapin rlimit
Date: Fri, 4 Nov 2005 09:14:01 -0600
References: <E1EXEfW-0005ON-00@w-gerrit.beaverton.ibm.com> <20051104072628.GA20108@elte.hu> <20051103233628.12ed1eee.akpm@osdl.org>
In-Reply-To: <20051103233628.12ed1eee.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200511040914.02635.rob@landley.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Ingo Molnar <mingo@elte.hu>, pbadari@gmail.com, torvalds@osdl.org, jdike@addtoit.com, nickpiggin@yahoo.com.au, gh@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, haveblue@us.ibm.com, mel@csn.ul.ie, mbligh@mbligh.org, kravetz@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Friday 04 November 2005 01:36, Andrew Morton wrote:
> >  wouldnt the clean solution here be a "swap ulimit"?
>
> Well it's _a_ solution, but it's terribly specific.
>
> How hard is it to read /proc/<pid>/nr_swapped_in_pages and if that's
> non-zero, kill <pid>?

Things like make fork lots of short-lived child processes, and some of those 
can be quite memory intensive.  (The gcc 4.0.2 build causes an outright swap 
storm for me about halfway through, doing genattrtab and then again compiling 
the result).

Is there any way for parents to collect their child process's statistics when 
the children exit?  Or by the time the actual swapper exits, do we not care 
anymore?

Rob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
