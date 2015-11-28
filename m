Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id B000C6B0038
	for <linux-mm@kvack.org>; Sat, 28 Nov 2015 05:08:59 -0500 (EST)
Received: by wmec201 with SMTP id c201so96268681wme.0
        for <linux-mm@kvack.org>; Sat, 28 Nov 2015 02:08:59 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id n10si53988549wja.51.2015.11.28.02.08.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Nov 2015 02:08:58 -0800 (PST)
Received: by wmww144 with SMTP id w144so77978452wmw.1
        for <linux-mm@kvack.org>; Sat, 28 Nov 2015 02:08:58 -0800 (PST)
Date: Sat, 28 Nov 2015 11:08:56 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] tree wide: get rid of __GFP_REPEAT for order-0
 allocations part I
Message-ID: <20151128100856.GA7963@dhcp22.suse.cz>
References: <1446740160-29094-1-git-send-email-mhocko@kernel.org>
 <1446740160-29094-2-git-send-email-mhocko@kernel.org>
 <5641185F.9020104@suse.cz>
 <20151110125101.GA8440@dhcp22.suse.cz>
 <564C8801.2090202@suse.cz>
 <20151127093807.GD2493@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151127093807.GD2493@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Fri 27-11-15 10:38:07, Michal Hocko wrote:
[...]
> I am not sure whether we found any conclusion here. Are there any strong
> arguments against patch 1? I think that should be relatively
> non-controversial. What about patch 2? I think it should be ok as well
> as we are basically removing the flag which has never had any effect.
> 
> I would like to proceed with this further by going through remaining users.
> Most of them depend on a variable size and I am not familiar with the
> code so I will talk to maintainer to find out reasoning behind using the
> flag. Once we have reasonable number of them I would like to go on and
> rename the flag to __GFP_BEST_AFFORD and make it independent on the

ble, __GFP_BEST_EFFORT I meant of course...

> order. It would still trigger OOM killer where applicable but wouldn't
> retry endlessly.
> 
> Does this sound like a reasonable plan?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
