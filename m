Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 093A48E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 14:01:22 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id t7so5298080edr.21
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 11:01:21 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c13-v6si16252ejj.300.2019.01.18.11.01.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 11:01:19 -0800 (PST)
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
References: <20190110070355.GJ27534@dastard>
 <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica>
 <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com>
 <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net>
 <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
 <20190116054613.GA11670@nautica>
 <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
 <20190116063430.GA22938@nautica>
 <CA+t-nXTfdo07EBvVo+mu8SRhrVyB=mEPLDQikHfpJue1jALJtQ@mail.gmail.com>
 <a056deb7-9c11-612e-2b3a-6482acca4ff6@suse.cz>
 <CAHk-=wi0MXm4zTC6jjS1TBfbHW_sQq_OcyfeLBNGJ29m88pt+g@mail.gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <362c8696-b308-53b7-2014-261530b4abcb@suse.cz>
Date: Fri, 18 Jan 2019 19:58:13 +0100
MIME-Version: 1.0
In-Reply-To: <CAHk-=wi0MXm4zTC6jjS1TBfbHW_sQq_OcyfeLBNGJ29m88pt+g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Josh Snyder <joshs@netflix.com>, Dominique Martinet <asmadeus@codewreck.org>, Andy Lutomirski <luto@amacapital.net>, Dave Chinner <david@fromorbit.com>, Jiri Kosina <jikos@kernel.org>, Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On 1/18/19 5:49 AM, Linus Torvalds wrote:
> On Fri, Jan 18, 2019 at 9:45 AM Vlastimil Babka <vbabka@suse.cz> wrote:
>>
>> Or maybe we could resort to the 5.0-rc1 page table check (that is now being
>> reverted) but only in cases when we are not allowed the page cache residency
>> check? Or would that be needlessly complicated?
> 
> I think it would  be good fallback semantics, but I'm not sure it's
> worth it. Have you tried writing a patch for it? I don't think you'd
> want to do the check *when* you find a hole, so you'd have to do it
> upfront and then pass the cached data down with the private pointer
> (or have a separate "struct mm_walk" structure, perhaps?
> 
> So I suspect we're better off with the patch we have. But if somebody
> *wants* to try to do that fancier patch, and it doesn't look
> horrendous, I think it might be the "quality" solution.

I thought to drop the idea because of leaking that page has been
evicted, but then I realized there are other ways to check for that
anyway in /proc. So I'll try, but probably not until after next week. If
somebody else wants to, they are welcome. As you say, the current
solution should be ok, so that would be a patch on top anyway, for
bisectability etc.

Vlastimil

>               Linus
> 
