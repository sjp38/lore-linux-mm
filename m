Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 908D56B0003
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 16:16:32 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id g15-v6so3111496plo.11
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 13:16:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y10-v6sor1055093pga.170.2018.07.18.13.16.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 13:16:30 -0700 (PDT)
Date: Wed, 18 Jul 2018 13:16:28 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/page_alloc: Deprecate kernelcore=nn and
 movable_core=
In-Reply-To: <20180717233100.GH1724@MiWiFi-R3L-srv>
Message-ID: <alpine.DEB.2.21.1807181314230.49359@chino.kir.corp.google.com>
References: <20180717131837.18411-1-bhe@redhat.com> <alpine.DEB.2.21.1807171344320.12251@chino.kir.corp.google.com> <20180717233100.GH1724@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, corbet@lwn.net, linux-doc@vger.kernel.org

On Wed, 18 Jul 2018, Baoquan He wrote:

> > > We can still use 'kernelcore=mirror' or 'movable_node' for the usage
> > > of hotplug and movable zone. If somebody shows up with a valid usecase
> > > we can reconsider.
> > > 
> > 
> > We actively use kernelcore=n%, I had recently added support for the option 
> > in the first place in 4.17.  It's certainly not deprecated.
> 
> Thanks for telling. Just for curiosity, could you tell the scenario you
> are using kernelcore=n%? Since it evenly spread movable area on nodes,
> we may not be able to physically hot unplug/plug RAM.
> 

To evenly distribute ZONE_MOVABLE over a set of nodes regardless of the 
many memory capacities of systems that we have where individual command 
lines cannot be tuned.  But you want to deprecate kernelcore=nn, not just 
the percent version, so I assume that's not the answer you're looking for. 
We do not enable CONFIG_MEMORY_HOTPLUG so this deprecation would break our 
userspace such that we cannot use ZONE_MOVABLE.
