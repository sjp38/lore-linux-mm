Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E3E896B0082
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 12:48:50 -0400 (EDT)
Received: by vxg38 with SMTP id 38so471545vxg.14
        for <linux-mm@kvack.org>; Thu, 16 Jun 2011 09:48:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1106141614480.10017@router.home>
References: <20110614201031.GA19848@Chamillionaire.breakpoint.cc>
	<alpine.DEB.2.00.1106141614480.10017@router.home>
Date: Thu, 16 Jun 2011 19:48:48 +0300
Message-ID: <BANLkTim-C7=KVde=A-S5WXoHksaSZ0-wTw@mail.gmail.com>
Subject: Re: [PATCH] slob: push the min alignment to long long
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, "David S. Miller" <davem@davemloft.net>, netfilter@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, Jun 15, 2011 at 12:16 AM, Christoph Lameter <cl@linux.com> wrote:
> Maybe this would work too?
>
>
> Subject: slauob: Unify alignment definition
>
> Every slab has its on alignment definition in include/linux/sl?b_def.h. Extract those
> and define a common set in include/linux/slab.h.
>
> SLOB: As notes sometimes we need double word alignment on 32 bit. This gives all
> structures allocated by SLOB a unsigned long long alignment like the others do.
>
> SLAB: If ARCH_SLAB_MINALIGN is not set SLAB would set ARCH_SLAB_MINALIGN to
> zero meaning no alignment at all. Give it the default unsigned long long alignment.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
