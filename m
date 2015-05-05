Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id C1B176B0038
	for <linux-mm@kvack.org>; Tue,  5 May 2015 09:24:00 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so192934847pac.1
        for <linux-mm@kvack.org>; Tue, 05 May 2015 06:24:00 -0700 (PDT)
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com. [202.81.31.146])
        by mx.google.com with ESMTPS id ci13si24300403pac.227.2015.05.05.06.23.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 05 May 2015 06:23:59 -0700 (PDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 5 May 2015 23:23:54 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 0CC412BB004D
	for <linux-mm@kvack.org>; Tue,  5 May 2015 23:23:51 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t45DNgVF46071932
	for <linux-mm@kvack.org>; Tue, 5 May 2015 23:23:51 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t45DNIRP003239
	for <linux-mm@kvack.org>; Tue, 5 May 2015 23:23:18 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [patch v2 for-4.0] mm, thp: really limit transparent hugepage allocation to local node
In-Reply-To: <55488994.8010303@suse.cz>
References: <alpine.DEB.2.10.1502241422370.11324@chino.kir.corp.google.com> <alpine.DEB.2.10.1502241522590.9480@chino.kir.corp.google.com> <54EDA96C.4000609@suse.cz> <alpine.DEB.2.10.1502251311360.18097@chino.kir.corp.google.com> <54EE60FC.7000909@suse.cz> <87k2x6q6n0.fsf@linux.vnet.ibm.com> <55488994.8010303@suse.cz>
Date: Tue, 05 May 2015 18:52:58 +0530
Message-ID: <87oalzcg5p.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Vlastimil Babka <vbabka@suse.cz> writes:

> On 04/21/2015 09:31 AM, Aneesh Kumar K.V wrote:
>> Vlastimil Babka <vbabka@suse.cz> writes:
>>
>>> On 25.2.2015 22:24, David Rientjes wrote:
>>>>
>>>>> alloc_pages_preferred_node() variant, change the exact_node() variant to pass
>>>>> __GFP_THISNODE, and audit and adjust all callers accordingly.
>>>>>
....
...
>>> Right, we might be changing behavior not just for slab allocators, but
>>> also others using such
>>> combination of flags.
>>
>> Any update on this ? Did we reach a conclusion on how to go forward here
>> ?
>
> I believe David's later version was merged already. Or what exactly are 
> you asking about?

When I checked last time I didn't find it. Hence I asked here. Now I
see that it got committed as 5265047ac30191ea24b16503165000c225f54feb

Thanks
-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
