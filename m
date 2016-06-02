Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id B3CEE6B007E
	for <linux-mm@kvack.org>; Wed,  1 Jun 2016 20:43:04 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id h144so75219733ita.1
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 17:43:04 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id s205si4948209oif.23.2016.06.01.17.43.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 01 Jun 2016 17:43:04 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1] mm: thp: check pmd_trans_unstable() after
 split_huge_pmd()
Date: Thu, 2 Jun 2016 00:37:03 +0000
Message-ID: <20160602003702.GA18004@hori1.linux.bs1.fc.nec.co.jp>
References: <1464741400-12143-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20160601093957.GA8493@node.shutemov.name>
In-Reply-To: <20160601093957.GA8493@node.shutemov.name>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <E63B24DCDC0043479ECFD37B28B750F7@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, Jun 01, 2016 at 12:39:57PM +0300, Kirill A. Shutemov wrote:
> On Wed, Jun 01, 2016 at 09:36:40AM +0900, Naoya Horiguchi wrote:
> > split_huge_pmd() doesn't guarantee that the pmd is normal pmd pointing =
to
> > pte entries, which can be checked with pmd_trans_unstable().
>=20
> Could you be more specific on when we don't have normal ptes after
> split_huge_pmd? Race with other thread? DAX?

Actually I don't have any such specific case in mind.
__split_huge_pmd could skip real split code. In most case the skip happens
when the pmd is already split and pointing to normal ptes, and I'm not sure
when the pmd could be none or bad ...

So my above description seems misstatement, I should say "some caller does
assertion and some does differently and some not, so let's do it in unified
manner".

- Naoya

>
> I guess we can modify split_huge_pmd() to return if the pmd was split or
> not.=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
