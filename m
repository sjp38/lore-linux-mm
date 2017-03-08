Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 49B7D6B03BD
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 02:51:27 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id g8so8650323wmg.7
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 23:51:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x61si3223145wrb.294.2017.03.07.23.51.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 23:51:25 -0800 (PST)
Subject: Re: [PATCH] mm: Do not use double negation for testing page flags
References: <1488868597-32222-1-git-send-email-minchan@kernel.org>
 <8b5c4679-484e-fe7f-844b-af5fd41b01e0@linux.vnet.ibm.com>
 <20170308052555.GB11206@bbox>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6f9274f7-6d2e-60a6-c36a-78f8f79004aa@suse.cz>
Date: Wed, 8 Mar 2017 08:51:23 +0100
MIME-Version: 1.0
In-Reply-To: <20170308052555.GB11206@bbox>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Chen Gang <gang.chen.5i5j@gmail.com>

On 03/08/2017 06:25 AM, Minchan Kim wrote:
> Hi Anshuman,
> 
> On Tue, Mar 07, 2017 at 09:31:18PM +0530, Anshuman Khandual wrote:
>> On 03/07/2017 12:06 PM, Minchan Kim wrote:
>>> With the discussion[1], I found it seems there are every PageFlags
>>> functions return bool at this moment so we don't need double
>>> negation any more.
>>> Although it's not a problem to keep it, it makes future users
>>> confused to use dobule negation for them, too.
>>>
>>> Remove such possibility.
>>
>> A quick search of '!!Page' in the source tree does not show any other
>> place having this double negation. So I guess this is all which need
>> to be fixed.
> 
> Yeb. That's the why my patch includes only khugepagd part but my
> concern is PageFlags returns int type not boolean so user might
> be confused easily and tempted to use dobule negation.
> 
> Other side is they who create new custom PageXXX(e.g., PageMovable)
> should keep it in mind that they should return 0 or 1 although
> fucntion prototype's return value is int type.

> It shouldn't be
> documented nowhere.

Was this double negation intentional? :P

> Although we can add a little description
> somewhere in page-flags.h, I believe changing to boolean is more
> clear/not-error-prone so Chen's work is enough worth, I think.

Agree, unless some arches benefit from the int by performance
for some reason (no idea if it's possible).

Anyway, to your original patch:

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
