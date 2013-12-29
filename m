Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5762C6B0035
	for <linux-mm@kvack.org>; Sun, 29 Dec 2013 06:45:51 -0500 (EST)
Received: by mail-wg0-f51.google.com with SMTP id b13so9210765wgh.18
        for <linux-mm@kvack.org>; Sun, 29 Dec 2013 03:45:50 -0800 (PST)
Received: from mail-we0-x234.google.com (mail-we0-x234.google.com [2a00:1450:400c:c03::234])
        by mx.google.com with ESMTPS id vi3si1369731wjc.59.2013.12.29.03.45.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 29 Dec 2013 03:45:50 -0800 (PST)
Received: by mail-we0-f180.google.com with SMTP id t61so9490976wes.11
        for <linux-mm@kvack.org>; Sun, 29 Dec 2013 03:45:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <524fc449.06a3420a.03dc.ffffb760SMTPIN_ADDED_BROKEN@mx.google.com>
References: <522E9569.9060104@huawei.com>
	<524fc449.06a3420a.03dc.ffffb760SMTPIN_ADDED_BROKEN@mx.google.com>
Date: Sun, 29 Dec 2013 13:45:49 +0200
Message-ID: <CAOJsxLEiafGHcX6zy85NRXN7ydnVKNv2oZHNwffp9=hORxGJog@mail.gmail.com>
Subject: Re: [PATCH] slub: Fix calculation of cpu slabs
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Li Zefan <lizefan@huawei.com>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sat, Oct 5, 2013 at 10:48 AM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
> On Tue, Sep 10, 2013 at 11:43:37AM +0800, Li Zefan wrote:
>>  /sys/kernel/slab/:t-0000048 # cat cpu_slabs
>>  231 N0=16 N1=215
>>  /sys/kernel/slab/:t-0000048 # cat slabs
>>  145 N0=36 N1=109
>>
>>See, the number of slabs is smaller than that of cpu slabs.
>>
>>The bug was introduced by commit 49e2258586b423684f03c278149ab46d8f8b6700
>>("slub: per cpu cache for partial pages").
>>
>>We should use page->pages instead of page->pobjects when calculating
>>the number of cpu partial slabs. This also fixes the mapping of slabs
>>and nodes.
>>
>>As there's no variable storing the number of total/active objects in
>>cpu partial slabs, and we don't have user interfaces requiring those
>>statistics, I just add WARN_ON for those cases.
>>
>>Cc: <stable@vger.kernel.org> # 3.2+
>>Signed-off-by: Li Zefan <lizefan@huawei.com>
>
> Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Applied and sorry for the slow response!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
