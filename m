Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 6DAB36B0031
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 03:20:24 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id fp1so66566pdb.24
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 00:20:24 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id gj4si21087416pac.2.2014.02.19.00.20.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 00:20:23 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id lf10so71225pab.4
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 00:20:23 -0800 (PST)
Date: Wed, 19 Feb 2014 00:20:21 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: ppc: RECLAIM_DISTANCE 10?
In-Reply-To: <20140219081644.GA14783@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.02.1402190017480.7280@chino.kir.corp.google.com>
References: <20140218090658.GA28130@dhcp22.suse.cz> <alpine.DEB.2.02.1402181424490.20772@chino.kir.corp.google.com> <20140219081644.GA14783@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Anton Blanchard <anton@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 19 Feb 2014, Michal Hocko wrote:

> > I strongly suspect that the patch is correct since powerpc node distances 
> > are different than the architectures you're talking about and get doubled 
> > for every NUMA domain that the hardware supports.
> 
> Even if the units of the distance is different on PPC should every NUMA
> machine have zone_reclaim enabled? That doesn't right to me.
> 

In my experience on powerpc it's very correct, there's typically a 
significant latency in remote access and we don't have the benefit of a 
SLIT that actually defines the locality between proximity domains like we 
do on other architectures.  We have had significant issues with thp, for 
example, being allocated remotely instead of pages locally, much more 
drastic than on our x86 machines, particularly AMD machines.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
