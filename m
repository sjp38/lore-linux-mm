Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id EDC688E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 08:55:17 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id d35so5122348qtd.20
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 05:55:17 -0800 (PST)
Received: from sonic310-12.consmr.mail.ir2.yahoo.com (sonic310-12.consmr.mail.ir2.yahoo.com. [77.238.177.33])
        by mx.google.com with ESMTPS id j14si110493qvm.164.2018.12.14.05.55.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 05:55:17 -0800 (PST)
Subject: Re: [PATCH] fix page_count in ->iomap_migrate_page()
References: <1544766961-3492-1-git-send-email-openzhangj@gmail.com>
 <1618433.IpySj692Hd@blindfold> <2b19b3c4-2bc4-15fa-15cc-27a13e5c7af1@aol.com>
 <5520068.cAKZ7BqcUI@blindfold>
From: Gao Xiang <hsiangkao@aol.com>
Message-ID: <d18a4e12-c062-0c6c-52e4-83d5e2a14da5@aol.com>
Date: Fri, 14 Dec 2018 21:55:01 +0800
MIME-Version: 1.0
In-Reply-To: <5520068.cAKZ7BqcUI@blindfold>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: Artem Bityutskiy <dedekind1@gmail.com>, zhangjun <openzhangj@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, hch@lst.de, bfoster@redhat.com, Dave Chinner <david@fromorbit.com>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, n-horiguchi@ah.jp.nec.com, mgorman@techsingularity.net, aarcange@redhat.com, willy@infradead.org, linux@dominikbrodowski.net, linux-mm@kvack.org, Gao Xiang <gaoxiang25@huawei.com>

Hi Richard,

On 2018/12/14 21:35, Richard Weinberger wrote:
> Hmm, in case of UBIFS it seems easy. We can add a get/put_page() around setting/clearing
> the flag.
> I did that now and so far none of my tests exploded.

Yes, many existed codes are based on this restriction in order to be freeable race-free.
and that's it since PG_Private was once introduced at first by Andrew Morton in 2002
for many Linux versions....and it's not bad I think... :)

Thanks,
Gao Xiang
