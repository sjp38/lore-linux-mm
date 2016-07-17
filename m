Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E4DD6B0253
	for <linux-mm@kvack.org>; Sat, 16 Jul 2016 20:07:13 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 63so297725574pfx.3
        for <linux-mm@kvack.org>; Sat, 16 Jul 2016 17:07:13 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id ro7si17772955pab.251.2016.07.16.17.07.10
        for <linux-mm@kvack.org>;
        Sat, 16 Jul 2016 17:07:12 -0700 (PDT)
Message-ID: <578ACD99.2070807@emindsoft.com.cn>
Date: Sun, 17 Jul 2016 08:13:13 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: gup: Re-define follow_page_mask output parameter
 page_mask usage
References: <1468084625-26999-1-git-send-email-chengang@emindsoft.com.cn> <20160711141702.fb1879707aa2bcb290133a43@linux-foundation.org> <578522CE.9060905@emindsoft.com.cn> <20160713075024.GB28723@dhcp22.suse.cz>
In-Reply-To: <20160713075024.GB28723@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, vbabka@suse.cz, kirill.shutemov@linux.intel.com, mingo@kernel.org, dave.hansen@linux.intel.com, dan.j.williams@intel.com, hannes@cmpxchg.org, jack@suse.cz, iamjoonsoo.kim@lge.com, jmarchan@redhat.com, dingel@linux.vnet.ibm.com, oleg@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chen Gang <gang.chen.5i5j@gmail.com>


On 7/13/16 15:50, Michal Hocko wrote:
> On Wed 13-07-16 01:03:10, Chen Gang wrote:
>> On 7/12/16 05:17, Andrew Morton wrote:
>>> On Sun, 10 Jul 2016 01:17:05 +0800 chengang@emindsoft.com.cn wrote:
>>>
>>>> For a pure output parameter:
>>>>
>>>>  - When callee fails, the caller should not assume the output parameter
>>>>    is still valid.
>>>>
>>>>  - And callee should not assume the pure output parameter must be
>>>>    provided by caller -- caller has right to pass NULL when caller does
>>>>    not care about it.
>>>
>>> Sorry, I don't think this one is worth merging really.
>>>
>>
>> OK, thanks, I can understand.
>>
>> It will be better if provide more details: e.g.
>>
>>  - This patch is incorrect, or the comments is not correct.
>>
>>  - The patch is worthless, at present.
> 
> I would say the patch is not really needed. The code you are touching
> works just fine and there is no reason to touch it unless this is a part
> of a larger change where future changes would be easier to
> review/implement.
> 

OK, thanks. I shall try to find other kinds of patches in linux/include,
next.  :-)

-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
