Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3FED66B0073
	for <linux-mm@kvack.org>; Thu, 28 May 2015 21:58:03 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so54647024pdb.0
        for <linux-mm@kvack.org>; Thu, 28 May 2015 18:58:03 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id ca1si6126935pbb.169.2015.05.28.18.58.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 28 May 2015 18:58:02 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp ([10.7.69.202])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t4T1w0uG009202
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Fri, 29 May 2015 10:58:00 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 3/3] mm/hugetlb: handle races in alloc_huge_page and
 hugetlb_reserve_pages
Date: Fri, 29 May 2015 01:49:46 +0000
Message-ID: <20150529014946.GB2986@hori1.linux.bs1.fc.nec.co.jp>
References: <1432749371-32220-1-git-send-email-mike.kravetz@oracle.com>
 <1432749371-32220-4-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1432749371-32220-4-git-send-email-mike.kravetz@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <9B72803D6418AD4CAF397CFAD047CE89@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, May 27, 2015 at 10:56:11AM -0700, Mike Kravetz wrote:
> alloc_huge_page and hugetlb_reserve_pages use region_chg to
> calculate the number of pages which will be added to the reserve
> map.  Subpool and global reserve counts are adjusted based on
> the output of region_chg.  Before the pages are actually added
> to the reserve map, these routines could race and add fewer
> pages than expected.  If this happens, the subpool and global
> reserve counts are not correct.
>=20
> Compare the number of pages actually added (region_add) to those
> expected to added (region_chg).  If fewer pages are actually added,
> this indicates a race and adjust counters accordingly.
>=20
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
