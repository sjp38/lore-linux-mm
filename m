Date: Fri, 4 Nov 2005 11:21:18 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch] swapin rlimit
Message-ID: <20051104102118.GA26388@elte.hu>
References: <E1EXEfW-0005ON-00@w-gerrit.beaverton.ibm.com> <200511021747.45599.rob@landley.net> <43699573.4070301@yahoo.com.au> <200511030007.34285.rob@landley.net> <20051103163555.GA4174@ccure.user-mode-linux.org> <1131035000.24503.135.camel@localhost.localdomain> <20051103205202.4417acf4.akpm@osdl.org> <20051104072628.GA20108@elte.hu> <1131099267.30726.43.camel@tara.firmix.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1131099267.30726.43.camel@tara.firmix.at>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bernd Petrovitsch <bernd@firmix.at>
Cc: Andrew Morton <akpm@osdl.org>, Badari Pulavarty <pbadari@gmail.com>, Linus Torvalds <torvalds@osdl.org>, jdike@addtoit.com, rob@landley.net, nickpiggin@yahoo.com.au, gh@us.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, haveblue@us.ibm.com, mel@csn.ul.ie, mbligh@mbligh.org, kravetz@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

* Bernd Petrovitsch <bernd@firmix.at> wrote:

> On Fri, 2005-11-04 at 08:26 +0100, Ingo Molnar wrote:
> > * Andrew Morton <akpm@osdl.org> wrote:
> > 
> > > Similarly, that SGI patch which was rejected 6-12 months ago to kill 
> > > off processes once they started swapping.  We thought that it could be 
> > > done from userspace, but we need a way for userspace to detect when a 
> > > task is being swapped on a per-task basis.
> > 
> > wouldnt the clean solution here be a "swap ulimit"?
> 
> Hmm, where is the difference to "mlockall(MCL_CURRENT|MCL_FUTURE);"? 
> OK, mlockall() can only be done by root (processes).

what do you mean? mlockall pins down all pages. swapin ulimit kills the 
task (and thus frees all the RAM it had) when it touches swap for the 
first time. These two solutions almost oppose each other!

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
