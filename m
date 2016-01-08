Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id BF46D828DE
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 06:34:34 -0500 (EST)
Received: by mail-wm0-f45.google.com with SMTP id f206so132529128wmf.0
        for <linux-mm@kvack.org>; Fri, 08 Jan 2016 03:34:34 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l191si27045974wmg.78.2016.01.08.03.34.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 08 Jan 2016 03:34:33 -0800 (PST)
Subject: Re: [PATCH v2 9/9] mm, oom: print symbolic gfp_flags in oom warning
References: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
 <1448368581-6923-10-git-send-email-vbabka@suse.cz>
 <alpine.DEB.2.10.1601071327490.20990@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <568F9EC6.8070708@suse.cz>
Date: Fri, 8 Jan 2016 12:34:30 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1601071327490.20990@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>

On 01/07/2016 10:29 PM, David Rientjes wrote:
> On Tue, 24 Nov 2015, Vlastimil Babka wrote:
>
>> It would be useful to translate gfp_flags into string representation when
>> printing in case of an OOM, especially as the flags have been undergoing some
>> changes recently and the script ./scripts/gfp-translate needs a matching source
>> version to be accurate.
>>
>> Example output:
>>
>> a.out invoked oom-killer: order=0, oom_score_adj=0, gfp_mask=0x24280ca(GFP_HIGHUSER_MOVABLE|GFP_ZERO)
>>
>
> Is there a way that we can keep the order of the fields so that anything
> parsing the kernel log for oom kills doesn't break?

Yes, this is possible with the new printk handling of flags, please look 
at v3:
http://marc.info/?l=linux-mm&m=145042944710510&w=2

There I changed the print just to have order first and gfp_mask next, as 
it seemed more logical. But it doesn't need to be that way and I can 
post V4 keeping the original order of variables. But do you think the 
flags expansion is safe to add there, or should I put it on separate line?

Thanks

> The messages printed
> to the kernel log are the only (current) way to determine that the kernel
> killed something so we should be careful not to break anything parsing
> them, and this is a common line to look for.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
