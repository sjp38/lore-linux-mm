From: Dave Peterson <dsp@llnl.gov>
Subject: Re: [PATCH 1/2 (repost)] mm: serialize OOM kill operations
Date: Fri, 28 Apr 2006 15:24:19 -0700
References: <200604271308.10080.dsp@llnl.gov> <200604281459.27895.dsp@llnl.gov> <20060428151638.32ca188e.akpm@osdl.org>
In-Reply-To: <20060428151638.32ca188e.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200604281524.19425.dsp@llnl.gov>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@surriel.com, nickpiggin@yahoo.com.au, ak@suse.de, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Friday 28 April 2006 15:16, Andrew Morton wrote:
> Dave Peterson <dsp@llnl.gov> wrote:
> > Yes I am familiar with this sort of problem.  :-)
>
> Andrea has long advocated that the memory allocator shouldn't infinitely
> loop for small __GFP_WAIT allocations.  ie: ultimately we should return
> NULL back to the caller.
>
> Usually this will cause the correct process to exit.  Sometimes it won't.
>
> Did you try it?

Haven't tried it yet.  Sounds like a good idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
