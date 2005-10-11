From: Andi Kleen <ak@suse.de>
Subject: Re: Benchmarks to exploit LRU deficiencies
Date: Tue, 11 Oct 2005 02:13:29 +0200
References: <20051010184636.GA15415@logos.cnet>
In-Reply-To: <20051010184636.GA15415@logos.cnet>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200510110213.29937.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: linux-mm@kvack.org, sjiang@lanl.gov, rni@andrew.cmu.edu, a.p.zijlstra@chello.nl, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Monday 10 October 2005 20:46, Marcelo Tosatti wrote:
> Hi,
>
> There are a few experimental implementations of advanced replacement
> algorithms being developed and discussed. Unfortunately, there is lack of
> knowledge on how to properly test them.

I think if you want to really see advantages you should not implement
the advanced algorithms for the page cache, but for the inode/dentry
cache. We seem to have far more problems in this area than with the
standard page cache.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
