Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1EC876B0038
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 21:30:05 -0400 (EDT)
Received: by pdbni2 with SMTP id ni2so38238286pdb.1
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 18:30:04 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id zg5si447284pbb.66.2015.03.31.18.30.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Mar 2015 18:30:03 -0700 (PDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC PATCH 00/11] an introduction of library operating system for Linux (LibOS)
In-Reply-To: <m2sicnalnh.wl@sfc.wide.ad.jp>
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp> <551164ED.5000907@nod.at> <m2twxacw13.wl@sfc.wide.ad.jp> <55117565.6080002@nod.at> <m2sicuctb2.wl@sfc.wide.ad.jp> <55118277.5070909@nod.at> <m2bnjhcevt.wl@sfc.wide.ad.jp> <55133BAF.30301@nod.at> <m2h9t7bubh.wl@wide.ad.jp> <5514560A.7040707@nod.at> <m28uejaqyn.wl@wide.ad.jp> <55152137.20405@nod.at> <m2sicnalnh.wl@sfc.wide.ad.jp>
Date: Wed, 01 Apr 2015 11:59:39 +1030
Message-ID: <87iodgocu4.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>, richard@nod.at
Cc: linux-arch@vger.kernel.org, arnd@arndb.de, corbet@lwn.net, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, jdike@addtoit.com, mathieu.lacage@gmail.com

Hajime Tazaki <tazaki@sfc.wide.ad.jp> writes:
> the issue here is the decision between 'no-ops' and
> 'assert(false)' depends on the context. an auto-generated
> mechanism needs some hand-written parameters I think.

Yes, I used auto-generated (fprintf, abort) stubs for similar testing in
pettycoin, where if it failed to link it would generate such stubs
for undefined symbols.

It's not a panacea, but it helps speed up rejiggin after code changes.
Generating noop stubs can actually make that process slower, as you can
get failures because you now need to do something in that stub.

> one more concern on the out-of-arch-tree design is that how
> to handle our asm-generic-based header files
> (arch/lib/include/asm). we have been heavily used
> 'generic-y' in the Kbuild file to reuse header files.

Yeah, the arch trick is clever.

Cheers,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
