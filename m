Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id 3FED86B0253
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 15:15:40 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id gc3so36320814obb.3
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 12:15:40 -0800 (PST)
Received: from alln-iport-4.cisco.com (alln-iport-4.cisco.com. [173.37.142.91])
        by mx.google.com with ESMTPS id fj9si17170807oeb.7.2016.02.12.12.15.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Feb 2016 12:15:39 -0800 (PST)
Subject: Re: computing drop-able caches
References: <56AAA77D.7090000@cisco.com> <56BE1F2A.30103@intel.com>
 <56BE2135.5040407@cisco.com> <56BE21EC.6030708@intel.com>
From: Daniel Walker <danielwa@cisco.com>
Message-ID: <56BE3D69.7080305@cisco.com>
Date: Fri, 12 Feb 2016 12:15:37 -0800
MIME-Version: 1.0
In-Reply-To: <56BE21EC.6030708@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Khalid Mughal (khalidm)" <khalidm@cisco.com>, "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>

On 02/12/2016 10:18 AM, Dave Hansen wrote:
> On 02/12/2016 10:15 AM, Daniel Walker wrote:
>> On 02/12/2016 10:06 AM, Dave Hansen wrote:
>>> On 01/28/2016 03:42 PM, Daniel Walker wrote:
>>>> My colleague Khalid and I are working on a patch which will provide a
>>>> /proc file to output the size of the drop-able page cache.
>>>> One way to implement this is to use the current drop_caches /proc
>>>> routine, but instead of actually droping the caches just add
>>>> up the amount.
>>> Code, please.
>> We have a process for release code which doesn't allow us to send it
>> immediately. B
> OK, how about we continue this discussion once you can release it?

Ok, you should have the code now."kernel: fs: drop_caches: add dds 
drop_caches_count"

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
