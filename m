Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A86356B0005
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 22:38:08 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l4so42175973wml.0
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 19:38:08 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id w127si5844417wmg.118.2016.08.09.19.38.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 09 Aug 2016 19:38:07 -0700 (PDT)
Message-ID: <57AA936E.3080503@huawei.com>
Date: Wed, 10 Aug 2016 10:37:34 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: optimize find_zone_movable_pfns_for_nodes to avoid
 unnecessary loop.
References: <1470405847-53322-1-git-send-email-zhongjiang@huawei.com> <20160809162919.266e58ca0c33896dcf417a02@linux-foundation.org>
In-Reply-To: <20160809162919.266e58ca0c33896dcf417a02@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2016/8/10 7:29, Andrew Morton wrote:
> On Fri, 5 Aug 2016 22:04:07 +0800 zhongjiang <zhongjiang@huawei.com> wrote:
>
>> when required_kernelcore decrease to zero, we should exit the loop in time.
>> because It will waste time to scan the remainder node.
> The patch is rather ugly and it only affects __init code, so the only
> benefit will be to boot time.
   yes
> Do we have any timing measurements which would justify changing this code?
  I am sorry for that.  That is a only theoretical analysis.
>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
