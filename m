Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 22F846B0087
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 17:06:42 -0400 (EDT)
Date: Tue, 10 Sep 2013 21:06:40 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: Fix calculation of cpu slabs
In-Reply-To: <522E9569.9060104@huawei.com>
Message-ID: <0000014109b29246-61170b4a-7ab7-41f0-a887-a1cd62603196-000000@email.amazonses.com>
References: <522E9569.9060104@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, 10 Sep 2013, Li Zefan wrote:

> We should use page->pages instead of page->pobjects when calculating
> the number of cpu partial slabs. This also fixes the mapping of slabs
> and nodes.

True.

> As there's no variable storing the number of total/active objects in
> cpu partial slabs, and we don't have user interfaces requiring those
> statistics, I just add WARN_ON for those cases.


Well that is not strictly required but it does not hurt either.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
