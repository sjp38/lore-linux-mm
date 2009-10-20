Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D1F126B004F
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 17:13:22 -0400 (EDT)
Received: from spaceape11.eur.corp.google.com (spaceape11.eur.corp.google.com [172.28.16.145])
	by smtp-out.google.com with ESMTP id n9KLDJwH003805
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 14:13:20 -0700
Received: from pxi40 (pxi40.prod.google.com [10.243.27.40])
	by spaceape11.eur.corp.google.com with ESMTP id n9KLCVpe024575
	for <linux-mm@kvack.org>; Tue, 20 Oct 2009 14:13:16 -0700
Received: by pxi40 with SMTP id 40so4973596pxi.24
        for <linux-mm@kvack.org>; Tue, 20 Oct 2009 14:13:16 -0700 (PDT)
Date: Tue, 20 Oct 2009 14:13:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 5/5] Documentation: ABI: document
 /sys/devices/system/cpu/
In-Reply-To: <20091020204738.GC23675@ldl.fc.hp.com>
Message-ID: <alpine.DEB.1.00.0910201410280.27248@chino.kir.corp.google.com>
References: <20091019212740.32729.7171.stgit@bob.kio> <20091019213435.32729.81751.stgit@bob.kio> <alpine.DEB.1.00.0910192022460.25264@chino.kir.corp.google.com> <20091020204738.GC23675@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alex Chiang <achiang@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Randy Dunlap <randy.dunlap@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

On Tue, 20 Oct 2009, Alex Chiang wrote:

> > Would it be possible for you to document all entities in 
> > /sys/devices/system/cpu/* in this new file (requiring a folding of 
> > Documentation/ABI/testing/sysfs-devices-cache_disable into it)?
>  
> I'll give it a go. There are quite a few things in that directory
> though, like topology information, frequency, etc. that I wasn't
> so excited about documenting.
> 

Those are usually the ones where documentation is the most valuable and 
I'm sure would be greatly appreciated.

> But if that's the tax to create my new symlinks, I'll pay it. ;)
> 

It's definitely not required, I just thought it was a good opportunity to 
document all the contents under /sys/devices/system/cpu if you're going to 
do some of them.  It's up to you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
