Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 38F576B0036
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 19:36:24 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id un15so8072029pbc.27
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 16:36:23 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ai8si17151177pad.96.2014.01.13.16.36.22
        for <linux-mm@kvack.org>;
        Mon, 13 Jan 2014 16:36:23 -0800 (PST)
Date: Mon, 13 Jan 2014 16:36:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V3 2/2] mm/memblock: Add support for excluded memory
 areas
Message-Id: <20140113163620.ade5ee9171c5f443a227f8af@linux-foundation.org>
In-Reply-To: <1389618217-48166-3-git-send-email-phacht@linux.vnet.ibm.com>
References: <1389618217-48166-1-git-send-email-phacht@linux.vnet.ibm.com>
	<1389618217-48166-3-git-send-email-phacht@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, qiuxishi@huawei.com, dhowells@redhat.com, daeseok.youn@gmail.com, liuj97@gmail.com, yinghai@kernel.org, zhangyanfei@cn.fujitsu.com, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, tangchen@cn.fujitsu.com

On Mon, 13 Jan 2014 14:03:37 +0100 Philipp Hachtmann <phacht@linux.vnet.ibm.com> wrote:

> Add a new memory state "nomap" to memblock. This can be used to truncate
> the usable memory in the system without forgetting about what is really
> installed.
> 
> ...
>
>  5 files changed, 254 insertions(+), 70 deletions(-)

Patch is big.  I'll toss this in for some testing but it does look too
large and late for 3.14.  How will this affect your s390 development?

Hopefully some people who are familiar with memblock will have time to
review this carefully, please.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
