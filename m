Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 00A846B006E
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 20:03:50 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id b20so4568324yha.12
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 17:03:50 -0800 (PST)
Received: from mail-yh0-x235.google.com (mail-yh0-x235.google.com [2607:f8b0:4002:c01::235])
        by mx.google.com with ESMTPS id n44si15615223yhn.240.2013.12.10.17.03.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 17:03:49 -0800 (PST)
Received: by mail-yh0-f53.google.com with SMTP id b20so4466327yha.26
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 17:03:47 -0800 (PST)
Date: Tue, 10 Dec 2013 17:03:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, memcg: avoid oom notification when current needs
 access to memory reserves
In-Reply-To: <20131210103827.GB20242@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1312101655430.22701@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1311261648570.21003@chino.kir.corp.google.com> <20131127163435.GA3556@cmpxchg.org> <20131202200221.GC5524@dhcp22.suse.cz> <20131202212500.GN22729@cmpxchg.org> <20131203120454.GA12758@dhcp22.suse.cz>
 <alpine.DEB.2.02.1312031544530.5946@chino.kir.corp.google.com> <20131204111318.GE8410@dhcp22.suse.cz> <alpine.DEB.2.02.1312041606260.6329@chino.kir.corp.google.com> <20131209124840.GC3597@dhcp22.suse.cz> <alpine.DEB.2.02.1312091328550.11026@chino.kir.corp.google.com>
 <20131210103827.GB20242@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue, 10 Dec 2013, Michal Hocko wrote:

> > What exactly would you like to see?
> 
> How often do you see PF_EXITING tasks which haven't been killed causing
> a pointless notification? Because fatal_signal_pending and TIF_MEMDIE
> cases are already handled because we bypass charges in those cases (except
> for user OOM killer killed tasks which don't get TIF_MEMDIE and that
> should be fixed).
> 

Triggering a pointless notification with PF_EXITING is rare, yet one 
pointless notification can be avoided with the patch.  Additionally, it 
also avoids a pointless notification for a racing SIGKILL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
