Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id CA4C482F64
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 23:05:33 -0400 (EDT)
Received: by wicfx6 with SMTP id fx6so183425656wic.1
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 20:05:33 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p3si1239766wia.63.2015.10.27.20.05.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 20:05:32 -0700 (PDT)
Date: Tue, 27 Oct 2015 20:05:19 -0700
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Message-ID: <20151028030519.GA20789@cmpxchg.org>
References: <20151027154138.GA4665@cmpxchg.org>
 <20151027161554.GJ9891@dhcp22.suse.cz>
 <20151027164227.GB7749@cmpxchg.org>
 <20151027.174532.469361008055673315.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151027.174532.469361008055673315.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: mhocko@kernel.org, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 27, 2015 at 05:45:32PM -0700, David Miller wrote:
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Tue, 27 Oct 2015 09:42:27 -0700
> 
> > On Tue, Oct 27, 2015 at 05:15:54PM +0100, Michal Hocko wrote:
> >> > For now, something like this as a boot commandline?
> >> > 
> >> > cgroup.memory=nosocket
> >> 
> >> That would work for me.
> > 
> > Okay, then I'll go that route for the socket stuff.
> > 
> > Dave is that cool with you?
> 
> Depends upon the default.
> 
> Until the user configures something explicitly into the memory
> controller, the networking bits should all evaluate to nothing.

Yep, I'll stick them behind a default-off jump label again.

This bootflag is only to override an active memory controller
configuration and force-off that jump label permanently.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
