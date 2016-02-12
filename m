Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 78FFE6B0009
	for <linux-mm@kvack.org>; Fri, 12 Feb 2016 13:15:19 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id wb13so133533946obb.1
        for <linux-mm@kvack.org>; Fri, 12 Feb 2016 10:15:19 -0800 (PST)
Received: from rcdn-iport-5.cisco.com (rcdn-iport-5.cisco.com. [173.37.86.76])
        by mx.google.com with ESMTPS id g3si16580299obr.44.2016.02.12.10.15.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Feb 2016 10:15:18 -0800 (PST)
Subject: Re: computing drop-able caches
References: <56AAA77D.7090000@cisco.com> <56BE1F2A.30103@intel.com>
From: Daniel Walker <danielwa@cisco.com>
Message-ID: <56BE2135.5040407@cisco.com>
Date: Fri, 12 Feb 2016 10:15:17 -0800
MIME-Version: 1.0
In-Reply-To: <56BE1F2A.30103@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Khalid Mughal (khalidm)" <khalidm@cisco.com>, "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>

On 02/12/2016 10:06 AM, Dave Hansen wrote:
> On 01/28/2016 03:42 PM, Daniel Walker wrote:
>> My colleague Khalid and I are working on a patch which will provide a
>> /proc file to output the size of the drop-able page cache.
>> One way to implement this is to use the current drop_caches /proc
>> routine, but instead of actually droping the caches just add
>> up the amount.
> Code, please.

We have a process for release code which doesn't allow us to send it 
immediately. B

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
