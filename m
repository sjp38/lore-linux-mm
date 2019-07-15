Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 276FEC76191
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 22:00:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A7E4420665
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 22:00:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="EC6fKVCh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7E4420665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24B536B0003; Mon, 15 Jul 2019 18:00:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D4376B0006; Mon, 15 Jul 2019 18:00:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09CF76B0007; Mon, 15 Jul 2019 18:00:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C3BBE6B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 18:00:34 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id k20so11266191pgg.15
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 15:00:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=X/oUKNxDTp84H2JqM60txAgcpY2XdRwedM+r2XD9v/4=;
        b=c9ovxkuG80Bo9mn+nosiRQlfVRL5d+gnd0l/XQEPMXkHoQGRYz7dt+uA0Amg7A4xtY
         tR6Uo853T3/p6zni8AGLkpBgleW/rUBLf3erEOmIPrLBihNbAn4hfHasrEcOL63gU5A2
         XH5OJBOTV++iUd+8qgps7sMNqNRWCUdaccA6pvaB7uz/YW1yVWoVLzByDdaI43gXIdFp
         9m2MXFm88qkiTiJG/GiOfWlb3tYCr/tQYgvSBQWbIgdhP274iC+haM3rcHvBOloJpmDA
         OJ+yPcjojPQpzifllGBNO0jA3fDYw6Tmp1ZEglyoXa41r+ZBq3RmrKOPh2HLSOVaAcwu
         CbKA==
X-Gm-Message-State: APjAAAW37k6bLIUqDLDLkr7GGz2602pezgobjawAyEHcaZPR9/0ctAuV
	p4mBHzHNTCbjM9KbkCubXXXxL0/mX2o+/Yl1NZiI5ariMYDgYlOPzVnpPcq03MzhBtC+7QTE2N5
	0Rhb240M6DCi6L3AEQuC+CfugXCf2z1j8HgAFVsryz7rFzCQg3zg1GsV18DMlx1x0eA==
X-Received: by 2002:a17:90b:f12:: with SMTP id br18mr30459890pjb.127.1563228034389;
        Mon, 15 Jul 2019 15:00:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhwkE1wv17jAx8UWtJMJXqhB+M1o2Nb4FVtrHAUPQfwWuIuC071uNMjEyB4dAYUK0ZzInY
X-Received: by 2002:a17:90b:f12:: with SMTP id br18mr30459752pjb.127.1563228033005;
        Mon, 15 Jul 2019 15:00:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563228033; cv=none;
        d=google.com; s=arc-20160816;
        b=c1FzsfT6VGL5tWcz7z3U/ZOMCUZDMTXKh6zxlDGt3gLKmXq1wgdDsGc8NyVohH/dzr
         t6q5l0yoZ6M6JnJY5EIl8j+2eCvS1L1NtCDU5OYpTrikjqzM1TIFa9morZ38ZvN3D3q8
         sBYGnrUL7lJKtQb8HtYL792L7EHGbRQvhk6monop0biZZjHq0jDXxYGAK2lA2qK/IHbI
         d1DPIWi5kOizYBR2xBGLXv65qSdQ7xMHrKjFNRQkB+XtXKxtPm2uSS4PgcCtBju0lcRO
         zvzr4CclaVpjdM2NSZ0y6mo3UlHA0z6hdyDE2mbhaTHKWLuKmKNGtBqKdMbx6LWwycOf
         dGpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=X/oUKNxDTp84H2JqM60txAgcpY2XdRwedM+r2XD9v/4=;
        b=M2uM+ZY32Si3JrRZyYq+qPqR9ykCbEoCCw2vR/enIYWIcAwcSafji9fLwFqWtp9w31
         HBm5Zdv9qgZ4KX9aAunkNDhpQX7pV8D3I/CP20cUMoPeevdit0Cp/a8ch/S00AXnwHpM
         m29Vzo3ftMuX4O7RGAUIyNyjlJChgSLIhaYOc1TeoAjhEg7Fu72yxyyZvKIg6zaRL/NW
         4xGwyWjjsdYUiDtxC7aJk51Wed8ru66NjEhVpYL5xJzlmzHnFfDS5hr7fEToHjQVZ2bL
         JSONBnN3fI5X5CCi+sre68wN9DdVBoua6ZItIkLaJStnDk/Q3FNrew6SCXuec3pDMtwO
         reyg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=EC6fKVCh;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i18si17945071pfa.23.2019.07.15.15.00.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 15:00:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=EC6fKVCh;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1DD472171F;
	Mon, 15 Jul 2019 22:00:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563228032;
	bh=opj85GkhTsX799kvL6zjC53Z5Nb4q3yDICVYRU7YfS0=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=EC6fKVCh7fcp4L3S+xIIzlJ041+FzYRiPqD+o/00VyfrmwI78fMb8glbcLyVutXZN
	 SjI9PDYmbGBy8XjyzzJKqlCvHtOzhWif4oCIPemh5CMm+eEiCheYoK9L12l/K117EG
	 Lki6SkcXAH/ihaC/jxXzsC9IORAdtALY1dvq1V2M=
Date: Mon, 15 Jul 2019 15:00:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, =?ISO-8859-1?Q?J?=
 =?ISO-8859-1?Q?=E9r=F4me?= Glisse <jglisse@redhat.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mike Kravetz
 <mike.kravetz@oracle.com>, Jason Gunthorpe <jgg@mellanox.com>
Subject: Re: [PATCH] mm/hmm: Fix bad subpage pointer in try_to_unmap_one
Message-Id: <20190715150031.49c2846f4617f30bca5f043f@linux-foundation.org>
In-Reply-To: <05fffcad-cf5e-8f0c-f0c7-6ffbd2b10c2e@nvidia.com>
References: <20190709223556.28908-1-rcampbell@nvidia.com>
	<20190709172823.9413bb2333363f7e33a471a0@linux-foundation.org>
	<05fffcad-cf5e-8f0c-f0c7-6ffbd2b10c2e@nvidia.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 9 Jul 2019 18:24:57 -0700 Ralph Campbell <rcampbell@nvidia.com> wro=
te:

>=20
> On 7/9/19 5:28 PM, Andrew Morton wrote:
> > On Tue, 9 Jul 2019 15:35:56 -0700 Ralph Campbell <rcampbell@nvidia.com>=
 wrote:
> >=20
> >> When migrating a ZONE device private page from device memory to system
> >> memory, the subpage pointer is initialized from a swap pte which compu=
tes
> >> an invalid page pointer. A kernel panic results such as:
> >>
> >> BUG: unable to handle page fault for address: ffffea1fffffffc8
> >>
> >> Initialize subpage correctly before calling page_remove_rmap().
> >=20
> > I think this is
> >=20
> > Fixes:  a5430dda8a3a1c ("mm/migrate: support un-addressable ZONE_DEVICE=
 page in migration")
> > Cc: stable
> >=20
> > yes?
> >=20
>=20
> Yes. Can you add this or should I send a v2?

I updated the patch.  Could we please have some review input?


From: Ralph Campbell <rcampbell@nvidia.com>
Subject: mm/hmm: fix bad subpage pointer in try_to_unmap_one

When migrating a ZONE device private page from device memory to system
memory, the subpage pointer is initialized from a swap pte which computes
an invalid page pointer. A kernel panic results such as:

BUG: unable to handle page fault for address: ffffea1fffffffc8

Initialize subpage correctly before calling page_remove_rmap().

Link: http://lkml.kernel.org/r/20190709223556.28908-1-rcampbell@nvidia.com
Fixes: a5430dda8a3a1c ("mm/migrate: support un-addressable ZONE_DEVICE page=
 in migration")
Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: "J=E9r=F4me Glisse" <jglisse@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: <stable@vger.kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/rmap.c |    1 +
 1 file changed, 1 insertion(+)

--- a/mm/rmap.c~mm-hmm-fix-bad-subpage-pointer-in-try_to_unmap_one
+++ a/mm/rmap.c
@@ -1476,6 +1476,7 @@ static bool try_to_unmap_one(struct page
 			 * No need to invalidate here it will synchronize on
 			 * against the special swap migration pte.
 			 */
+			subpage =3D page;
 			goto discard;
 		}
=20
_

