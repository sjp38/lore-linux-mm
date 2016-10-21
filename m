Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE646B0069
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 03:31:47 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id f134so21636126lfg.6
        for <linux-mm@kvack.org>; Fri, 21 Oct 2016 00:31:47 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r187si2418511wmr.28.2016.10.21.00.31.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 21 Oct 2016 00:31:46 -0700 (PDT)
Subject: Re: [RFC] fs/proc/meminfo: introduce Unaccounted statistic
References: <20161020121149.9935-1-vbabka@suse.cz>
 <20161020133358.GN14609@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <fa571a7a-c833-e639-536e-3f87ad752924@suse.cz>
Date: Fri, 21 Oct 2016 09:31:44 +0200
MIME-Version: 1.0
In-Reply-To: <20161020133358.GN14609@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>

On 10/20/2016 03:33 PM, Michal Hocko wrote:
> On Thu 20-10-16 14:11:49, Vlastimil Babka wrote:
> [...]
>> Hi, I'm wondering if people would find this useful. If you think it is, and
>> to not make performance worse, I could also make sure in proper submission
>> that values are not read via global_page_state() multiple times etc...
>
> I definitely find this information useful and hate to do the math all
> the time but on the other hand this is quite fragile and I can imagine
> we can easily forget to add something there and provide a misleading
> information to the userspace. So I would be worried with a long term
> maintainability of this.

I wouldn't fear this that much. Maybe even on the contrary - if we unknowingly 
change the picture by misacounting something, or changing a counter to become 
subset of another, and Unaccounted starts to give weird values, it will give us 
hint that there's either a problem to fix, or a missed documentation update.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
