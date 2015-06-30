Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 717686B0032
	for <linux-mm@kvack.org>; Mon, 29 Jun 2015 21:52:13 -0400 (EDT)
Received: by pdbci14 with SMTP id ci14so126346236pdb.2
        for <linux-mm@kvack.org>; Mon, 29 Jun 2015 18:52:13 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id fh4si67307884pdb.61.2015.06.29.18.52.12
        for <linux-mm@kvack.org>;
        Mon, 29 Jun 2015 18:52:12 -0700 (PDT)
Message-ID: <5591F64A.3040108@intel.com>
Date: Mon, 29 Jun 2015 18:52:10 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC v2 PATCH 0/8] mm: mirrored memory support for page buddy
 allocations
References: <558E084A.60900@huawei.com> <559161EF.7050405@intel.com> <5591F042.1020304@huawei.com>
In-Reply-To: <5591F042.1020304@huawei.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, "Luck, Tony" <tony.luck@intel.com>, Hanjun Guo <guohanjun@huawei.com>, Xiexiuqi <xiexiuqi@huawei.com>, leon@leon.nu, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 06/29/2015 06:26 PM, Xishi Qiu wrote:
>> > Has there been any performance analysis done on this code?  I'm always
>> > nervous when I see page_alloc.c churn.
>> > 
> Not yet, which benchmark do you suggest?

mmtests is always a good place to start.  aim9.  I'm partial to
will-it-scale.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
