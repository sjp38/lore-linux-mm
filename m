Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1343B6B025E
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 19:49:33 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ts6so38617731pac.1
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 16:49:33 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i186si2805306pfe.3.2016.06.23.16.49.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jun 2016 16:49:32 -0700 (PDT)
Date: Thu, 23 Jun 2016 16:49:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ksm: set anon_vma of first rmap_item of ksm page to
 page's anon_vma other than vma's anon_vma
Message-Id: <20160623164931.da352f7e6f4b115aba13f37e@linux-foundation.org>
In-Reply-To: <1466688834-127613-1-git-send-email-zhouxianrong@huawei.com>
References: <1466688834-127613-1-git-send-email-zhouxianrong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong@huawei.com
Cc: linux-mm@kvack.org, hughd@google.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, zhouchengming1@huawei.com, geliangtang@163.com, linux-kernel@vger.kernel.org, zhouxiyu@huawei.com, wanghaijun5@huawei.com

On Thu, 23 Jun 2016 21:33:54 +0800 <zhouxianrong@huawei.com> wrote:

> From: z00281421 <z00281421@notesmail.huawei.com>
> 
> set anon_vma of first rmap_item of ksm page to page's anon_vma
> other than vma's anon_vma so that we can lookup all the forked
> vma of kpage via reserve map. thus we can try_to_unmap ksm page
> completely and reclaim or migrate the ksm page successfully and
> need not to merg other forked vma addresses of ksm page with
> building a rmap_item for it ever after.
> 
> a forked more mapcount ksm page with partially merged vma addresses and
> a ksm page mapped into non-VM_MERGEABLE vma due to setting MADV_MERGEABLE
> on one of the forked vma can be unmapped completely by try_to_unmap.
> 

hm, OK, so this is an efficiency increase rather than a functional
change?

If so, are you able to quantify the benefit?  ie, how much faster did
things get?

I'll queue it up and shall await Hugh review (please).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
