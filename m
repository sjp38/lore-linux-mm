Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 26CD16B02E1
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 05:40:38 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id m79so19372947oik.5
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 02:40:38 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id p22si875608oic.265.2017.04.27.02.40.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 02:40:36 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/7] mm/hugetlb/migration: Use set_huge_pte_at instead
 of set_pte_at
Date: Thu, 27 Apr 2017 09:39:21 +0000
Message-ID: <20170427093921.GA8842@hori1.linux.bs1.fc.nec.co.jp>
References: <1492449106-27467-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1492449106-27467-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1492449106-27467-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <61CB2DFD1BABB142A68ABEB2B69D8622@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mpe@ellerman.id.au" <mpe@ellerman.id.au>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

On Mon, Apr 17, 2017 at 10:41:40PM +0530, Aneesh Kumar K.V wrote:
> The right interface to use to set a hugetlb pte entry is set_huge_pte_at.=
 Use
> that instead of set_pte_at.
>=20
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
