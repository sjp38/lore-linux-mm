Received: by ug-out-1314.google.com with SMTP id o2so806398uge
        for <linux-mm@kvack.org>; Wed, 26 Jul 2006 04:00:24 -0700 (PDT)
Message-ID: <6e0cfd1d0607260400r731489a1tfd9e6c5a197fb0bd@mail.gmail.com>
Date: Wed, 26 Jul 2006 13:00:23 +0200
From: "Martin Schwidefsky" <schwidefsky@googlemail.com>
Subject: Re: [PATCH] mm: inactive-clean list
In-Reply-To: <44C30E33.2090402@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1153167857.31891.78.camel@lappy> <44C30E33.2090402@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 7/23/06, Rik van Riel <riel@redhat.com> wrote:
> Peter Zijlstra wrote:
> > This patch implements the inactive_clean list spoken of during the VM summit.
> > The LRU tail pages will be unmapped and ready to free, but not freeed.
> > This gives reclaim an extra chance.
>
> This patch makes it possible to implement Martin Schwidefsky's
> hypervisor-based fast page reclaiming for architectures without
> millicode - ie. Xen, UML and all other non-s390 architectures.

Hmm, I wonder how the inactive clean list helps in regard to the fast
host reclaim
scheme. In particular since the memory pressure that triggers the
reclaim is in the
host, not in the guest. So all pages might be on the active list but
the host still
wants to be able to discard pages.

-- 
blue skies,
  Martin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
