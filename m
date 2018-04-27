Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 665C46B0005
	for <linux-mm@kvack.org>; Fri, 27 Apr 2018 04:27:18 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id m68so1043886pfm.20
        for <linux-mm@kvack.org>; Fri, 27 Apr 2018 01:27:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e125si846866pfe.244.2018.04.27.01.27.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Apr 2018 01:27:17 -0700 (PDT)
Date: Fri, 27 Apr 2018 10:27:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: OOM killer invoked while still one forth of mem is available
Message-ID: <20180427082715.GD17484@dhcp22.suse.cz>
References: <df1a8c14-bda3-6271-d403-24b88a254b2c@c-s.fr>
 <alpine.DEB.2.21.1804251253240.151692@chino.kir.corp.google.com>
 <296ea83c-2c00-f1d2-3f62-d8ab8b8fb73c@c-s.fr>
 <20180426131154.GQ17484@dhcp22.suse.cz>
 <2706829f-6207-89f7-46e6-d32244305ccb@c-s.fr>
 <20180426190514.GU17484@dhcp22.suse.cz>
 <20180426222917.Horde.cu42u5sTkcbGdcY0VUmclQ1@messagerie.si.c-s.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180426222917.Horde.cu42u5sTkcbGdcY0VUmclQ1@messagerie.si.c-s.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LEROY Christophe <christophe.leroy@c-s.fr>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Thu 26-04-18 22:29:17, LEROY Christophe wrote:
> Michal Hocko <mhocko@kernel.org> a ecrit :
[...]
> > Yes, show_migration_types. But I do not see why unmovable pageblocks
> > should block the allocation. This is a GFP_KERNEL allocation request
> > essentially - thus unmovable itself. This smells like a bug. We are way
> > above reserves which could block the allocation.
> 
> Any suggestion on how to investigate that bug ? Anything to trace ?

try to enable allocator and vmscan tracepoints. Maybe it will tell
something.
-- 
Michal Hocko
SUSE Labs
