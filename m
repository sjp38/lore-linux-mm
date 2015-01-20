Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id E62F16B0032
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 09:16:35 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id em10so13332803wid.5
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 06:16:35 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ej8si5684860wid.14.2015.01.20.06.16.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jan 2015 06:16:35 -0800 (PST)
Date: Tue, 20 Jan 2015 09:16:28 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: memcontrol: default hierarchy interface for memory
 fix - high reclaim
Message-ID: <20150120141628.GA11181@phnom.home.cmpxchg.org>
References: <1421508079-29293-1-git-send-email-hannes@cmpxchg.org>
 <20150120132519.GH25342@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150120132519.GH25342@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jan 20, 2015 at 02:25:19PM +0100, Michal Hocko wrote:
> On Sat 17-01-15 10:21:19, Johannes Weiner wrote:
> > High limit reclaim can currently overscan in proportion to how many
> > charges are happening concurrently.  Tone it down such that charges
> > don't target the entire high-boundary excess, but instead only the
> > pages they charged themselves when excess is detected.
> > 
> > Reported-by: Michal Hocko <mhocko@suse.cz>
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> I certainly agree with this approach.
> Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> Is this planned to be folded into the original patch or go on its own. I
> am OK with both ways, maybe having it separate would be better from
> documentation POV.

I submitted them to be folded in.  Which aspect would you like to see
documented?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
