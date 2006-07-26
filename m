Received: by ug-out-1314.google.com with SMTP id o2so848299uge
        for <linux-mm@kvack.org>; Wed, 26 Jul 2006 06:04:06 -0700 (PDT)
Message-ID: <6e0cfd1d0607260604w3e8636e4taaea4bc918397b34@mail.gmail.com>
Date: Wed, 26 Jul 2006 15:04:05 +0200
From: "Martin Schwidefsky" <schwidefsky@googlemail.com>
Subject: Re: [PATCH] mm: inactive-clean list
In-Reply-To: <1153912268.2732.30.camel@taijtu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1153167857.31891.78.camel@lappy> <44C30E33.2090402@redhat.com>
	 <6e0cfd1d0607260400r731489a1tfd9e6c5a197fb0bd@mail.gmail.com>
	 <1153912268.2732.30.camel@taijtu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On 7/26/06, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> > Hmm, I wonder how the inactive clean list helps in regard to the fast
> > host reclaim
> > scheme. In particular since the memory pressure that triggers the
> > reclaim is in the
> > host, not in the guest. So all pages might be on the active list but
> > the host still
> > wants to be able to discard pages.
> >
>
> I think Rik would want to set all the already unmapped pages to volatile
> state in the hypervisor.
>
> These pages can be dropped without loss of information on the guest
> system since they are all already on a backing-store, be it regular
> files or swap.

I guessed that as well. It isn't good enough. Consider a guest with a
large (virtual) memory size and a host with a small physical memory
size. The guest will never put any page on the inactive_clean list
because it does not have memory pressure. vmscan will never run. The
host wants to reclaim memory of the guest, but since the
inactive_clean list is empty it will find only stable pages.

-- 
blue skies,
  Martin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
