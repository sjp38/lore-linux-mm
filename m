Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0D20E6B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 17:13:40 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id ho8so40165740pac.2
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 14:13:40 -0800 (PST)
Received: from us-alimail-mta1.hst.scl.en.alidc.net (mail113-250.mail.alibaba.com. [205.204.113.250])
        by mx.google.com with ESMTP id am4si14974964pad.172.2016.02.25.14.13.36
        for <linux-mm@kvack.org>;
        Thu, 25 Feb 2016 14:13:37 -0800 (PST)
Message-ID: <56CF7D5D.1020609@emindsoft.com.cn>
Date: Fri, 26 Feb 2016 06:17:01 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
References: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn> <20160225085719.GA17573@dhcp22.suse.cz> <56CF0E6A.2090204@emindsoft.com.cn> <20160225144718.GD4204@dhcp22.suse.cz>
In-Reply-To: <20160225144718.GD4204@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: trivial@kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vdavydov@virtuozzo.com, dan.j.williams@intel.com, linux-mm@kvack.org


On 2/25/16 22:47, Michal Hocko wrote:
>>
>> For the "comment placement" the common way is below, but still make git
>> grep harder:
> 
> if you did git grep ZONE_MOVABLE you would get less information
> 

OK.

>>
>> -#define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE)  /* ZONE_MOVABLE allowed */
>> +/* ZONE_MOVABLE allowed */
>> +#define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE)
>>
>> Then how about:
>>
>> -#define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE)  /* ZONE_MOVABLE allowed */
>> +#define __GFP_MOVABLE	\
>> 		((__force gfp_t)___GFP_MOVABLE) /* ZONE_MOVABLE allowed */
>>
>> or:
>>
>> -#define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE)  /* ZONE_MOVABLE allowed */
>> +#define __GFP_MOVABLE	/* ZONE_MOVABLE allowed */ \
>> 			((__force gfp_t)___GFP_MOVABLE)
> 
> Now looks worse then other, really. Please try to think what would be
> a benefit of such change. As Mel already pointed out git blame would
> take an additional step to get back to the patch which has introduced
> them. And what is the advantage? Make 80 characters-per-line rule happy?
> I just do not think this is worth changes at all.
> 

For 80 column limitation:

 - I often use vsp (vertical split window) in vim to reading code in the
   2 files, 80 columns limitation can avoid the line wrap, which will
   let code reading better.

 - Sometimes we need copy/past the code to a pdf files (e.g. print the
   interface header file contents to a new document as appendix), or
   print the code to a physical paper (e.g. write a book).

For worth or worthless:

  The shared header files (e.g. in our case), have more chances to be
  read or printed than the normal source code files. So for me, we need
  take more care about the coding styles of them.

For git-blame:

 - It really a good feature! Originally, I did not know about it :-).

 - Can it instead of sending trivial patch? (I guess not).


Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
