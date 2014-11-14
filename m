Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7EDBA6B00D3
	for <linux-mm@kvack.org>; Thu, 13 Nov 2014 20:04:50 -0500 (EST)
Received: by mail-yh0-f54.google.com with SMTP id 29so4454277yhl.41
        for <linux-mm@kvack.org>; Thu, 13 Nov 2014 17:04:50 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id k3si12914635ykc.44.2014.11.13.17.04.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Nov 2014 17:04:46 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm: mincore: add hwpoison page handle
Date: Fri, 14 Nov 2014 01:02:44 +0000
Message-ID: <20141114010320.GA15456@hori1.linux.bs1.fc.nec.co.jp>
References: <000001cffe2a$66a95a50$33fc0ef0$%yang@samsung.com>
 <20141112142022.GA29766@phnom.home.cmpxchg.org>
In-Reply-To: <20141112142022.GA29766@phnom.home.cmpxchg.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <0A7C1CF4A75A604EAC87CC5EE2420470@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Weijie Yang <weijie.yang@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, "mgorman@suse.de" <mgorman@suse.de>, 'Rik van Riel' <riel@redhat.com>, 'Weijie Yang' <weijie.yang.kh@gmail.com>, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>

On Wed, Nov 12, 2014 at 09:20:22AM -0500, Johannes Weiner wrote:
> On Wed, Nov 12, 2014 at 11:39:29AM +0800, Weijie Yang wrote:
> > When encounter pte is a swap entry, the current code handles two cases:
> > migration and normal swapentry, but we have a third case: hwpoison page=
.
> >=20
> > This patch adds hwpoison page handle, consider hwpoison page incore as
> > same as migration.
> >=20
> > Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

>=20
> The change makes sense:
>=20
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
>=20
> But please add a description of what happens when a poison entry is
> encountered with the current code.  I'm guessing swap_address_space()
> will return garbage and this might crash the kernel?

Yes, I think that's correct.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
