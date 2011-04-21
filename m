Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8CCA18D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 15:33:57 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p3LJXrmh025612
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:33:54 -0700
Received: from pwi15 (pwi15.prod.google.com [10.241.219.15])
	by wpaz37.hot.corp.google.com with ESMTP id p3LJXddc012581
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:33:52 -0700
Received: by pwi15 with SMTP id 15so51125pwi.33
        for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:33:48 -0700 (PDT)
Date: Thu, 21 Apr 2011 12:33:46 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
In-Reply-To: <20110421221712.9184.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1104211230030.5829@chino.kir.corp.google.com>
References: <1303337718.2587.51.camel@mulgrave.site> <alpine.DEB.2.00.1104201530430.13948@chino.kir.corp.google.com> <20110421221712.9184.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>

On Thu, 21 Apr 2011, KOSAKI Motohiro wrote:

> ia64 and mips have CONFIG_ARCH_POPULATES_NODE_MAP and it initialize
> N_NORMAL_MEMORY automatically if my understand is correct.
> (plz see free_area_init_nodes)
> 

ia64 doesn't enable CONFIG_HIGHMEM, so it never gets set via this generic 
code; mips also doesn't enable it for all configs even for 32-bit.

So we'll either want to take check_for_regular_memory() out from under 
CONFIG_HIGHMEM and do it for all configs or teach slub to use 
N_HIGH_MEMORY rather than N_NORMAL_MEMORY.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
