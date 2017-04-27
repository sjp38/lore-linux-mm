Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 098BC6B02EE
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 05:40:47 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id g184so19314919oif.6
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 02:40:47 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id g138si915953oic.9.2017.04.27.02.40.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 02:40:46 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/7] mm/follow_page_mask: Split follow_page_mask to
 smaller functions.
Date: Thu, 27 Apr 2017 09:39:42 +0000
Message-ID: <20170427093942.GB8842@hori1.linux.bs1.fc.nec.co.jp>
References: <1492449106-27467-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1492449106-27467-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1492449106-27467-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <ABA06832BF165D4181180B882D70B82D@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mpe@ellerman.id.au" <mpe@ellerman.id.au>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

On Mon, Apr 17, 2017 at 10:41:41PM +0530, Aneesh Kumar K.V wrote:
> Makes code reading easy. No functional changes in this patch. In a follow=
up
> patch, we will be updating the follow_page_mask to handle hugetlb hugepd =
format
> so that archs like ppc64 can switch to the generic version. This split he=
lps
> in doing that nicely.
>=20
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
