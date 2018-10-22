Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id CB8456B0006
	for <linux-mm@kvack.org>; Sun, 21 Oct 2018 21:24:09 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id v18-v6so1943418edq.23
        for <linux-mm@kvack.org>; Sun, 21 Oct 2018 18:24:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b28-v6sor21893174edc.13.2018.10.21.18.24.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 21 Oct 2018 18:24:08 -0700 (PDT)
Date: Mon, 22 Oct 2018 01:24:06 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [RFC] put page to pcp->lists[] tail if it is not on the same node
Message-ID: <20181022012406.7qenlvgabt2s34as@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181019043303.s5axhjfb2v2lzsr3@master>
 <20181019083818.GQ5819@techsingularity.net>
 <20181020163318.72oqszgdtqfafycu@master>
 <20181021121251.GA8041@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181021121251.GA8041@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Wei Yang <richard.weiyang@gmail.com>, willy@infradead.org, mhocko@suse.com, linux-mm@kvack.org, akpm@linux-foundation.org

On Sun, Oct 21, 2018 at 01:12:51PM +0100, Mel Gorman wrote:
>On Sat, Oct 20, 2018 at 04:33:18PM +0000, Wei Yang wrote:
>> >Pages from remote nodes are not placed on local lists. Even in the slab
>> >context, such objects are placed on alien caches which have special
>> >handling.
>> >
>> 
>> Hmm... I am not sure get your point correctly.
>> 
>
>The point is that one list should not contain a mix of pages belonging to
>different nodes or zones or it'll result in unexpected behaviour. If you
>are just shuffling the ordering of pages in the list, it needs justification
>as to why that makes sense.
>

Yep, you are right :-)

>-- 
>Mel Gorman
>SUSE Labs

-- 
Wei Yang
Help you, Help me
