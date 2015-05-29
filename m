Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id EF11C6B0071
	for <linux-mm@kvack.org>; Thu, 28 May 2015 21:53:04 -0400 (EDT)
Received: by pabru16 with SMTP id ru16so36690532pab.1
        for <linux-mm@kvack.org>; Thu, 28 May 2015 18:53:04 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id d4si6123429pdj.184.2015.05.28.18.53.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 28 May 2015 18:53:04 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t4T1r0v6008470
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Fri, 29 May 2015 10:53:01 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v3 2/3] mm/hugetlb: compute/return the number of regions
 added by region_add()
Date: Fri, 29 May 2015 01:48:40 +0000
Message-ID: <20150529014839.GA2986@hori1.linux.bs1.fc.nec.co.jp>
References: <1432749371-32220-1-git-send-email-mike.kravetz@oracle.com>
 <1432749371-32220-3-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1432749371-32220-3-git-send-email-mike.kravetz@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <D3CE73894623EE4E929B0971865C1107@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, Luiz Capitulino <lcapitulino@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, May 27, 2015 at 10:56:10AM -0700, Mike Kravetz wrote:
> Modify region_add() to keep track of regions(pages) added to the
> reserve map and return this value.  The return value can be
> compared to the return value of region_chg() to determine if the
> map was modified between calls.
>=20
> Make vma_commit_reservation() also pass along the return value of
> region_add().  In the normal case, we want vma_commit_reservation
> to return the same value as the preceding call to vma_needs_reservation.
> Create a common __vma_reservation_common routine to help keep the
> special case return values in sync
>=20
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
