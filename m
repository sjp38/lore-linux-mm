Received: by rv-out-0910.google.com with SMTP id l15so1179161rvb
        for <linux-mm@kvack.org>; Sun, 28 Oct 2007 23:30:35 -0700 (PDT)
Message-ID: <84144f020710282330v5df5df32v1a766e653081a751@mail.gmail.com>
Date: Mon, 29 Oct 2007 08:30:35 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch 09/10] SLUB: Do our own locking via slab_lock and slab_unlock.
In-Reply-To: <Pine.LNX.4.64.0710282001000.28636@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071028033156.022983073@sgi.com>
	 <20071028033300.479692380@sgi.com>
	 <Pine.LNX.4.64.0710281702140.6766@sbz-30.cs.Helsinki.FI>
	 <Pine.LNX.4.64.0710282001000.28636@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matthew Wilcox <matthew@wil.cx>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 10/29/07, Christoph Lameter <clameter@sgi.com> wrote:
> > We don't need preempt_enable for CONFIG_SMP, right?
>
> preempt_enable is needed if preemption is enabled.

Disabled? But yeah, I see that slab_trylock() can leave preemption
disabled if cmpxchg fails. Was confused by the #ifdefs... :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
