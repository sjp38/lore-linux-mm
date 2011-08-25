Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 275706B0169
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 01:04:34 -0400 (EDT)
Received: from wpaz1.hot.corp.google.com (wpaz1.hot.corp.google.com [172.24.198.65])
	by smtp-out.google.com with ESMTP id p7P54U6J000529
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 22:04:30 -0700
Received: from pzk4 (pzk4.prod.google.com [10.243.19.132])
	by wpaz1.hot.corp.google.com with ESMTP id p7P54SU9007635
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Aug 2011 22:04:29 -0700
Received: by pzk4 with SMTP id 4so2786595pzk.28
        for <linux-mm@kvack.org>; Wed, 24 Aug 2011 22:04:28 -0700 (PDT)
Date: Wed, 24 Aug 2011 22:04:25 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Patch] numa: introduce CONFIG_NUMA_SYSFS for
 drivers/base/node.c
In-Reply-To: <20110824205044.7ff45b6c.rdunlap@xenotime.net>
Message-ID: <alpine.DEB.2.00.1108242202050.576@chino.kir.corp.google.com>
References: <20110804145834.3b1d92a9eeb8357deb84bf83@canb.auug.org.au> <20110804152211.ea10e3e7.rdunlap@xenotime.net> <20110823143912.0691d442.akpm@linux-foundation.org> <4E547155.8090709@redhat.com> <20110824191430.8a908e70.rdunlap@xenotime.net>
 <4E55C221.8080100@redhat.com> <20110824205044.7ff45b6c.rdunlap@xenotime.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: Cong Wang <amwang@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, gregkh@suse.de, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, 24 Aug 2011, Randy Dunlap wrote:

> > Below is the updated version.
> > 
> > Thanks for testing!
> 
> Yes, that works after changing #ifdef defined(...)
> to #if defined(...)
> 
> Acked-by: Randy Dunlap <rdunlap@xenotime.net>
> 

No, it doesn't work, CONFIG_HUGETLBFS can be enabled with CONFIG_NUMA=y 
and CONFIG_SYSFS=n and that uses data structures from drivers/base/node.c 
which doesn't get compiled with this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
