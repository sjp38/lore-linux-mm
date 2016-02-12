Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0A6356B0009
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 13:25:29 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id xk3so132617067obc.2
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 10:25:29 -0800 (PST)
Received: from rcdn-iport-1.cisco.com (rcdn-iport-1.cisco.com. [173.37.86.72])
        by mx.google.com with ESMTPS id h8si16600199oeq.23.2016.02.12.10.25.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Feb 2016 10:25:28 -0800 (PST)
Subject: Re: computing drop-able caches
References: <56AAA77D.7090000@cisco.com> <56BE1F2A.30103@intel.com>
 <56BE2135.5040407@cisco.com> <56BE21EC.6030708@intel.com>
From: Daniel Walker <danielwa@cisco.com>
Message-ID: <56BE2396.30801@cisco.com>
Date: Fri, 12 Feb 2016 10:25:26 -0800
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

I understand you want to see it, and we will release it (sometime today) 
.. But the code is not sophisticated, it just counts the caches which 
would be dropped reusing much of fs/drop_caches.c .

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
