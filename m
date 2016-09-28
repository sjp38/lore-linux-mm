Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8AE9A28024C
	for <linux-mm@kvack.org>; Wed, 28 Sep 2016 19:20:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 2so56828405pfs.1
        for <linux-mm@kvack.org>; Wed, 28 Sep 2016 16:20:57 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id gy7si10835392pac.240.2016.09.28.16.20.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Sep 2016 16:20:56 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2] mm: remove unnecessary condition in
 remove_inode_hugepages
Date: Wed, 28 Sep 2016 05:48:28 +0000
Message-ID: <20160928054827.GA27463@hori1.linux.bs1.fc.nec.co.jp>
References: <1474985786-5052-1-git-send-email-zhongjiang@huawei.com>
In-Reply-To: <1474985786-5052-1-git-send-email-zhongjiang@huawei.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <F6237AC2362E0647A26FFFEF2BA15222@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Sep 27, 2016 at 10:16:26PM +0800, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
>=20
> when the huge page is added to the page cahce (huge_add_to_page_cache),
> the page private flag will be cleared. since this code
> (remove_inode_hugepages) will only be called for pages in the
> page cahce, PagePrivate(page) will always be false.
>=20
> The patch remove the code without any functional change.
>=20
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>

Looks good to me.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
