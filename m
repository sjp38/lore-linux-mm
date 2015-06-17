Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f43.google.com (mail-oi0-f43.google.com [209.85.218.43])
	by kanga.kvack.org (Postfix) with ESMTP id 4778E6B006E
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 03:59:38 -0400 (EDT)
Received: by oial131 with SMTP id l131so28655511oia.3
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 00:59:38 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id px9si2187950obc.92.2015.06.17.00.59.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 17 Jun 2015 00:59:37 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 1/4] pagemap: check permissions and capabilities at
 open time
Date: Wed, 17 Jun 2015 07:58:10 +0000
Message-ID: <20150617075809.GB384@hori1.linux.bs1.fc.nec.co.jp>
References: <20150609195333.21971.58194.stgit@zurg>
 <20150609200015.21971.25692.stgit@zurg>
In-Reply-To: <20150609200015.21971.25692.stgit@zurg>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <4D66D730AA62554CA938E4CF12CCA0A0@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-api@vger.kernel.org" <linux-api@vger.kernel.org>, Mark Williamson <mwilliamson@undo-software.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Tue, Jun 09, 2015 at 11:00:15PM +0300, Konstantin Khlebnikov wrote:
> From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>=20
> This patch moves permission checks from pagemap_read() into pagemap_open(=
).
>=20
> Pointer to mm is saved in file->private_data. This reference pins only
> mm_struct itself. /proc/*/mem, maps, smaps already work in the same way.
>=20
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Link: http://lkml.kernel.org/r/CA+55aFyKpWrt_Ajzh1rzp_GcwZ4=3D6Y=3DkOv8hB=
z172CFJp6L8Tg@mail.gmail.com
                                                          =20
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>   =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
