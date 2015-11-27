Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 8DD5C6B0038
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 11:40:44 -0500 (EST)
Received: by wmvv187 with SMTP id v187so77787986wmv.1
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 08:40:44 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t7si11513177wmf.42.2015.11.27.08.40.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 27 Nov 2015 08:40:43 -0800 (PST)
Subject: Re: [PATCH] mm: Allow GFP_IOFS for page_cache_read page cache
 allocation
References: <1447251233-14449-1-git-send-email-mhocko@kernel.org>
 <20151112095301.GA25265@quack.suse.cz> <20151126150820.GI7953@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56588789.1010300@suse.cz>
Date: Fri, 27 Nov 2015 17:40:41 +0100
MIME-Version: 1.0
In-Reply-To: <20151126150820.GI7953@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, Mark Fasheh <mfasheh@suse.com>, ocfs2-devel@oss.oracle.com, ceph-devel@vger.kernel.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On 11/26/2015 04:08 PM, Michal Hocko wrote:
> On Thu 12-11-15 10:53:01, Jan Kara wrote:
>> On Wed 11-11-15 15:13:53, mhocko@kernel.org wrote:
>>>
>>> Hi,
>>> this has been posted previously as a part of larger GFP_NOFS related
>>> patch set (http://lkml.kernel.org/r/1438768284-30927-1-git-send-email-mhocko%40kernel.org)
>>> but I think it makes sense to discuss it even out of that scope.
>>>
>>> I would like to hear FS and other MM people about the proposed interface.
>>> Using mapping_gfp_mask blindly doesn't sound good to me and vm_fault
>>> looks like a proper channel to communicate between MM and FS layers.
>>>
>>> Comments? Are there any better ideas?
>>
>> Makes sense to me and the filesystems I know should be fine with this
>> (famous last words ;). Feel free to add:
>>
>> Acked-by: Jan Kara <jack@suse.com>
>
> Thanks a lot! Are there any objections from other fs/mm people?

Please replace "GFP_IOFS" in the subject, as the "flag" has been removed 
recently. Otherwise

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
