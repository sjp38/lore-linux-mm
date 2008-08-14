Message-ID: <48A494B0.3050509@goop.org>
Date: Thu, 14 Aug 2008 13:25:20 -0700
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [rfc][patch] mm: dirty page accounting race fix
References: <20080814094537.GA741@wotan.suse.de>  <Pine.LNX.4.64.0808141210200.4398@blonde.site> <1218716318.10800.209.camel@twins> <Pine.LNX.4.64.0808141328090.11013@blonde.site>
In-Reply-To: <Pine.LNX.4.64.0808141328090.11013@blonde.site>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> I realized that was the intended optimization, what I'd missed is that
> dirty_accountable can only be true there if (vma->vm_flags & VM_WRITE):
> that's checked in vma_wants_writenotify(), which is how dirty_accountable
> gets to be set.
>
> So those lines are okay, panic over, phew.
>   

I got bitten by precisely the same train of thought.  I think that code 
officially Non Obvious (or at least Not Immediately Obvious, which is 
bad in security-sensitive code).

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
