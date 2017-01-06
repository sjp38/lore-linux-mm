Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C72816B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 03:42:00 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c85so2316790wmi.6
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 00:42:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u30si525523wru.73.2017.01.06.00.41.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 00:41:59 -0800 (PST)
Subject: Re: [patch] mm, thp: add new background defrag option
References: <alpine.DEB.2.10.1701041532040.67903@chino.kir.corp.google.com>
 <20170105101330.bvhuglbbeudubgqb@techsingularity.net>
 <fe83f15e-2d9f-e36c-3a89-ce1a2b39e3ca@suse.cz>
 <alpine.DEB.2.10.1701051446140.19790@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <558ce85c-4cb4-8e56-6041-fc4bce2ee27f@suse.cz>
Date: Fri, 6 Jan 2017 09:41:57 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1701051446140.19790@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 01/05/2017 11:54 PM, David Rientjes wrote:
> On Thu, 5 Jan 2017, Vlastimil Babka wrote:
> 
>> Hmm that's probably why it's hard to understand, because "madvise
>> request" is just setting a vma flag, and the THP allocation (and defrag)
>> still happens at fault.
>>
>> I'm not a fan of either name, so I've tried to implement my own
>> suggestion. Turns out it was easier than expected, as there's no kernel
>> boot option for "defer", just for "enabled", so that particular worry
>> was unfounded.
>>
>> And personally I think that it's less confusing when one can enable defer
>> and madvise together (and not any other combination), than having to dig
>> up the difference between "defer" and "background".
>>
> 
> I think allowing only two options to be combined amongst four available 
> solo options is going to be confusing and then even more difficult for the 
> user to understand what happens when they are combined.  Thus, I think 

Well, the other options are named "always" and "never", so I wouldn't
think so confusing that they can't be combined with anything else.
Deciding between "defer" and "background" is however confusing, and also
doesn't indicate that the difference is related to madvise.

> these options should only have one settable mode as they have always done.
> 
> The kernel implementation takes less of a priority to userspace 
> simplicitly, imo, and my patch actually cleans up much of the existing 
> code and ends up adding fewer lines that yours.  I consider it an 
> improvement in itself.  I don't see the benefit of allowing combined 
> options.

I don't like bikesheding, but as this is about user-space API, more care
should be taken than for implementation details that can change. Even
though realistically there will be in 99% of cases only two groups of
users setting this
- experts like you who know what they are doing, and confusing names
won't prevent them from making the right choice
- people who will blindly copy/paste from the future cargo-cult websites
(if they ever get updated from the enabled="never" recommendations), who
likely won't stop and think about the other options.

Well, so we'll probably disagree, maybe others can add their opinions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
