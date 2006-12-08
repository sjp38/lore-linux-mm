From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Fri, 8 Dec 2006 17:21:24 +1100 (EST)
Subject: Re: new procfs memory analysis feature
In-Reply-To: <20061207143611.7a2925e2.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0612081716440.28861@weill.orchestra.cse.unsw.EDU.AU>
References: <45789124.1070207@mvista.com> <20061207143611.7a2925e2.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: David Singleton <dsingleton@mvista.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee.Schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 7 Dec 2006, Andrew Morton wrote:

> I think that's our eighth open-coded pagetable walker.  Apparently they are
> all slightly different.  Perhaps we shouild do something about that one
> day.

At UNSW we have abstracted the page table into its own layer, and
are running an alternate page table (a GPT), under a clean page table
interface (PTI).

The PTI gathers all the open coded iterators togethers into one place,
which would be a good precursor to providing generic iterators for
non performance critical iterations.

We are completing the updating/enhancements to this PTI for the latest 
kernel, to be released just prior to LCA.  This PTI is benchmarking well. 
We also plan to release the experimental guarded page table (GPT) running 
under this PTI.

Paul Davies
Gelato@UNSW
~

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
