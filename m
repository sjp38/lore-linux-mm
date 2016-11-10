Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id CEE896B0283
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 04:15:50 -0500 (EST)
Received: by mail-pa0-f69.google.com with SMTP id ro13so89032006pac.7
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 01:15:50 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id 11si3724618pgf.221.2016.11.10.01.15.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Nov 2016 01:15:50 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 07/12] mm: thp: check pmd migration entry in common
 path
Date: Thu, 10 Nov 2016 09:12:07 +0000
Message-ID: <20161110091207.GB9173@hori1.linux.bs1.fc.nec.co.jp>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-8-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5824317E.5050706@linux.vnet.ibm.com>
In-Reply-To: <5824317E.5050706@linux.vnet.ibm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <58C392E89D5DC34697BDE30F50987D1F@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Balbir Singh <bsingharora@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Nov 10, 2016 at 02:06:14PM +0530, Anshuman Khandual wrote:
> On 11/08/2016 05:01 AM, Naoya Horiguchi wrote:
> > If one of callers of page migration starts to handle thp, memory manage=
ment code
> > start to see pmd migration entry, so we need to prepare for it before e=
nabling.
> > This patch changes various code point which checks the status of given =
pmds in
> > order to prevent race between thp migration and the pmd-related works.
>=20
> There are lot of changes in this one patch. Should not we split
> this up into multiple patches and explain them in a bit detail
> through their commit messages ?

Yes, and I admit that I might change more than necessary, if the context
never encounters migration entry for any reason, no change is needed.
I'll dig more detail.

- Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
