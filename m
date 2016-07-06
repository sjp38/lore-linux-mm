Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 03511828E1
	for <linux-mm@kvack.org>; Wed,  6 Jul 2016 05:26:25 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ts6so446823729pac.1
        for <linux-mm@kvack.org>; Wed, 06 Jul 2016 02:26:24 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id uk2si3253935pab.226.2016.07.06.02.26.22
        for <linux-mm@kvack.org>;
        Wed, 06 Jul 2016 02:26:24 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <014201d1d738$744c8f90$5ce5aeb0$@alibaba-inc.com>	<014601d1d73b$5a3c0420$0eb40c60$@alibaba-inc.com>	<20160706082350.5c56ca40@mschwide>	<015301d1d751$8973de50$9c5b9af0$@alibaba-inc.com> <20160706104753.74daeaa2@mschwide>
In-Reply-To: <20160706104753.74daeaa2@mschwide>
Subject: Re: [PATCH 2/2] s390/mm: use ipte range to invalidate multiple page table entries
Date: Wed, 06 Jul 2016 17:26:08 +0800
Message-ID: <015d01d1d768$6db5d9e0$49218da0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Martin Schwidefsky' <schwidefsky@de.ibm.com>
Cc: 'linux-kernel' <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> 
> You are still a bit cryptic, 
>
Sorry, Sir, simply because I'm not native English speaker.

> are you trying to tell me that your hint is
> about trying to avoid the preempt_enable() call?
> 
Yes, since we are already in the context with page table lock held.

thanks
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
