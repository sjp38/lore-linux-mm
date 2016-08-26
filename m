Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 634CA830BA
	for <linux-mm@kvack.org>; Fri, 26 Aug 2016 04:35:59 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l4so50449133wml.0
        for <linux-mm@kvack.org>; Fri, 26 Aug 2016 01:35:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j77si18427437wmd.76.2016.08.26.01.35.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Aug 2016 01:35:57 -0700 (PDT)
Date: Fri, 26 Aug 2016 10:35:54 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: OOM killer changes
Message-ID: <20160826083553.GE16195@dhcp22.suse.cz>
References: <e867d795-224f-5029-48c9-9ce515c0b75f@Quantum.com>
 <f050bc92-d2f1-80cc-f450-c5a57eaf82f0@suse.cz>
 <ea18e6b3-9d47-b154-5e12-face50578302@Quantum.com>
 <f7a9ea9d-bb88-bfd6-e340-3a933559305a@suse.cz>
 <20160819073359.GA32619@dhcp22.suse.cz>
 <d443b884-87e7-1c93-8684-3a3a35759fb1@suse.cz>
 <20160819082639.GE32619@dhcp22.suse.cz>
 <a43170bc-4464-487f-140b-966f58f9bddf@Quantum.com>
 <20160825072219.GD4230@dhcp22.suse.cz>
 <2f897a0c-e27d-7ad7-dd0c-6b1e0d3fb2b4@Quantum.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2f897a0c-e27d-7ad7-dd0c-6b1e0d3fb2b4@Quantum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu 25-08-16 13:35:04, Ralf-Peter Rohbeck wrote:
[...]
> Sorry, the tag was next-20160823; I called the branch linux-next-20160823.

Yeah that is the tag I was looking for but the linux-next is quite
volatile and if you do not fetch the particular tag it won't exist in
leter trees. Anyway, I have set up a branch oom-playground in my tree
git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git which which
is on top of the current up-to-date mmotm tree + revert of the quick
workaround which you have already tested (thanks for that!) and with
the Vlastimil's patch which was dropped due to workaround. AFAIU this
is what you have previously tested without OOM but later on still
managed to hit OOM again. Which would suggest we are still not there
and need to investigate further. I have some ideas what to do but I
would appreciate if we can confirm this status before we try new things.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
