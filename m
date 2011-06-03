Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 09D776B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 23:09:56 -0400 (EDT)
Received: by yib18 with SMTP id 18so760595yib.14
        for <linux-mm@kvack.org>; Thu, 02 Jun 2011 20:09:55 -0700 (PDT)
Date: Fri, 3 Jun 2011 00:08:43 -0300
From: Rafael Aquini <aquini@linux.com>
Subject: Re: [PATCH] [BUGFIX] mm: hugepages can cause negative commitlimit
Message-ID: <20110603030841.GB10530@optiplex.tchesoft.com>
Reply-To: aquini@linux.com
References: <20110518153445.GA18127@sgi.com>
 <BANLkTinbHnrf2isuLzUFZN8ypaT476G1zw@mail.gmail.com>
 <20110519045630.GA22533@sgi.com>
 <BANLkTinyYP-je9Nf8X-xWEdpgvn8a631Mw@mail.gmail.com>
 <20110519221101.GC19648@sgi.com>
 <20110520130411.d1e0baef.akpm@linux-foundation.org>
 <20110520223032.GA15192@x61.tchesoft.com>
 <20110526210751.GA14819@optiplex.tchesoft.com>
 <20110602040821.GA7934@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110602040821.GA7934@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russ Anderson <rja@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, rja@americas.sgi.com

Howdy Russ,

On Wed, Jun 01, 2011 at 11:08:31PM -0500, Russ Anderson wrote:
> 
> Yes, it fixes the inconsistency in reporting totalram_pages.
Thanks alot for the feedback.

> There seems to be another issue.  1G hugepages can be allocated at boot time, but
> cannot be allocated at run time.  "default_hugepagesz=1G hugepagesz=1G hugepages=1" on 
> the boot line works.  With "default_hugepagesz=1G hugepagesz=1G" the command
> "echo 1 > /proc/sys/vm/nr_hugepages" fails.
> 
> uv4-sys:~ # echo 1 > /proc/sys/vm/nr_hugepages
> -bash: echo: write error: Invalid argument

That's not an issue, actually. It seems to be , unfortunately, 
an implementation characteristic, due to an imposed arch constraint.
Further reference: http://lwn.net/Articles/273661/

Cheers!
-- 
Rafael Aquini <aquini@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
