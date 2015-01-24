Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id ABEA16B0032
	for <linux-mm@kvack.org>; Sat, 24 Jan 2015 02:16:36 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id x13so1155214wgg.1
        for <linux-mm@kvack.org>; Fri, 23 Jan 2015 23:16:36 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id qd1si2343013wjc.109.2015.01.23.23.16.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jan 2015 23:16:35 -0800 (PST)
Date: Sat, 24 Jan 2015 02:16:23 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: mmotm 2015-01-22-15-04: qemu failure due to 'mm: memcontrol:
 remove unnecessary soft limit tree node test'
Message-ID: <20150124071623.GA17705@phnom.home.cmpxchg.org>
References: <54c1822d.RtdGfWPekQVAw8Ly%akpm@linux-foundation.org>
 <20150123050802.GB22751@roeck-us.net>
 <20150123141817.GA22926@phnom.home.cmpxchg.org>
 <alpine.DEB.2.11.1501231419420.11767@gentwo.org>
 <54C2B01D.4070303@roeck-us.net>
 <alpine.DEB.2.11.1501231508020.7871@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1501231508020.7871@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Guenter Roeck <linux@roeck-us.net>, akpm@linux-foundation.org, mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, sfr@canb.auug.org.au, mhocko@suse.cz

On Fri, Jan 23, 2015 at 03:09:20PM -0600, Christoph Lameter wrote:
> On Fri, 23 Jan 2015, Guenter Roeck wrote:
> 
> > Wouldn't that have unintended consequences ? So far
> > rb tree nodes are allocated even if a node not online;
> > the above would change that. Are you saying it is
> > unnecessary to initialize rb tree nodes if the node
> > is not online ?
> 
> It is not advisable to allocate since an offline node means that the
> structure cannot be allocated on the node where it would be most
> beneficial. Typically subsystems allocate the per node data structures
> when the node is brought online.

I would generally agree, but this code, which implements a userspace
interface, is already grotesquely inefficient and heavyhanded.  It's
also superseded in the next release, so we can just keep this simple
at this point.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
