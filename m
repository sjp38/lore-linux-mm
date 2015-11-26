Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id B18D66B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 05:39:11 -0500 (EST)
Received: by wmec201 with SMTP id c201so16739537wme.1
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 02:39:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b83si2618211wme.104.2015.11.26.02.39.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 26 Nov 2015 02:39:10 -0800 (PST)
Subject: Re: [PATCH v2 5/9] mm, page_owner: track and print last migrate
 reason
References: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
 <1448368581-6923-6-git-send-email-vbabka@suse.cz>
 <20151125081323.GB10494@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5656E14A.1020508@suse.cz>
Date: Thu, 26 Nov 2015 11:39:06 +0100
MIME-Version: 1.0
In-Reply-To: <20151125081323.GB10494@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

On 11/25/2015 09:13 AM, Joonsoo Kim wrote:
>> +	if (page_ext->last_migrate_reason != -1) {
>> +		ret += snprintf(kbuf + ret, count - ret,
>> +			"Page has been migrated, last migrate reason: %s\n",
>> +			migrate_reason_names[page_ext->last_migrate_reason]);
>> +		if (ret >= count)
>> +			goto err;
>> +	}
>> +
> 
> migrate_reason_names is defined if CONFIG_MIGRATION is enabled so
> it would cause build failure in case of !CONFIG_MIGRATION and
> CONFIG_PAGE_OWNER.
> 
> Thanks.

Ugh right, linking gives warnings... Thanks.
I think instead of adding #ifdefs here, let's move migrate_reason_names to
mm/debug.c as we gradually do with these things. Also enum
migrate_reason is defined regardless of CONFIG_MIGRATION, so match that
for migrate_reason_names as well.

------8<------
