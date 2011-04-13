Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E44B1900086
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 20:22:31 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p3D0MPDv022259
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 17:22:25 -0700
Received: from pxi2 (pxi2.prod.google.com [10.243.27.2])
	by kpbe17.cbf.corp.google.com with ESMTP id p3D0MHWE007948
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 17:22:24 -0700
Received: by pxi2 with SMTP id 2so82920pxi.24
        for <linux-mm@kvack.org>; Tue, 12 Apr 2011 17:22:24 -0700 (PDT)
Date: Tue, 12 Apr 2011 17:22:21 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH resend^2] mm: increase RECLAIM_DISTANCE to 30
In-Reply-To: <1302557371.7286.16607.camel@nimitz>
Message-ID: <alpine.DEB.2.00.1104121719430.10966@chino.kir.corp.google.com>
References: <20110411172004.0361.A69D9226@jp.fujitsu.com> <1302557371.7286.16607.camel@nimitz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris McDermott <lcm@linux.vnet.ibm.com>

On Mon, 11 Apr 2011, Dave Hansen wrote:

> > This patch raise zone_reclaim_mode threshold to 30. 30 don't have
> > specific meaning. but 20 mean one-hop QPI/Hypertransport and such
> > relatively cheap 2-4 socket machine are often used for tradiotional
> > server as above. The intention is, their machine don't use
> > zone_reclaim_mode.
> 
> I know specifically of pieces of x86 hardware that set the information
> in the BIOS to '21' *specifically* so they'll get the zone_reclaim_mode
> behavior which that implies.
> 

That doesn't seem like an argument against this patch, it's an improper 
configuration unless the remote memory access has a latency of 2.1x that 
of a local access between those two nodes.  If that's the case, then it's 
accurately following the ACPI spec and the VM has made its policy decision 
to enable zone_reclaim_mode as a result.  I'm surprised that they'd play 
with their BIOS to enable this by default, those, when it's an easily 
tunable sysctl.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
