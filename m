Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id CEB1A6B0253
	for <linux-mm@kvack.org>; Thu, 28 Jan 2016 20:03:55 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id is5so50949807obc.0
        for <linux-mm@kvack.org>; Thu, 28 Jan 2016 17:03:55 -0800 (PST)
Received: from alln-iport-3.cisco.com (alln-iport-3.cisco.com. [173.37.142.90])
        by mx.google.com with ESMTPS id o9si11765136oih.126.2016.01.28.17.03.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Jan 2016 17:03:55 -0800 (PST)
Subject: Re: computing drop-able caches
References: <56AAA77D.7090000@cisco.com> <20160128235815.GA5953@cmpxchg.org>
From: Daniel Walker <danielwa@cisco.com>
Message-ID: <56AABA79.3030103@cisco.com>
Date: Thu, 28 Jan 2016 17:03:53 -0800
MIME-Version: 1.0
In-Reply-To: <20160128235815.GA5953@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Khalid Mughal (khalidm)" <khalidm@cisco.com>, "xe-kernel@external.cisco.com" <xe-kernel@external.cisco.com>, Rik van Riel <riel@redhat.com>

On 01/28/2016 03:58 PM, Johannes Weiner wrote:
> On Thu, Jan 28, 2016 at 03:42:53PM -0800, Daniel Walker wrote:
>> "Currently there is no way to figure out the droppable pagecache size
>> from the meminfo output. The MemFree size can shrink during normal
>> system operation, when some of the memory pages get cached and is
>> reflected in "Cached" field. Similarly for file operations some of
>> the buffer memory gets cached and it is reflected in "Buffers" field.
>> The kernel automatically reclaims all this cached & buffered memory,
>> when it is needed elsewhere on the system. The only way to manually
>> reclaim this memory is by writing 1 to /proc/sys/vm/drop_caches. "
> [...]
>
>> The point of the whole exercise is to get a better idea of free memory for
>> our employer. Does it make sense to do this for computing free memory?
> /proc/meminfo::MemAvailable was added for this purpose. See the doc
> text in Documentation/filesystem/proc.txt.
>
> It's an approximation, however, because this question is not easy to
> answer. Pages might be in various states and uses that can make them
> unreclaimable.


Khalid was telling me that our internal sources rejected MemAvailable 
because it was not accurate enough. It says in the description,
"The estimate takes into account that the system needs some page cache 
to function well". I suspect that's part of the inaccuracy. I asked 
Khalid to respond with more details on this.

Do you know of any work to make it more accurate?

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
