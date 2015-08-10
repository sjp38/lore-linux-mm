Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id BFAAA6B0253
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 05:54:20 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so17920460wic.1
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 02:54:20 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d4si36606690wjn.153.2015.08.10.02.54.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Aug 2015 02:54:19 -0700 (PDT)
Subject: Re: [RFC v3 2/2] mm, compaction: make kcompactd rely on
 sysctl_extfrag_threshold
References: <1438619141-22215-2-git-send-email-vbabka@suse.cz>
 <166622926.1247366.1439140873216.JavaMail.yahoo@mail.yahoo.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55C874C9.4050803@suse.cz>
Date: Mon, 10 Aug 2015 11:54:17 +0200
MIME-Version: 1.0
In-Reply-To: <166622926.1247366.1439140873216.JavaMail.yahoo@mail.yahoo.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu_agarwal@yahoo.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pintu Kumar <pintu.k@samsung.com>

On 08/09/2015 07:21 PM, PINTU KUMAR wrote:
>>
>> -extern int fragmentation_index(struct zone *zone, unsigned int order);
>> +extern int fragmentation_index(struct zone *zone, unsigned int order,
>
>> +                            bool ignore_suitable);
>
> We would like to retain the original fragmentation_index as it is.
> Because in some cases people may be using it without kcompactd.
> In such cases, future kernel upgrades will suffer.
> In my opinion fragmentation_index should work just based on zones and order.

I don't understand the concern. If you pass 'false' to ignore_suitable, 
you get the standard behavior. Only kcompactd uses the altered behavior.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
