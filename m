Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 969C16B0038
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 20:47:52 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id j127so3571556itj.17
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 17:47:52 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id l5si13073462itl.42.2017.04.18.17.47.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 17:47:51 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH V3] mm/madvise: Move up the behavior parameter validation
Date: Wed, 19 Apr 2017 00:46:32 +0000
Message-ID: <20170419004631.GA21629@hori1.linux.bs1.fc.nec.co.jp>
References: <20170413092008.5437-1-khandual@linux.vnet.ibm.com>
 <20170418052844.24891-1-khandual@linux.vnet.ibm.com>
In-Reply-To: <20170418052844.24891-1-khandual@linux.vnet.ibm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <6785EABA5E89A64E8231061A1D0D4934@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Tue, Apr 18, 2017 at 10:58:44AM +0530, Anshuman Khandual wrote:
> The madvise_behavior_valid() function should be called before
> acting upon the behavior parameter. Hence move up the function.
> This also includes MADV_SOFT_OFFLINE and MADV_HWPOISON options
> as valid behavior parameter for the system call madvise().
>=20
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
