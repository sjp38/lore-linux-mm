Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C3AC26B025E
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 08:50:16 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id k184so42056788wme.3
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 05:50:16 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id jr7si11867508wjb.186.2016.06.17.05.50.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 05:50:15 -0700 (PDT)
Subject: Re: [PATCH] mm/compaction: remove local variable is_lru
References: <1466155971-6280-1-git-send-email-opensource.ganesh@gmail.com>
 <20160617095030.GB21670@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <fbcd77c3-b192-3415-8417-6c8b07ce2146@suse.cz>
Date: Fri, 17 Jun 2016 14:50:12 +0200
MIME-Version: 1.0
In-Reply-To: <20160617095030.GB21670@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, hillf.zj@alibaba-inc.com, minchan@kernel.org

On 06/17/2016 11:50 AM, Michal Hocko wrote:
> On Fri 17-06-16 17:32:51, Ganesh Mahendran wrote:
>> local varialbe is_lru was used for tracking non-lru pages(such as
>> balloon pages).
>>
>> But commit
>> 112ea7b668d3 ("mm: migrate: support non-lru movable page migration")
>
> this commit sha is not stable because it is from the linux-next tree.
>
>> introduced a common framework for non-lru page migration and moved
>> the compound pages check before non-lru movable pages check.
>>
>> So there is no need to use local variable is_lru.
>>
>> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
>
> Other than that the patch looks ok and maybe it would be worth folding
> into the mm-migrate-support-non-lru-movable-page-migration.patch

Agreed.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
