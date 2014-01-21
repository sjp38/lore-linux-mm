Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 62B5E6B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 01:08:14 -0500 (EST)
Received: by mail-yh0-f42.google.com with SMTP id a41so902226yho.29
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 22:08:14 -0800 (PST)
Received: from mail-gg0-x230.google.com (mail-gg0-x230.google.com [2607:f8b0:4002:c02::230])
        by mx.google.com with ESMTPS id j50si4336014yhc.150.2014.01.20.22.08.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 20 Jan 2014 22:08:13 -0800 (PST)
Received: by mail-gg0-f176.google.com with SMTP id b1so2450507ggn.21
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 22:08:13 -0800 (PST)
Date: Mon, 20 Jan 2014 22:08:09 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
In-Reply-To: <20140121060428.GA19037@kroah.com>
Message-ID: <alpine.DEB.2.02.1401202204510.21729@chino.kir.corp.google.com>
References: <20140109144757.e95616b4280c049b22743a15@linux-foundation.org> <alpine.DEB.2.02.1401091551390.20263@chino.kir.corp.google.com> <20140109161246.57ea590f00ea5b61fdbf5f11@linux-foundation.org> <alpine.DEB.2.02.1401091613560.22649@chino.kir.corp.google.com>
 <20140110221432.GD6963@cmpxchg.org> <alpine.DEB.2.02.1401121404530.20999@chino.kir.corp.google.com> <20140115143449.GN8782@dhcp22.suse.cz> <alpine.DEB.2.02.1401151319580.10727@chino.kir.corp.google.com> <20140116093220.GC28157@dhcp22.suse.cz>
 <alpine.DEB.2.02.1401202155410.21729@chino.kir.corp.google.com> <20140121060428.GA19037@kroah.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartmann <gregkh@linuxfoundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, "Eric W. Biederman" <ebiederm@xmission.com>

On Mon, 20 Jan 2014, Greg Kroah-Hartmann wrote:

> > The patches getting proposed through -mm for stable boggles my mind
> > sometimes.
> 
> Do you have any objections to patches that I have taken for -stable?  If
> so, please let me know.
> 

You've haven't taken the ones that I outlined in 
http://marc.info/?l=linux-kernel&m=138580717728759, so I'm happy that 
those could be prevented.  I'm identifying another patch here that is 
pending in -mm that obviously violates the stable kernel rules and I don't 
believe it should be annotated in a way that you'll scoop it up later.

The patch in question hasn't been tested by anybody and I don't think you 
want such things to ever be merged into a stable kernel series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
