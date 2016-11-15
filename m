Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id C09436B0038
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 23:00:56 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id b123so72489745itb.3
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 20:00:56 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id cm4si20753674pac.174.2016.11.14.20.00.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Nov 2016 20:00:55 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 04/12] mm: thp: introduce
 CONFIG_ARCH_ENABLE_THP_MIGRATION
Date: Tue, 15 Nov 2016 02:05:38 +0000
Message-ID: <20161115020537.GA8738@hori1.linux.bs1.fc.nec.co.jp>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-5-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20161111111840.GF19382@node.shutemov.name>
In-Reply-To: <20161111111840.GF19382@node.shutemov.name>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <0248F00E8BCFE44385D7A43A376FB803@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Nov 11, 2016 at 02:18:40PM +0300, Kirill A. Shutemov wrote:
> On Tue, Nov 08, 2016 at 08:31:49AM +0900, Naoya Horiguchi wrote:
> > +static inline bool thp_migration_supported(void)
> > +{
> > +#ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
> > +	return true;
> > +#else
> > +	return false;
> > +#endif
>=20
> Em..
>=20
> 	return IS_ENABLED(CONFIG_ARCH_ENABLE_THP_MIGRATION);

Looks better, thank you.

- Naoya=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
