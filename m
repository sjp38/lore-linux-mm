Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 879CB800C7
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 16:13:35 -0500 (EST)
Received: by mail-pf0-f172.google.com with SMTP id 65so162838514pff.3
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 13:13:35 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y83si74525916pfa.156.2016.01.04.13.13.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Jan 2016 13:13:34 -0800 (PST)
Date: Mon, 4 Jan 2016 13:13:33 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] arm64: fix add kasan bug
Message-Id: <20160104131333.6603ea788a59150e728970f2@linux-foundation.org>
In-Reply-To: <1451556549-8962-1-git-send-email-zhongjiang@huawei.com>
References: <1451556549-8962-1-git-send-email-zhongjiang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: linux-kernel@vger.kernel.org, ryabinin.a.a@gmail.com, linux-mm@kvack.org, catalin.marinas@arm.com, qiuxishi@huawei.com, long.wanglong@huawei.com

On Thu, 31 Dec 2015 18:09:09 +0800 zhongjiang <zhongjiang@huawei.com> wrote:

> From: zhong jiang <zhongjiang@huawei.com>
> 
> In general, each process have 16kb stack space to use, but
> stack need extra space to store red_zone when kasan enable.
> the patch fix above question.

Thanks.  I grabbed this, but would prefer that the arm64 people handle
it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
