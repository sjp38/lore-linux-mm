Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CFF756B0253
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 04:26:38 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id d140so1874529wmd.4
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 01:26:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 6si28452397wrp.137.2017.01.18.01.26.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 Jan 2017 01:26:37 -0800 (PST)
Subject: Re: [RFC 3/4] mm, page_alloc: move cpuset seqcount checking to
 slowpath
References: <20170117221610.22505-1-vbabka@suse.cz>
 <20170117221610.22505-4-vbabka@suse.cz>
 <036f01d2715b$97827e80$c6877b80$@alibaba-inc.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <372726f9-3bc9-217f-3bf5-c40d3e52a6b6@suse.cz>
Date: Wed, 18 Jan 2017 10:26:34 +0100
MIME-Version: 1.0
In-Reply-To: <036f01d2715b$97827e80$c6877b80$@alibaba-inc.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>, 'Mel Gorman' <mgorman@techsingularity.net>, 'Ganapatrao Kulkarni' <gpkulkarni@gmail.com>
Cc: 'Michal Hocko' <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 01/18/2017 08:22 AM, Hillf Danton wrote:
> On Wednesday, January 18, 2017 6:16 AM Vlastimil Babka wrote:
>>
>> This is a preparation for the following patch to make review simpler. While
>> the primary motivation is a bug fix, this could also save some cycles in the
>> fast path.
>>
> This also gets kswapd involved.
> Dunno how frequent cpuset is changed in real life.

I don't think the extra kswapd wakeups due to retry_cpuset would be noticeable. 
Such frequent cpuset changes would likely have their own associated overhead 
larger than the wakeups.

>
> Hillf
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
