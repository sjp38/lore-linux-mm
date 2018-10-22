Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9CBA76B0006
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 13:01:51 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l51-v6so25040186edc.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 10:01:51 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cw21-v6si1543214ejb.52.2018.10.22.10.01.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Oct 2018 10:01:50 -0700 (PDT)
Date: Mon, 22 Oct 2018 19:01:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory management issue in 4.18.15
Message-ID: <20181022170146.GI18839@dhcp22.suse.cz>
References: <CADa=ObrwYaoNFn0x06mvv5W1F9oVccT5qjGM8qFBGNPoNuMUNw@mail.gmail.com>
 <20181022083322.GE32333@dhcp22.suse.cz>
 <20181022150815.GA4287@tower.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181022150815.GA4287@tower.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>, Sasha Levin <alexander.levin@microsoft.com>
Cc: Spock <dairinin@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon 22-10-18 15:08:22, Roman Gushchin wrote:
[...]
> RE backporting: I'm slightly surprised that only one patch of the memcg
> reclaim fix series has been backported. Either all or none makes much more
> sense to me.

Yeah, I think this is AUTOSEL trying to be clever again. I though it has
been agreed that MM is quite good at marking patches for stable and so
it was not considered by the machinery. Sasha?
-- 
Michal Hocko
SUSE Labs
