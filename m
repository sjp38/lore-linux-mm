Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6DC8B6B003B
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 05:53:21 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id y10so985778wgg.32
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 02:53:20 -0700 (PDT)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id d10si793502wjw.131.2014.06.12.02.53.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 02:53:20 -0700 (PDT)
Received: by mail-wg0-f42.google.com with SMTP id z12so959637wgg.13
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 02:53:19 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH v2 01/10] DMA, CMA: clean-up log message
In-Reply-To: <xa1toaxyjym3.fsf@mina86.com>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com> <1402543307-29800-2-git-send-email-iamjoonsoo.kim@lge.com> <87y4x2pwnk.fsf@linux.vnet.ibm.com> <20140612055358.GA30128@js1304-P5Q-DELUXE> <xa1toaxyjym3.fsf@mina86.com>
Date: Thu, 12 Jun 2014 11:53:16 +0200
Message-ID: <xa1tegyujvxv.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Thu, Jun 12 2014, Michal Nazarewicz <mina86@mina86.com> wrote:
> I used =E2=80=9Cfunction(arg1, arg2, =E2=80=A6)=E2=80=9D at the *beginnin=
g* of functions when
> the arguments passed to the function were included in the message.  In
> all other cases I left it at just =E2=80=9Cfunction:=E2=80=9D (or just no=
 additional
> prefix).  IMO that's a reasonable strategy.

At closer inspection, I realised drivers/base/dma-contiguous.c is
Marek's code, but the above I think is still reasonable thing to do, so
I'd rather standardise on having =E2=80=9Cfunction(=E2=80=A6)=E2=80=9D only=
 at the beginning of
a function.  Just my 0.02 CHF.

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
