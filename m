Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 6E0BB6B0147
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 04:25:00 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id b13so3882846wgh.14
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 01:24:59 -0700 (PDT)
Received: from mail-we0-x236.google.com (mail-we0-x236.google.com [2a00:1450:400c:c03::236])
        by mx.google.com with ESMTPS id a5si734282wiy.31.2014.06.11.01.24.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 01:24:59 -0700 (PDT)
Received: by mail-we0-f182.google.com with SMTP id q59so3455001wes.13
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 01:24:58 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC PATCH 2/3] DMA, CMA: use general CMA reserved area management framework
In-Reply-To: <20140610024910.GB19036@js1304-P5Q-DELUXE>
References: <1401757919-30018-1-git-send-email-iamjoonsoo.kim@lge.com> <1401757919-30018-3-git-send-email-iamjoonsoo.kim@lge.com> <xa1twqcyjx3z.fsf@mina86.com> <20140610024910.GB19036@js1304-P5Q-DELUXE>
Date: Wed, 11 Jun 2014 10:24:55 +0200
Message-ID: <xa1t38fb3lbc.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Tue, Jun 10 2014, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> Without including device.h, build failure occurs.
> In dma-contiguous.h, we try to access to dev->cma_area, so we need
> device.h. In the past, we included it luckily by swap.h in
> drivers/base/dma-contiguous.c. Swap.h includes node.h and then node.h
> includes device.h, so we were happy. But, in this patch, I remove
> 'include <linux/swap.h>' so we need to include device.h explicitly.

Ack.

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
