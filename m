Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id F41556B0009
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 18:12:26 -0500 (EST)
Received: by mail-pf0-f181.google.com with SMTP id e127so40647043pfe.3
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 15:12:26 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id sm4si15256551pac.245.2016.02.25.15.12.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 15:12:26 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id q63so325432pfb.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 15:12:26 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Date: Fri, 26 Feb 2016 08:12:19 +0900 (KST)
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
In-Reply-To: <56CF8043.1030603@emindsoft.com.cn>
Message-ID: <alpine.DEB.2.10.1602260806380.16296@hxeon>
References: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn> <20160225092752.GU2854@techsingularity.net> <56CF1202.2020809@emindsoft.com.cn> <20160225160707.GX2854@techsingularity.net> <56CF8043.1030603@emindsoft.com.cn>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="781441777-1775379704-1456441944=:16296"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <chengang@emindsoft.com.cn>
Cc: Mel Gorman <mgorman@techsingularity.net>, trivial@kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-kernel@vger.kernel.org, mhocko@suse.cz, hannes@cmpxchg.org, vdavydov@virtuozzo.com, dan.j.williams@intel.com, linux-mm@kvack.org, Chen Gang <gang.chen.5i5j@gmail.com>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--781441777-1775379704-1456441944=:16296
Content-Type: TEXT/PLAIN; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8BIT



On Fri, 26 Feb 2016, Chen Gang wrote:

> On 2/26/16 00:07, Mel Gorman wrote:
>>>> On Thu, Feb 25, 2016 at 06:26:31AM +0800, chengang@emindsoft.com.cn wrote:
>>
>> I do not want this patch to go through the trivial tree. It still adds
>> another step to identifying relevant commits through git blame and has
>> limited, if any, benefit to maintainability.
>>
>>>   "it's preferable to preserve blame than go through a layer of cleanup
>>>   when looking for the commit that defined particular flags".
>>>
>>
>> git blame identifies what commit last altered a line. If a cleanup patch
>> is encountered then the tree before that commit needs to be examined
>> which adds time. It's rare that cleanup patches on their own are useful
>> and this is one of those cases.
>>
>
> git is a tool mainly for analyzing code, but not mainly for normal
> reading main code.
>
> So for me, the coding styles need not consider about git.


It is common to see reject of trivial coding style fixup patch here and
there.  Those patches usually be merged for early stage files that only
few people read / write.  However, for files that are old and lots of
people read and write, those patches are rejected in usual.  I mean, the
negative opinions for this patches are usual in this community.

I agree that coding style is important and respect your effort.  However,
because the code will be seen and written by most kernel hackers, the file
should be maintained to be easily readable and writable by most kernel
hackers, especially, maintainers.  What I want to say is, we should
respect maintainers' opinion in usual.

As far as I remember, I have seen a document that saying same with others'
opinion but couldn't find it.


Thanks,
SeongJae Park

>
>
> Thanks.
> -- 
> Chen Gang (e??a??)
>
> Managing Natural Environments is the Duty of Human Beings.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
--781441777-1775379704-1456441944=:16296--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
