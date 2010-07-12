Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id ED7996B02A5
	for <linux-mm@kvack.org>; Mon, 12 Jul 2010 11:15:29 -0400 (EDT)
Date: Mon, 12 Jul 2010 10:11:50 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [S+Q2 00/19] SLUB with queueing (V2) beats SLAB netperf TCP_RR
In-Reply-To: <20100710195621.GA13720@fancy-poultry.org>
Message-ID: <alpine.DEB.2.00.1007121010420.14328@router.home>
References: <20100709190706.938177313@quilx.com> <20100710195621.GA13720@fancy-poultry.org>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811839-1120396131-1278947511=:14328"
Sender: owner-linux-mm@kvack.org
To: Heinz Diehl <htd@fancy-poultry.org>
Cc: linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811839-1120396131-1278947511=:14328
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Sat, 10 Jul 2010, Heinz Diehl wrote:

> On 10.07.2010, Christoph Lameter wrote:
>
> > The following patchset cleans some pieces up and then equips SLUB with
> > per cpu queues that work similar to SLABs queues. With that approach
> > SLUB wins significantly in hackbench and improves also on tcp_rr.
>
> The patchset applies cleanly, however compilation fails with
>
> [....]
> mm/slub.c: In function =E2=80=98alloc_kmem_cache_cpus=E2=80=99:
> mm/slub.c:2093: error: negative width in bit-field =E2=80=98<anonymous>=
=E2=80=99
> make[1]: *** [mm/slub.o] Error 1
> make: *** [mm] Error 2
> make: *** Waiting for unfinished jobs....
> [....]

You need a sufficient PERCPU_DYNAMIC_EARLY_SIZE to be configured. What
platform is this? Tejon: You suggested the BUILD_BUG_ON(). How can he
increase the early size?


---1463811839-1120396131-1278947511=:14328--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
