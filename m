Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 827A86B02E1
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 05:42:04 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id m79so19393375oik.5
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 02:42:04 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id l16si850539otd.122.2017.04.27.02.42.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 02:42:03 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 3/7] mm/hugetlb: export hugetlb_entry_migration helper
Date: Thu, 27 Apr 2017 09:41:42 +0000
Message-ID: <20170427094142.GA16722@hori1.linux.bs1.fc.nec.co.jp>
References: <1492449106-27467-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1492449106-27467-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1492449106-27467-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <F232CF6AEA37BE4F87D4D9244C633F07@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mpe@ellerman.id.au" <mpe@ellerman.id.au>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

On Mon, Apr 17, 2017 at 10:41:42PM +0530, Aneesh Kumar K.V wrote:
> We will be using this later from the ppc64 code. Change the return type t=
o bool.
>=20
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
