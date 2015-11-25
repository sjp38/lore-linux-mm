Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id AF54D6B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 13:26:12 -0500 (EST)
Received: by igbxm8 with SMTP id xm8so43706500igb.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 10:26:12 -0800 (PST)
Received: from resqmta-ch2-12v.sys.comcast.net (resqmta-ch2-12v.sys.comcast.net. [2001:558:fe21:29:69:252:207:44])
        by mx.google.com with ESMTPS id m2si7396206igv.76.2015.11.25.10.26.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 25 Nov 2015 10:26:11 -0800 (PST)
Date: Wed, 25 Nov 2015 12:26:10 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/vmstat: retrieve more accurate vmstat value
In-Reply-To: <20151125180350.GT27283@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1511251225060.432@east.gentwo.org>
References: <1448346123-2699-1-git-send-email-iamjoonsoo.kim@lge.com> <alpine.DEB.2.20.1511240934130.20512@east.gentwo.org> <20151125025735.GC9563@js1304-P5Q-DELUXE> <alpine.DEB.2.20.1511251002380.31590@east.gentwo.org>
 <20151125180350.GT27283@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 25 Nov 2015, Michal Hocko wrote:

> > Simply remove the counter from the vmstat handling and do it differently
> > then.
>
> We definitely do not want yet another set of counters. vmstat counters
> are not only to be exported into the userspace. We have in kernel users
> as well. I do agree that there are users who can cope with some level of
> imprecision though and those which depend on the accuracy can use
> zone_page_state_snapshot which doesn't impose any overhead on others.
> [...]

Ok then the proper patch would be to use zone_page_state() instead of
zone_page_state() here instead of modifying zone_page_state().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
