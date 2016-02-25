Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1FA5B6B0255
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 09:20:11 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id hb3so13805355igb.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 06:20:11 -0800 (PST)
Received: from out1134-233.mail.aliyun.com (out1134-233.mail.aliyun.com. [42.120.134.233])
        by mx.google.com with ESMTP id 78si10690162ior.54.2016.02.25.06.20.09
        for <linux-mm@kvack.org>;
        Thu, 25 Feb 2016 06:20:10 -0800 (PST)
Message-ID: <56CF0E6A.2090204@emindsoft.com.cn>
Date: Thu, 25 Feb 2016 22:23:38 +0800
From: Chen Gang <chengang@emindsoft.com.cn>
MIME-Version: 1.0
Subject: Re: [PATCH trivial] include/linux/gfp.h: Improve the coding styles
References: <1456352791-2363-1-git-send-email-chengang@emindsoft.com.cn> <20160225085719.GA17573@dhcp22.suse.cz>
In-Reply-To: <20160225085719.GA17573@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: trivial@kernel.org, akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-kernel@vger.kernel.org, hannes@cmpxchg.org, mgorman@techsingularity.net, vdavydov@virtuozzo.com, dan.j.williams@intel.com, linux-mm@kvack.org

On 2/25/16 16:57, Michal Hocko wrote:
> On Thu 25-02-16 06:26:31, chengang@emindsoft.com.cn wrote:
>>
>> Always notice about 80 columns, and the white space near '|'.
>>
>> Let the wrapped function parameters align as the same styles.
>>
>> Remove redundant statement "enum zone_type z;" in function gfp_zone.
> 
> I do not think this is an improvement. The comment placement is just odd
> and artificially splitting the mask into more lines makes git grep
> harder to use.
> 

Excuse me, I am not quite sure your meaning is the whole contents of the
patch is worthless, or only for the "comment placement"?

For the "comment placement" the common way is below, but still make git
grep harder:

-#define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE)  /* ZONE_MOVABLE allowed */
+/* ZONE_MOVABLE allowed */
+#define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE)

Then how about:

-#define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE)  /* ZONE_MOVABLE allowed */
+#define __GFP_MOVABLE	\
		((__force gfp_t)___GFP_MOVABLE) /* ZONE_MOVABLE allowed */

or:

-#define __GFP_MOVABLE	((__force gfp_t)___GFP_MOVABLE)  /* ZONE_MOVABLE allowed */
+#define __GFP_MOVABLE	/* ZONE_MOVABLE allowed */ \
			((__force gfp_t)___GFP_MOVABLE)


Thanks.
-- 
Chen Gang (e??a??)

Managing Natural Environments is the Duty of Human Beings.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
