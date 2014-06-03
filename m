Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 217E16B004D
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 03:02:26 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id w62so6320317wes.16
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 00:02:25 -0700 (PDT)
Received: from mail-wg0-x22b.google.com (mail-wg0-x22b.google.com [2a00:1450:400c:c00::22b])
        by mx.google.com with ESMTPS id bf3si30386896wjc.6.2014.06.03.00.02.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 00:02:24 -0700 (PDT)
Received: by mail-wg0-f43.google.com with SMTP id l18so6257322wgh.14
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 00:02:23 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC PATCH 3/3] PPC, KVM, CMA: use general CMA reserved area management framework
In-Reply-To: <1401757919-30018-4-git-send-email-iamjoonsoo.kim@lge.com>
References: <1401757919-30018-1-git-send-email-iamjoonsoo.kim@lge.com> <1401757919-30018-4-git-send-email-iamjoonsoo.kim@lge.com>
Date: Tue, 03 Jun 2014 09:02:17 +0200
Message-ID: <xa1ttx82jx1i.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Tue, Jun 03 2014, Joonsoo Kim wrote:
> Now, we have general CMA reserved area management framework,
> so use it for future maintainabilty. There is no functional change.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

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
