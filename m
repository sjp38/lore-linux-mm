Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EE6F66B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 01:19:54 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p2so28880508pfk.0
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 22:19:54 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id s61si8227260plb.658.2017.10.09.22.19.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 22:19:53 -0700 (PDT)
Subject: Re: [PATCH v2] mm/page_alloc.c: inline __rmqueue()
References: <20171009054434.GA1798@intel.com>
 <3a46edcf-88f8-e4f4-8b15-3c02620308e4@intel.com>
 <20171010025151.GD1798@intel.com> <20171010025601.GE1798@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <8d6a98d3-764e-fd41-59dc-88a9d21822c7@intel.com>
Date: Mon, 9 Oct 2017 22:19:52 -0700
MIME-Version: 1.0
In-Reply-To: <20171010025601.GE1798@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

On 10/09/2017 07:56 PM, Aaron Lu wrote:
> This patch adds inline to __rmqueue() and vmlinux' size doesn't have any
> change after this patch according to size(1).
> 
> without this patch:
>    text    data     bss     dec     hex     filename
> 9968576 5793372 17715200  33477148  1fed21c vmlinux
> 
> with this patch:
>    text    data     bss     dec     hex     filename
> 9968576 5793372 17715200  33477148  1fed21c vmlinux

This is unexpected.  Could you double-check this, please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
