Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E28F6B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 12:57:11 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id m101so45840555ioi.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 09:57:11 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id n188si12587480ite.54.2016.07.12.09.57.08
        for <linux-mm@kvack.org>;
        Tue, 12 Jul 2016 09:57:09 -0700 (PDT)
Message-ID: <578522CE.9060905@emindsoft.com.cn>
Date: Wed, 13 Jul 2016 01:03:10 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: gup: Re-define follow_page_mask output parameter
 page_mask usage
References: <1468084625-26999-1-git-send-email-chengang@emindsoft.com.cn> <20160711141702.fb1879707aa2bcb290133a43@linux-foundation.org>
In-Reply-To: <20160711141702.fb1879707aa2bcb290133a43@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: vbabka@suse.cz, mhocko@suse.com, kirill.shutemov@linux.intel.com, mingo@kernel.org, dave.hansen@linux.intel.com, dan.j.williams@intel.com, hannes@cmpxchg.org, jack@suse.cz, iamjoonsoo.kim@lge.com, jmarchan@redhat.com, dingel@linux.vnet.ibm.com, oleg@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <gang.chen.5i5j@gmail.com>

On 7/12/16 05:17, Andrew Morton wrote:
> On Sun, 10 Jul 2016 01:17:05 +0800 chengang@emindsoft.com.cn wrote:
> 
>> For a pure output parameter:
>>
>>  - When callee fails, the caller should not assume the output parameter
>>    is still valid.
>>
>>  - And callee should not assume the pure output parameter must be
>>    provided by caller -- caller has right to pass NULL when caller does
>>    not care about it.
> 
> Sorry, I don't think this one is worth merging really.
> 

OK, thanks, I can understand.

It will be better if provide more details: e.g.

 - This patch is incorrect, or the comments is not correct.

 - The patch is worthless, at present.

 - ...

By the way, this patch let the callee keep the output parameter no touch
if callee no additional outputs, callee assumes caller has initialized
the output parameter (for me, it is OK, there are many cases like this).

Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
