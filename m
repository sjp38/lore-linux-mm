Received: by ug-out-1314.google.com with SMTP id c2so195671ugf
        for <linux-mm@kvack.org>; Thu, 27 Jul 2006 04:16:46 -0700 (PDT)
Message-ID: <6e0cfd1d0607270416g1248e93fi123b6ada852ff242@mail.gmail.com>
Date: Thu, 27 Jul 2006 13:16:45 +0200
From: "Martin Schwidefsky" <schwidefsky@googlemail.com>
Subject: Re: [PATCH] mm: inactive-clean list
In-Reply-To: <1153925104.2762.11.camel@taijtu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1153167857.31891.78.camel@lappy> <44C30E33.2090402@redhat.com>
	 <6e0cfd1d0607260400r731489a1tfd9e6c5a197fb0bd@mail.gmail.com>
	 <1153912268.2732.30.camel@taijtu>
	 <6e0cfd1d0607260604w3e8636e4taaea4bc918397b34@mail.gmail.com>
	 <1153925104.2762.11.camel@taijtu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 7/26/06, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> Wouldn't we typically have all free pages > min_free in state U?
> Also wouldn't all R/O mapped pages not also be V, all R/W mapped pages
> and unmapped page-cache pages P like you state in your paper.

Ahh, ok, I misunderstood. You want to keep the state changes for clean
page cache pages, I assumed that you only want to make pages volatile
if the get on the inactive_clean list and leave them stable if they
are on one of the other two lists.

> This patch would just increase the number of V pages with the tail end
> of the guest LRU, which are typically the pages you would want to evict
> (perhaps even add 5th guest state to indicate that these V pages are
> preferable over the others?)

Yes, that would help for architectures that cannot implement the
potential-volatile state.

> But isn't it so that for the gross over-commit scenario you outline the
> host OS will have to swap out S pages eventually?

My point was that you really have to distinguish between host memory
pressure and guest memory pressure.

-- 
blue skies,
  Martin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
