Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 555B56B02FA
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 04:51:12 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id h24-v6so3303404ede.9
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 01:51:12 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g23si2123462edy.160.2018.11.06.01.51.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 01:51:11 -0800 (PST)
Date: Tue, 6 Nov 2018 10:51:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, memory_hotplug: teach has_unmovable_pages about of
 LRU migrateable pages
Message-ID: <20181106095109.GJ27423@dhcp22.suse.cz>
References: <20181105002009.GF27491@MiWiFi-R3L-srv>
 <20181105091407.GB4361@dhcp22.suse.cz>
 <20181105092851.GD4361@dhcp22.suse.cz>
 <20181105102520.GB22011@MiWiFi-R3L-srv>
 <20181105123837.GH4361@dhcp22.suse.cz>
 <20181105142308.GJ27491@MiWiFi-R3L-srv>
 <20181105171002.GO4361@dhcp22.suse.cz>
 <20181106002216.GK27491@MiWiFi-R3L-srv>
 <20181106082826.GC27423@dhcp22.suse.cz>
 <20181106091624.GL27491@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181106091624.GL27491@MiWiFi-R3L-srv>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On Tue 06-11-18 17:16:24, Baoquan He wrote:
[...]
> Not sure if there are any scenario or use cases to cover those newly added
> checking other movable zone checking. Surely, I have no objection to
> adding them. But the two patches are separate issues, they have no
> dependency on each other.

Yes that is correct. I will drop those additional checks for now. Let's
see if we need them later.

> I just tested the movable zone checking yesterday, will add your
> previous check back, then test again. I believe the result will be
> positive. Will udpate once done.

THere is no need to retest with that patch for your movable node setup.

-- 
Michal Hocko
SUSE Labs
