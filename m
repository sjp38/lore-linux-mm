Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7394890014F
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 03:13:17 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p7B7DEpk026682
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 00:13:14 -0700
Received: from pzk34 (pzk34.prod.google.com [10.243.19.162])
	by hpaq3.eem.corp.google.com with ESMTP id p7B7Ca9j029237
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 11 Aug 2011 00:13:12 -0700
Received: by pzk34 with SMTP id 34so3665851pzk.35
        for <linux-mm@kvack.org>; Thu, 11 Aug 2011 00:13:12 -0700 (PDT)
Date: Thu, 11 Aug 2011 00:13:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: running of out memory => kernel crash
In-Reply-To: <1313046422.18195.YahooMailNeo@web111711.mail.gq1.yahoo.com>
Message-ID: <alpine.DEB.2.00.1108110010220.23622@chino.kir.corp.google.com>
References: <1312872786.70934.YahooMailNeo@web111712.mail.gq1.yahoo.com> <1db776d865939be598cdb80054cf5d93.squirrel@xenotime.net> <1312874259.89770.YahooMailNeo@web111704.mail.gq1.yahoo.com> <alpine.DEB.2.00.1108090900170.30199@chino.kir.corp.google.com>
 <1312964098.7449.YahooMailNeo@web111712.mail.gq1.yahoo.com> <alpine.DEB.2.00.1108102106410.14230@chino.kir.corp.google.com> <1313046422.18195.YahooMailNeo@web111711.mail.gq1.yahoo.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397155492-1080208226-1313046791=:23622"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mahmood Naderan <nt_mahmood@yahoo.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>, "\"\"linux-kernel@vger.kernel.org\"\"" <linux-kernel@vger.kernel.org>, "\"linux-mm@kvack.org\"" <linux-mm@kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397155492-1080208226-1313046791=:23622
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 11 Aug 2011, Mahmood Naderan wrote:

> >The default behavior is to kill all eligible and unkillable threads until 
> >there are none left to sacrifice (i.e. all kthreads and OOM_DISABLE).
>  
> In a simple test with virtualbox, I reduced the amount of ram to 300MB. 
> Then I ran "swapoff -a" and opened some applications. I noticed that the free
> spaces is kept around 2-3MB and "kswapd" is running. Also I saw that disk
> activity was very high. 
> That mean although "swap" partition is turned off, "kswapd" was trying to do
> something. I wonder how that behavior can be explained?
> 

Despite it's name, kswapd is still active, it's trying to reclaim memory 
to prevent having to kill a process as the last resort.

If /proc/sys/vm/panic_on_oom is not set, as previously mentioned, then 
we'll need the kernel log to diagnose this further.
--397155492-1080208226-1313046791=:23622--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
