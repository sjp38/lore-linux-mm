Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 6EC1D28003A
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 08:15:36 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id n3so1122078wiv.4
        for <linux-mm@kvack.org>; Fri, 31 Oct 2014 05:15:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id hi1si14034316wjc.7.2014.10.31.05.15.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Oct 2014 05:15:34 -0700 (PDT)
Message-ID: <54537D20.2080203@redhat.com>
Date: Fri, 31 Oct 2014 08:14:24 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Fix a spelling mistake
References: <1414751873-19981-1-git-send-email-weiyuan.wei@huawei.com>
In-Reply-To: <1414751873-19981-1-git-send-email-weiyuan.wei@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: w00218164 <weiyuan.wei@huawei.com>, akpm@linux-foundation.org, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org, vbabka@suse.cz, sasha.levin@oracle.com
Cc: lizefan@huawei.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 10/31/2014 06:37 AM, w00218164 wrote:
> From: Wei Yuan <weiyuan.wei@huawei.com>
> 
> This patch fixes a spelling mistake in func __zone_watermark_ok,
> which may was wrongly spelled my.
> 
> Signed-off-by Wei Yuan <weiyuan.wei@huawei.com>

Acked-by: Rik van Riel <riel@redhat.com>

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUU30gAAoJEM553pKExN6DuYEH/A//pb6HSRmQJAkRiQC3PQ/X
Qq8MRDyRiXznoHks6Xd/gbAVGpbLftTXApL+6zKL7Id8CSE8qqvJ2wOg6zuLaoyf
4KpCaPahKF6LVNGLdy8hK0OnR65iM6KnUZNHfPCPfA9FU7oDknuW6+Ryt3RqrF83
bEgczxDfv8p4+24GHhX+UODCOktIxS65Nm3zfRYmNcoMnoIRfgCJZIbjF8Ah5LBY
/0RWAjDAJwvpCZB6wwnttXOJlKhRPx77dnKjkMFJgjxDaplq9hSkKG+EzEqztFEi
n8gtvPCHGQovxctjjv/AFFP0o0mvkl5O/f4V/BChC2Bih7Z6pEvlAwo9SwbKqvU=
=OxmS
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
