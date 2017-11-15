Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C16D46B026D
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 09:43:16 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r68so807164wmr.4
        for <linux-mm@kvack.org>; Wed, 15 Nov 2017 06:43:16 -0800 (PST)
Received: from outbound-smtp11.blacknight.com ([46.22.139.106])
        by mx.google.com with ESMTPS id 91si1233504edy.434.2017.11.15.06.43.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Nov 2017 06:43:15 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id 2CEF01C411C
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 14:43:15 +0000 (GMT)
Date: Wed, 15 Nov 2017 14:43:14 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, meminit: Serially initialise deferred memory if
 trace_buf_size is specified
Message-ID: <20171115144314.xwdi2sbcn6m6lqdo@techsingularity.net>
References: <20171115085556.fla7upm3nkydlflp@techsingularity.net>
 <20171115115559.rjb5hy6d6332jgjj@dhcp22.suse.cz>
 <20171115141329.ieoqvyoavmv6gnea@techsingularity.net>
 <20171115142816.zxdgkad3ch2bih6d@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171115142816.zxdgkad3ch2bih6d@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, yasu.isimatu@gmail.com, koki.sanagi@us.fujitsu.com

On Wed, Nov 15, 2017 at 03:28:16PM +0100, Michal Hocko wrote:
> On Wed 15-11-17 14:13:29, Mel Gorman wrote:
> [...]
> > I doubt anyone well. Even the original reporter appeared to pick that
> > particular value just to trigger the OOM.
> 
> Then why do we care at all? The trace buffer size can be configured from
> the userspace if it is not sufficiently large IIRC.
> 

I guess there is the potential that the trace buffer needs to be large
enough early on in boot but I'm not sure why it would need to be that large
to be honest. Bottom line, it's fairly trivial to just serialise meminit
in the event that it's resized from command line. I'm also ok with just
leaving this is as a "don't set the buffer that large" but I don't think
spreading meminit concerns into ftrace is a good idea.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
