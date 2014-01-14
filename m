Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3822E6B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 04:43:01 -0500 (EST)
Received: by mail-ee0-f44.google.com with SMTP id c13so86312eek.3
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 01:43:00 -0800 (PST)
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com. [195.75.94.110])
        by mx.google.com with ESMTPS id i1si33969409eev.152.2014.01.14.01.42.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 01:43:00 -0800 (PST)
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <phacht@linux.vnet.ibm.com>;
	Tue, 14 Jan 2014 09:42:59 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id E17751B08074
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 09:42:17 +0000 (GMT)
Received: from d06av07.portsmouth.uk.ibm.com (d06av07.portsmouth.uk.ibm.com [9.149.37.248])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0E9ghvE51314750
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 09:42:43 GMT
Received: from d06av07.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av07.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0E9gtRw021363
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 04:42:55 -0500
Date: Tue, 14 Jan 2014 10:42:53 +0100
From: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Subject: Re: [PATCH V3 2/2] mm/memblock: Add support for excluded memory
 areas
Message-ID: <20140114104253.54ea0470@lilie>
In-Reply-To: <20140113163620.ade5ee9171c5f443a227f8af@linux-foundation.org>
References: <1389618217-48166-1-git-send-email-phacht@linux.vnet.ibm.com>
	<1389618217-48166-3-git-send-email-phacht@linux.vnet.ibm.com>
	<20140113163620.ade5ee9171c5f443a227f8af@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, qiuxishi@huawei.com, dhowells@redhat.com, daeseok.youn@gmail.com, liuj97@gmail.com, yinghai@kernel.org, zhangyanfei@cn.fujitsu.com, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, tangchen@cn.fujitsu.com

Am Mon, 13 Jan 2014 16:36:20 -0800
schrieb Andrew Morton <akpm@linux-foundation.org>:

> Patch is big.  I'll toss this in for some testing but it does look too
> large and late for 3.14.  How will this affect your s390 development?

It is needed for s390 bootmem -> memblock transition. The s390 dump
mechanisms cannot be switched to memblock (from using something s390
specific called memory_chunk) without the nomap list.
I'm also working on another enhancement on s390 that will rely on a
clean transition to memblock.

I have written and tested the stuff on top of our local development
tree. And then realised that it does not fit the linux-next tree. So I
converted it to fit linux-next and posted it. Have to maintain two
versions now. 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
