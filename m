Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 20E82900086
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 20:56:14 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p3D0uARb031482
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 17:56:10 -0700
Received: from pxi9 (pxi9.prod.google.com [10.243.27.9])
	by hpaq2.eem.corp.google.com with ESMTP id p3D0u8pH008550
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 17:56:09 -0700
Received: by pxi9 with SMTP id 9so111964pxi.14
        for <linux-mm@kvack.org>; Tue, 12 Apr 2011 17:56:07 -0700 (PDT)
Date: Tue, 12 Apr 2011 17:56:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH resend^2] mm: increase RECLAIM_DISTANCE to 30
In-Reply-To: <1302655746.8321.4001.camel@nimitz>
Message-ID: <alpine.DEB.2.00.1104121752400.12609@chino.kir.corp.google.com>
References: <20110411172004.0361.A69D9226@jp.fujitsu.com> <1302557371.7286.16607.camel@nimitz> <alpine.DEB.2.00.1104121719430.10966@chino.kir.corp.google.com> <1302655746.8321.4001.camel@nimitz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris McDermott <lcm@linux.vnet.ibm.com>

On Tue, 12 Apr 2011, Dave Hansen wrote:

> > That doesn't seem like an argument against this patch, it's an improper 
> > configuration unless the remote memory access has a latency of 2.1x that 
> > of a local access between those two nodes.  If that's the case, then it's 
> > accurately following the ACPI spec and the VM has made its policy decision 
> > to enable zone_reclaim_mode as a result.
> 
> Heh, if the kernel broke on every system that didn't follow _some_ spec,
> it wouldn't boot in very many places.
> 
> When you have a hammer, everything looks like a nail.  When you're a
> BIOS developer, you start thwacking at the kernel with munged ACPI
> tables instead of boot options.  Folks do this in the real world, and I
> think if we can't put their names and addresses next to the code that
> works around this, we might as well put the DMI strings of their
> hardware. :) 
> 

That's why I suggested doing away with RECLAIM_DISTANCE entirely, 
otherwise we are relying on the SLIT always being correct when we know 
it's not; the policy decision in the kernel as it stands now is that we 
want to enable zone_reclaim_mode when remote memory access takes longer 
than 2x that of a local access (3x with KOSAKI-san's patch), which is 
something we can actually measure at boot rather than relying on the BIOS 
at all.  Then we don't have to bother with DMI strings for specific pieces 
of hardware and can remove the existing ia64 and powerpc special cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
