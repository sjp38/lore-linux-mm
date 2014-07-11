Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id EB4D16B0037
	for <linux-mm@kvack.org>; Fri, 11 Jul 2014 10:51:13 -0400 (EDT)
Received: by mail-wg0-f48.google.com with SMTP id x13so1180131wgg.31
        for <linux-mm@kvack.org>; Fri, 11 Jul 2014 07:51:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id lh10si4442699wic.54.2014.07.11.07.50.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jul 2014 07:50:29 -0700 (PDT)
Message-ID: <53BFF995.5020602@redhat.com>
Date: Fri, 11 Jul 2014 10:49:57 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/page-writeback.c: fix divide by zero in bdi_dirty_limits
References: <20140711081656.15654.19946.stgit@localhost.localdomain>
In-Reply-To: <20140711081656.15654.19946.stgit@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maxim Patlasov <MPatlasov@parallels.com>, akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, mhocko@suse.cz, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, fengguang.wu@intel.com, jweiner@redhat.com

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 07/11/2014 04:18 AM, Maxim Patlasov wrote:
> Under memory pressure, it is possible for dirty_thresh, calculated
> by global_dirty_limits() in balance_dirty_pages(), to equal zero.
> Then, if strictlimit is true, bdi_dirty_limits() tries to resolve
> the proportion:
> 
> bdi_bg_thresh : bdi_thresh = background_thresh : dirty_thresh
> 
> by dividing by zero.
> 
> Signed-off-by: Maxim Patlasov <mpatlasov@parallels.com>

Acked-by: Rik van Riel <riel@redhat.com>

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJTv/mVAAoJEM553pKExN6Dw8UH/1KgQrLYDTVQIzvaXNxPwxOv
xXqrWAnFf+mOflA/Tu/TqOwPUV20YSWTAuJU/NbyLSR0Ak15beCjH4ObifpgZgR+
k9lvJNHEk6XUQH0nERsHcwbNZMGtLBAvyw1oRCVXm6V1IVpbpp0IckP29KP5Ibs4
FChNNna/h7zOTpgysTtuKDO6JGuPy+sCjK5aNVH0jSTd4ENtTD1HtfkgtU/OZVyS
m8afzJ0sp/A1sQGy+41ZorR3I0dAmtX3Qtx335QjrZQAy8bT3jCLBLjEHW9xQhCh
afuZhfHdrXHiNh8RZnLgeFWiVzYHDc6ytoD7aZQsxaFZIlyccVRzc7SvarrT4ys=
=jTrs
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
