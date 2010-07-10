Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 085466B024D
	for <linux-mm@kvack.org>; Sat, 10 Jul 2010 15:57:06 -0400 (EDT)
Date: Sat, 10 Jul 2010 21:56:21 +0200
From: Heinz Diehl <htd@fancy-poultry.org>
Subject: Re: [S+Q2 00/19] SLUB with queueing (V2) beats SLAB netperf TCP_RR
Message-ID: <20100710195621.GA13720@fancy-poultry.org>
References: <20100709190706.938177313@quilx.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20100709190706.938177313@quilx.com>
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On 10.07.2010, Christoph Lameter wrote:=20

> The following patchset cleans some pieces up and then equips SLUB with
> per cpu queues that work similar to SLABs queues. With that approach
> SLUB wins significantly in hackbench and improves also on tcp_rr.

The patchset applies cleanly, however compilation fails with

[....]
mm/slub.c: In function =E2=80=98alloc_kmem_cache_cpus=E2=80=99:
mm/slub.c:2093: error: negative width in bit-field =E2=80=98<anonymous>=E2=
=80=99
make[1]: *** [mm/slub.o] Error 1
make: *** [mm] Error 2
make: *** Waiting for unfinished jobs....
[....]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
