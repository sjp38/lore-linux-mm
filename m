Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5DD376B004F
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 17:09:58 -0400 (EDT)
Received: from spaceape9.eur.corp.google.com (spaceape9.eur.corp.google.com [172.28.16.143])
	by smtp-out.google.com with ESMTP id n9KL9q92001013
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 14:09:54 -0700
Received: from pzk30 (pzk30.prod.google.com [10.243.19.158])
	by spaceape9.eur.corp.google.com with ESMTP id n9KL9n7C021626
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 14:09:49 -0700
Received: by pzk30 with SMTP id 30so4752830pzk.24
        for <linux-mm@kvack.org>; Tue, 20 Oct 2009 14:09:48 -0700 (PDT)
Date: Tue, 20 Oct 2009 14:09:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/5] mm: add numa node symlink for cpu devices in sysfs
In-Reply-To: <20091020204136.GB23675@ldl.fc.hp.com>
Message-ID: <alpine.DEB.1.00.0910201407190.27248@chino.kir.corp.google.com>
References: <20091019212740.32729.7171.stgit@bob.kio> <20091019213430.32729.78995.stgit@bob.kio> <alpine.DEB.1.00.0910192016010.25264@chino.kir.corp.google.com> <20091020204136.GB23675@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alex Chiang <achiang@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 Oct 2009, Alex Chiang wrote:

> * David Rientjes <rientjes@google.com>:
> > On Mon, 19 Oct 2009, Alex Chiang wrote:
> > 
> > > You can discover which CPUs belong to a NUMA node by examining
> > > /sys/devices/system/node/$node/
> > > 
> > 
> > You mean /sys/devices/system/node/node# ?
> 
> Hm, in PCI land, I've been using $foo to indicate a variable in
> documentation I've written, but I can certainly use foo# if
> that's the preferred style.
> 

I'm referring to the directories in /sys/devices/system/node/ being 
'node13' for example, and not '13' as your changelog indicates.

> > > However, it's not convenient to go in the other direction, when looking at
> > > /sys/devices/system/cpu/$cpu/
> > > 
> > 
> > .../cpu/cpu# ?
> > 

Same here.

> > The return values of register_cpu_under_node() and 
> > unregister_cpu_under_node() are always ignored, so it would probably be 
> > best to convert these to be void functions.  That doesn't mean you can 
> > simply ignore the result of the first sysfs_create_link(), though: the 
> > second should probably be suppressed if the first returns an error.
> > 
> 
> I didn't want to change too much in the patch. Changing the
> function signature seems a bit overeager, but if you have strong
> feelings, I can do so.
> 

It's entirely up to you if you want to change them to be void.  I thought 
it would be cleaner if the first patch in the series would convert them to 
void on the basis that the return value is never actually used and then 
the following patches simply return on error conditions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
