Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0F5EF6B0089
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 03:18:53 -0500 (EST)
Received: by iwn42 with SMTP id 42so2413391iwn.14
        for <linux-mm@kvack.org>; Wed, 01 Dec 2010 00:18:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101201052232.GL2746@balbir.in.ibm.com>
References: <20101130101126.17475.18729.stgit@localhost6.localdomain6>
	<20101130101602.17475.32611.stgit@localhost6.localdomain6>
	<20101130142509.4f49d452.akpm@linux-foundation.org>
	<20101201045421.GG2746@balbir.in.ibm.com>
	<20101201052232.GL2746@balbir.in.ibm.com>
Date: Wed, 1 Dec 2010 17:18:52 +0900
Message-ID: <AANLkTine=1YW6RHDOwYR5Kq_6ENimf=OUbOgeo1pd8uZ@mail.gmail.com>
Subject: Re: [PATCH 3/3] Provide control over unmapped pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, kvm <kvm@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 1, 2010 at 2:22 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> * Balbir Singh <balbir@linux.vnet.ibm.com> [2010-12-01 10:24:21]:
>
>> * Andrew Morton <akpm@linux-foundation.org> [2010-11-30 14:25:09]:
>> > So you're OK with shoving all this flotsam into 100,000,000 cellphones?
>> > This was a pretty outrageous patchset!
>>
>> I'll do a better one, BTW, a lot of embedded folks are interested in
>> page cache control outside of cgroup behaviour.

Yes. Embedded people(at least, me) want it. That's because they don't
have any swap device so they could reclaim only page cache page.
And many page cache pages are mapped at address space of
application(ex, android uses java model so many pages are mapped by
application's address space). It means it's hard to reclaim them
without lagging.
So I have a interest in this patch.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
