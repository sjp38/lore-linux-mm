Subject: Re: [patch 1/5] x86: implement pte_special
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20080529122602.062780000@nick.local0.net>
References: <20080529122050.823438000@nick.local0.net>
	 <20080529122602.062780000@nick.local0.net>
Content-Type: text/plain
Date: Fri, 06 Jun 2008 23:35:40 +0200
Message-Id: <1212788140.19205.76.camel@lappy.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, shaggy@austin.ibm.com, linux-mm@kvack.org, linux-arch@vger.kernel.org, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-05-29 at 22:20 +1000, npiggin@suse.de wrote:
> plain text document attachment (x86-implement-pte_special.patch)
> Implement the pte_special bit for x86. This is required to support lockless
> get_user_pages, because we need to know whether or not we can refcount a
> particular page given only its pte (and no vma).
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> Cc: shaggy@austin.ibm.com
> Cc: linux-mm@kvack.org
> Cc: linux-arch@vger.kernel.org
> Cc: apw@shadowen.org

Full series:

Reviewed-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
