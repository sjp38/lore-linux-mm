Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4DD2E6B0070
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 18:14:00 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so5774721pdj.41
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 15:13:59 -0700 (PDT)
Received: from mail-pb0-x233.google.com (mail-pb0-x233.google.com [2607:f8b0:400e:c01::233])
        by mx.google.com with ESMTPS id qf5si4976386pac.211.2014.04.11.15.13.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Apr 2014 15:13:59 -0700 (PDT)
Received: by mail-pb0-f51.google.com with SMTP id uo5so5941774pbc.38
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 15:13:57 -0700 (PDT)
Date: Fri, 11 Apr 2014 15:13:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] drivers/base/node.c: export physical address range of
 given node (Re: NUMA node information for pages)
In-Reply-To: <53481724.8020304@intel.com>
Message-ID: <alpine.DEB.2.02.1404111513040.17724@chino.kir.corp.google.com>
References: <87eh1ix7g0.fsf@x240.local.i-did-not-set--mail-host-address--so-tickle-me> <533a1563.ad318c0a.6a93.182bSMTPIN_ADDED_BROKEN@mx.google.com> <CAOPLpQc8R2SfTB+=BsMa09tcQ-iBNJHg+tGnPK-9EDH1M47MJw@mail.gmail.com> <5343806c.100cc30a.0461.ffffc401SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.02.1404091734060.1857@chino.kir.corp.google.com> <5345fe27.82dab40a.0831.0af9SMTPIN_ADDED_BROKEN@mx.google.com> <alpine.DEB.2.02.1404101500280.11995@chino.kir.corp.google.com> <53474709.e59ec20a.3bd5.3b91SMTPIN_ADDED_BROKEN@mx.google.com>
 <alpine.DEB.2.02.1404110325210.30610@chino.kir.corp.google.com> <53481724.8020304@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, drepper@gmail.com, anatol.pomozov@gmail.com, jkosina@suse.cz, akpm@linux-foundation.org, xemul@parallels.com, paul.gortmaker@windriver.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 11 Apr 2014, Dave Hansen wrote:

> > So?  Who cares if there are non-addressable holes in part of the span?  
> > Ulrich, correct me if I'm wrong, but it seems you're looking for just a 
> > address-to-nodeid mapping (or pfn-to-nodeid mapping) and aren't actually 
> > expecting that there are no holes in a node for things like acpi or I/O or 
> > reserved memory.
> ...
> > I think trying to represent holes and handling different memory models and 
> > hotplug in special ways is complete overkill.
> 
> This isn't just about memory hotplug or different memory models.  There
> are systems out there today, in production, that have layouts like this:
> 
> |------Node0-----|
>      |------Node1-----|
> 
> and this:
> 
> |------Node0-----|
>      |-Node1-|
> 

What additional information, in your opinion, can we export to assist 
userspace in making this determination that $address is on $nid?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
