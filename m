Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id D41616B0032
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 22:53:26 -0400 (EDT)
Received: by igrv9 with SMTP id v9so3565314igr.1
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 19:53:26 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id a63si3957526ioe.50.2015.06.29.19.53.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 29 Jun 2015 19:53:26 -0700 (PDT)
Message-ID: <55920384.7030301@huawei.com>
Date: Tue, 30 Jun 2015 10:48:36 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: [RFC v2 PATCH 0/8] mm: mirrored memory support for page buddy
 allocations
References: <558E084A.60900@huawei.com> <559161EF.7050405@intel.com> <5591F042.1020304@huawei.com> <5591F64A.3040108@intel.com>
In-Reply-To: <5591F64A.3040108@intel.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, leon@leon.nu, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/6/30 9:52, Dave Hansen wrote:

> On 06/29/2015 06:26 PM, Xishi Qiu wrote:
>>>> Has there been any performance analysis done on this code?  I'm always
>>>> nervous when I see page_alloc.c churn.
>>>>
>> Not yet, which benchmark do you suggest?
> 
> mmtests is always a good place to start.  aim9.  I'm partial to
> will-it-scale.
> 

I see, thank you.

> 
> 
> .
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
