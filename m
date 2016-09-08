Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 258ED6B0264
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 05:57:50 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id s131so48638067oie.1
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 02:57:50 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id k98si37970027otk.2.2016.09.08.02.57.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Sep 2016 02:57:49 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC PATCH v3 1/2] mm/hugetlb: Introduce ARCH_HAS_GIGANTIC_PAGE
Date: Thu, 8 Sep 2016 09:55:05 +0000
Message-ID: <20160908095504.GA2554@hori1.linux.bs1.fc.nec.co.jp>
References: <1471872004-59365-1-git-send-email-xieyisheng1@huawei.com>
 <1471872004-59365-2-git-send-email-xieyisheng1@huawei.com>
In-Reply-To: <1471872004-59365-2-git-send-email-xieyisheng1@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <4F7CF4802D8ACA469E2FECB85631484E@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xie Yisheng <xieyisheng1@huawei.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "guohanjun@huawei.com" <guohanjun@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "will.deacon@arm.com" <will.deacon@arm.com>, "mhocko@suse.com" <mhocko@suse.com>, "dave.hansen@intel.com" <dave.hansen@intel.com>, "sudeep.holla@arm.com" <sudeep.holla@arm.com>, "catalin.marinas@arm.com" <catalin.marinas@arm.com>, "mark.rutland@arm.com" <mark.rutland@arm.com>, "robh+dt@kernel.org" <robh+dt@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>

On Mon, Aug 22, 2016 at 09:20:03PM +0800, Xie Yisheng wrote:
> Avoid making ifdef get pretty unwieldy if many ARCHs support gigantic pag=
e.
> No functional change with this patch.
>=20
> Signed-off-by: Xie Yisheng <xieyisheng1@huawei.com>

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
