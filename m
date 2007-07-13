Subject: Re: [RFT][PATCH] mm: drop behind
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <46967EE2.8020803@redhat.com>
References: <1184007008.1913.45.camel@twins>
	 <eada2a070707111537p20ab429anebd8b1840f5e5b5f@mail.gmail.com>
	 <1184225086.20032.45.camel@twins>  <46967EE2.8020803@redhat.com>
Content-Type: text/plain
Date: Fri, 13 Jul 2007 10:12:09 +0200
Message-Id: <1184314329.20032.70.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Snook <csnook@redhat.com>
Cc: Tim Pepper <lnxninja@us.ibm.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Fengguang Wu <wfg@mail.ustc.edu.cn>, riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-07-12 at 15:20 -0400, Chris Snook wrote:

> Then do what we do for FADV_SEQUENTIAL.  With that advice, we double the 
> readahead window.  We're already doing readahead, but we do a lot more 
> when we have the advice.  NOREUSE should put much greater pressure on 
> the vm to drop these pages quickly, or perhaps simply eliminate the 
> heuristic evaluation of the access pattern and short-circuit straight to 
> dropping the pages.
> 
> We should be encouraging application writers to actually use things like 
> fadvise when they can tune things more intelligently than kernel 
> heuristics can.

I like this, I'll see what I can do.. :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
