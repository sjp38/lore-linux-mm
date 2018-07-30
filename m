Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7140D6B000D
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 13:54:23 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id r184-v6so242066ith.0
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 10:54:23 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id d68-v6si104725ita.99.2018.07.30.10.54.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 30 Jul 2018 10:54:21 -0700 (PDT)
Subject: Re: [PATCH 0/10] psi: pressure stall information for CPU, memory, and
 IO v2
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180727220123.GB18879@amd> <20180730154035.GC4567@cmpxchg.org>
 <20180730173940.GB881@amd>
 <20180730175120.GJ1206094@devbig004.ftw2.facebook.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <dfc3c810-8918-add4-b818-8b9c294f5ea4@infradead.org>
Date: Mon, 30 Jul 2018 10:54:05 -0700
MIME-Version: 1.0
In-Reply-To: <20180730175120.GJ1206094@devbig004.ftw2.facebook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 07/30/2018 10:51 AM, Tejun Heo wrote:
> Hello,
> 
> On Mon, Jul 30, 2018 at 07:39:40PM +0200, Pavel Machek wrote:
>>> I'd rather have the internal config symbol match the naming scheme in
>>> the code, where psi is a shorter, unique token as copmared to e.g.
>>> pressure, press, prsr, etc.
>>
>> I'd do "pressure", really. Yes, psi is shorter, but I'd say that
>> length is not really important there.
> 
> This is an extreme bikeshedding without any relevance.  You can make
> suggestions but please lay it to the rest.  There isn't any general
> consensus against the current name and you're just trying to push your
> favorite name without proper justifications after contributing nothing
> to the project.  Please stop.
> 
> Thanks.

I'd say he's trying to make something that is readable and easier to
understand for users.

Thanks.


-- 
~Randy
