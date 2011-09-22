Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2E0289000BD
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 17:38:53 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p8MLcqY0009413
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 14:38:52 -0700
Received: from gwj17 (gwj17.prod.google.com [10.200.10.17])
	by wpaz33.hot.corp.google.com with ESMTP id p8MLbfwQ029234
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 22 Sep 2011 14:38:50 -0700
Received: by gwj17 with SMTP id 17so453411gwj.10
        for <linux-mm@kvack.org>; Thu, 22 Sep 2011 14:38:50 -0700 (PDT)
Date: Thu, 22 Sep 2011 14:38:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: kernel crash
In-Reply-To: <20110922212432.GB25623@redhat.com>
Message-ID: <alpine.DEB.2.00.1109221430450.2635@chino.kir.corp.google.com>
References: <1316717125.61795.YahooMailClassic@web162017.mail.bf1.yahoo.com> <20110922212432.GB25623@redhat.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397155492-439253256-1316727529=:2635"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: M <sah_8@yahoo.com>, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397155492-439253256-1316727529=:2635
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 22 Sep 2011, Dave Jones wrote:

> On Thu, Sep 22, 2011 at 11:45:25AM -0700, M wrote:
>  > Hi,
>  > 
>  > I am running Fedora 15 644bit on AMD 64bit arch. After update 3 days ago, kernel started to crash when I submit a heavy computation job. It happened today also with similar type of job. 
>  > 
>  > I submitted a bug report to https://bugzilla.redhat.com/  d=740613 . They referred me to contact linux memory management group. I have also uploaded my log file in the bug report. I will be very happy to provide more information if required to resolve this issue.
>  > 
>  > Thanks.
> 
> (fixed url is https://bugzilla.redhat.com/show_bug.cgi?id=740613)
> 
> Manoj's report here has a system with 32GB of RAM and 40GB of swap
> oomkill'ing processes when there seems to be ram still available.
> 

Looking at the output of the first oom from 
https://bugzilla.redhat.com/attachment.cgi?id=524451

Sep 20 19:39:19 host2 kernel: [1932999.874704] Node 0 DMA free:15892kB min:40kB low:48kB high:60kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15684kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
Sep 20 19:39:19 host2 kernel: [1932999.874727] lowmem_reserve[]: 0 1970 16110 16110
Sep 20 19:39:19 host2 kernel: [1932999.874739] Node 0 DMA32 free:61832kB min:5500kB low:6872kB high:8248kB active_anon:1494456kB inactive_anon:498264kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2018144kB mlocked:0kB dirty:0kB writeback:0kB mapped:20kB shmem:0kB slab_reclaimable:864kB slab_unreclaimable:44kB kernel_stack:0kB pagetables:6632kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
Sep 20 19:39:19 host2 kernel: [1932999.874765] lowmem_reserve[]: 0 0 14140 14140
Sep 20 19:39:19 host2 kernel: [1932999.874772] Node 0 Normal free:39440kB min:39464kB low:49328kB high:59196kB active_anon:12962768kB inactive_anon:1178596kB active_file:236kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:14479360kB mlocked:0kB dirty:0kB writeback:1560kB mapped:164kB shmem:0kB slab_reclaimable:10356kB slab_unreclaimable:12296kB kernel_stack:1504kB pagetables:75224kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:354 all_unreclaimable? yes
Sep 20 19:39:19 host2 kernel: [1932999.874810] lowmem_reserve[]: 0 0 0 0
Sep 20 19:39:19 host2 kernel: [1932999.874817] Node 1 Normal free:44920kB min:45100kB low:56372kB high:67648kB active_anon:14981988kB inactive_anon:1248872kB active_file:812kB inactive_file:792kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:16547840kB mlocked:0kB dirty:0kB writeback:14676kB mapped:392kB shmem:0kB slab_reclaimable:8484kB slab_unreclaimable:11252kB kernel_stack:840kB pagetables:71480kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:2057 all_unreclaimable? yes
Sep 20 19:39:19 host2 kernel: [1932999.874856] lowmem_reserve[]: 0 0 0 0

We can see that both normal zones are under their minimum watermark, so 
they are completely oom.  We can't allocate in ZONE_DMA32 because of 
lowmem_reserve for this gfp mask (61832K - (14140 * 4K) < 5500K) and 
ZONE_DMA for the same reason.  So there's no RAM available.

Sep 20 19:39:19 host2 kernel: [1932999.874970] 331623 total pagecache pages
Sep 20 19:39:19 host2 kernel: [1932999.874974] 331021 pages in swap cache
Sep 20 19:39:19 host2 kernel: [1932999.874978] Swap cache stats: add 10280280, delete 9949259, find 5232/9633
Sep 20 19:39:19 host2 kernel: [1932999.874982] Free swap  = 0kB

And there's no swap available.

> I note the gfp mask of the failing allocations has GFP_HIGHMEM,
> and this apparently doesn't happen when he runs 32-bit.
> 
> Could that be a clue ?
> 

The problem is this:

Sep 20 19:39:19 host2 kernel: [1933000.196980] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
...
Sep 20 19:39:19 host2 kernel: [1933000.197559] [13918]   507 13918 17992270  7758558   4     -17         -1000 root.exe

root.exe is has about 29.5GB of the 32GB available memory in RAM, and it's 
set to have a /proc/13918/oom_score_adj of -1000 meaning it's not eligible 
for oom killing.  So the kernel panics rather than kill the task.

There's not much the kernel can be expected to do in such a configuration, 
you've simply exhausted all RAM and swap.  You can set 
/proc/pid/oom_score_adj to not be -1000 so that it is at least eligible to 
be killed in these circumstances rather than panic the machine, but the VM 
will continue to oom under this configuration.
--397155492-439253256-1316727529=:2635--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
