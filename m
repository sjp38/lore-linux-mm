Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 04A27900086
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 20:49:11 -0400 (EDT)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3D0REYp029988
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 20:27:14 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 95C9E6E8039
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 20:49:09 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3D0n90A317800
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 20:49:09 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3D0n8UU006656
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 21:49:09 -0300
Subject: Re: [PATCH resend^2] mm: increase RECLAIM_DISTANCE to 30
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1104121719430.10966@chino.kir.corp.google.com>
References: <20110411172004.0361.A69D9226@jp.fujitsu.com>
	 <1302557371.7286.16607.camel@nimitz>
	 <alpine.DEB.2.00.1104121719430.10966@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Tue, 12 Apr 2011 17:49:06 -0700
Message-ID: <1302655746.8321.4001.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris McDermott <lcm@linux.vnet.ibm.com>

On Tue, 2011-04-12 at 17:22 -0700, David Rientjes wrote:
> On Mon, 11 Apr 2011, Dave Hansen wrote:
> I know specifically of pieces of x86 hardware that set the information
> > in the BIOS to '21' *specifically* so they'll get the zone_reclaim_mode
> > behavior which that implies.
> 
> That doesn't seem like an argument against this patch, it's an improper 
> configuration unless the remote memory access has a latency of 2.1x that 
> of a local access between those two nodes.  If that's the case, then it's 
> accurately following the ACPI spec and the VM has made its policy decision 
> to enable zone_reclaim_mode as a result.

Heh, if the kernel broke on every system that didn't follow _some_ spec,
it wouldn't boot in very many places.

When you have a hammer, everything looks like a nail.  When you're a
BIOS developer, you start thwacking at the kernel with munged ACPI
tables instead of boot options.  Folks do this in the real world, and I
think if we can't put their names and addresses next to the code that
works around this, we might as well put the DMI strings of their
hardware. :) 

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
