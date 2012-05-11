Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 7A5BA8D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 04:38:26 -0400 (EDT)
Message-ID: <4FACD00D.4060003@kernel.org>
Date: Fri, 11 May 2012 17:38:37 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: raise MemFree by reverting percpu_pagelist_fraction
 to 0
References: <alpine.LSU.2.00.1205110054520.2801@eggly.anvils> <CA+1xoqcChazS=TRt6-7GjJAzQNFLFXmO623rWwjRkdD5x3k=iw@mail.gmail.com>
In-Reply-To: <CA+1xoqcChazS=TRt6-7GjJAzQNFLFXmO623rWwjRkdD5x3k=iw@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/11/2012 05:30 PM, Sasha Levin wrote:

> On Fri, May 11, 2012 at 10:00 AM, Hugh Dickins <hughd@google.com> wrote:
>> Commit 93278814d359 "mm: fix division by 0 in percpu_pagelist_fraction()"
>> mistakenly initialized percpu_pagelist_fraction to the sysctl's minimum 8,
>> which leaves 1/8th of memory on percpu lists (on each cpu??); but most of
>> us expect it to be left unset at 0 (and it's not then used as a divisor).
> 
> I'm a bit confused about this, does it mean that once you set
> percpu_pagelist_fraction to a value above the minimum, you can no
> longer set it back to being 0?


Unfortunately, Yes. :(
It's rather awkward and need fix.


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
