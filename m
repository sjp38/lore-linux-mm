Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5A6336B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 12:25:52 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5GG1b8n000578
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 12:01:37 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5GGPoog133302
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 12:25:50 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5GCPbkH020632
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 09:25:38 -0300
Subject: Re: mmotm 2011-06-15-16-56 uploaded (mm/page_cgroup.c)
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110616103559.GA5244@suse.de>
References: <201106160034.p5G0Y4dr028904@imap1.linux-foundation.org>
	 <20110615214917.a7dce8e6.randy.dunlap@oracle.com>
	 <20110616172819.1e2d325c.kamezawa.hiroyu@jp.fujitsu.com>
	 <20110616103559.GA5244@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 16 Jun 2011 09:25:42 -0700
Message-ID: <1308241542.11430.119.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Randy Dunlap <randy.dunlap@oracle.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu, 2011-06-16 at 11:35 +0100, Mel Gorman wrote:
> > This patch removes definitions of node_start/end_pfn() in each archs
> > and defines a unified one in linux/mmzone.h. It's not under
> > CONFIG_NEED_MULTIPLE_NODES, now.
> 
> Does anyone remember *why* this did not happen in the first place? I
> can't think of a good reason so I've cc'd Dave Hansen as he might
> remember. 

You mean why it's not under CONFIG_NEED_MULTIPLE_NODES?  I'd guess it's
just because it keeps working in all configurations since the
pg_data_t->node_*_pfn entries are defined everywhere.

Is that what you're asking?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
