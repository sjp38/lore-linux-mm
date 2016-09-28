Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id CE8346B027F
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 09:13:16 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id l132so39427677wmf.0
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 06:13:16 -0700 (PDT)
Received: from albireo.enyo.de (albireo.enyo.de. [5.158.152.32])
        by mx.google.com with ESMTPS id w7si8500941wjg.48.2016.09.28.06.13.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Sep 2016 06:13:12 -0700 (PDT)
From: Florian Weimer <fw@deneb.enyo.de>
Subject: Re: [PATCH v5] powerpc: Do not make the entire heap executable
References: <20160822185105.29600-1-dvlasenk@redhat.com>
	<87d1jo7qbw.fsf@concordia.ellerman.id.au>
	<20160928025544.GA24199@obsidianresearch.com>
Date: Wed, 28 Sep 2016 15:12:57 +0200
In-Reply-To: <20160928025544.GA24199@obsidianresearch.com> (Jason Gunthorpe's
	message of "Tue, 27 Sep 2016 20:55:44 -0600")
Message-ID: <87k2dwgobq.fsf@mid.deneb.enyo.de>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Florian Weimer <fweimer@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Kees Cook <keescook@chromium.org>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

* Jason Gunthorpe:

> Eg that 32 bit powerpc currently unconditionally injects writable,
> executable pages into a user space process.
>
> This critically undermines all the W^X security work that has been
> done in the tool chain and user space by the PPC community.

Exactly, this is how we found it.  I have pretty extensive execmod
tests, and I'm going to put them into glibc eventually.  It would be
nice to cut down the number of architectures where it will fail.
(Even if you don't believe in security hardening.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
