Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id B67826B005A
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 06:26:29 -0400 (EDT)
Date: Tue, 23 Oct 2012 12:26:26 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: mmotm 2012-10-22-17-08 uploaded (memory_hotplug.c)
Message-ID: <20121023102625.GA24265@dhcp22.suse.cz>
References: <20121023000924.C56EF5C0050@hpza9.eem.corp.google.com>
 <50861FA9.2030506@xenotime.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50861FA9.2030506@xenotime.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Randy Dunlap <rdunlap@xenotime.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, David Rientjes <rientjes@google.com>, Jiang Liu <liuj97@gmail.com>, Len Brown <len.brown@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Mel Gorman <mel@csn.ul.ie>

On Mon 22-10-12 21:40:09, Randy Dunlap wrote:
> On 10/22/2012 05:09 PM, akpm@linux-foundation.org wrote:
> 
> > The mm-of-the-moment snapshot 2012-10-22-17-08 has been uploaded to
> > 
> >    http://www.ozlabs.org/~akpm/mmotm/
> > 
> > mmotm-readme.txt says
> > 
> > README for mm-of-the-moment:
> > 
> > http://www.ozlabs.org/~akpm/mmotm/
> > 
> > This is a snapshot of my -mm patch queue.  Uploaded at random hopefully
> > more than once a week.
> > 
> 
> 
> 
> on x86_64, when CONFIG_MEMORY_HOTREMOVE is not enabled:
> 
> mm/built-in.o: In function `online_pages':
> (.ref.text+0x10e7): undefined reference to `zone_pcp_reset'

Caused by memory-hotplug-allocate-zones-pcp-before-onlining-pages.patch.
And fixed by. Andrew either fold this one in to the above one or keep it
separate what works better with you.
---
