Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 196696B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 17:01:21 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kp14so228568pab.20
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 14:01:20 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id rt6si1659964pbc.348.2014.01.14.14.01.18
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 14:01:19 -0800 (PST)
Date: Tue, 14 Jan 2014 14:01:17 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V3 2/2] mm/memblock: Add support for excluded memory
 areas
Message-Id: <20140114140117.bff3db92027fea9eb6f2af7f@linux-foundation.org>
In-Reply-To: <20140114104253.54ea0470@lilie>
References: <1389618217-48166-1-git-send-email-phacht@linux.vnet.ibm.com>
	<1389618217-48166-3-git-send-email-phacht@linux.vnet.ibm.com>
	<20140113163620.ade5ee9171c5f443a227f8af@linux-foundation.org>
	<20140114104253.54ea0470@lilie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Philipp Hachtmann <phacht@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, qiuxishi@huawei.com, dhowells@redhat.com, daeseok.youn@gmail.com, liuj97@gmail.com, yinghai@kernel.org, zhangyanfei@cn.fujitsu.com, santosh.shilimkar@ti.com, grygorii.strashko@ti.com, tangchen@cn.fujitsu.com

On Tue, 14 Jan 2014 10:42:53 +0100 Philipp Hachtmann <phacht@linux.vnet.ibm.com> wrote:

> Am Mon, 13 Jan 2014 16:36:20 -0800
> schrieb Andrew Morton <akpm@linux-foundation.org>:
> 
> > Patch is big.  I'll toss this in for some testing but it does look too
> > large and late for 3.14.  How will this affect your s390 development?
> 
> It is needed for s390 bootmem -> memblock transition. The s390 dump
> mechanisms cannot be switched to memblock (from using something s390
> specific called memory_chunk) without the nomap list.
> I'm also working on another enhancement on s390 that will rely on a
> clean transition to memblock.
> 
> I have written and tested the stuff on top of our local development
> tree. And then realised that it does not fit the linux-next tree. So I
> converted it to fit linux-next and posted it. Have to maintain two
> versions now. 

So at 3.14-rc1 everything will come good - get the review issues sorted
out, add the patch to your tree (and hence linux-next).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
