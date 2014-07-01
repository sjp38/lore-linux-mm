Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 9E8206B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 13:42:38 -0400 (EDT)
Received: by mail-qg0-f44.google.com with SMTP id j107so3707558qga.17
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 10:42:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l5si4500649qaz.38.2014.07.01.10.42.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Jul 2014 10:42:37 -0700 (PDT)
Message-ID: <53B2F303.1010306@redhat.com>
Date: Tue, 01 Jul 2014 13:42:27 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] rmap: fix pgoff calculation to handle hugepage correctly
References: <1404225982-22739-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1404225982-22739-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 07/01/2014 10:46 AM, Naoya Horiguchi wrote:
> I triggered VM_BUG_ON() in vma_address() when I try to migrate an
> anonymous hugepage with mbind() in the kernel v3.16-rc3. This is
> because pgoff's calculation in rmap_walk_anon() fails to consider
> compound_order() only to have an incorrect value. So this patch
> fixes it.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: Rik van Riel <riel@redhat.com>

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJTsvMDAAoJEM553pKExN6DFIkH/1JOOZq3VtVLMr4f5I7QsqkE
/g3QU5JKbCdQZKeV+X1jFbZOyU7/B5gwSTVJMBIlAfFjm/tu21OgUeKAafvgfQHl
EVzisjPg1kN5jgtRrO61u4Bnt0rkLWSobBhDpwxslU2nWHNjVlyTBV5Hu2WcpWPB
PHoo+qt1/W185tVe6jeb6VpSZwGDXHWj7AQXGCBO3llCIythpbi/+u1IeoL3jW7V
UG2/xWZiRVBAoKoD4myvJvY6ny8o+WLpZh505WWJKM6WuTvSPhyOt+K1tWV3Sttq
km1aVgnSBYiH6m7if1PwLFtFTlvwhiDI2VZwW+GwhXWak6dh6lS+TssxOw1M9U4=
=zYJe
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
