Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0206B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 12:03:52 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [172.25.149.14])
	by smtp-out.google.com with ESMTP id p79G3nx4007282
	for <linux-mm@kvack.org>; Tue, 9 Aug 2011 09:03:49 -0700
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by hpaq14.eem.corp.google.com with ESMTP id p79G3gpD001360
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 9 Aug 2011 09:03:47 -0700
Received: by pzk36 with SMTP id 36so217404pzk.17
        for <linux-mm@kvack.org>; Tue, 09 Aug 2011 09:03:42 -0700 (PDT)
Date: Tue, 9 Aug 2011 09:03:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: running of out memory => kernel crash
In-Reply-To: <1312874259.89770.YahooMailNeo@web111704.mail.gq1.yahoo.com>
Message-ID: <alpine.DEB.2.00.1108090900170.30199@chino.kir.corp.google.com>
References: <1312872786.70934.YahooMailNeo@web111712.mail.gq1.yahoo.com> <1db776d865939be598cdb80054cf5d93.squirrel@xenotime.net> <1312874259.89770.YahooMailNeo@web111704.mail.gq1.yahoo.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="397155492-1484682820-1312905696=:30199"
Content-ID: <alpine.DEB.2.00.1108090901410.30199@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mahmood Naderan <nt_mahmood@yahoo.com>
Cc: Randy Dunlap <rdunlap@xenotime.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--397155492-1484682820-1312905696=:30199
Content-Type: TEXT/PLAIN; CHARSET=UTF-8
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.1108090901411.30199@chino.kir.corp.google.com>

On Tue, 9 Aug 2011, Mahmood Naderan wrote:

> >Do you have any kernel log panic/oops/Bug messages?
> A 
> Actually, that happened for one my diskless nodes 10 days ago.
> What I saw on the screen (not the logs), was 
> "running out of memory.... kernel panic....."
> 

The only similar message in the kernel is "Out of memory and no killable 
processes..." and that panics the machine when there are no eligible 
tasks to kill.

If you're using cpusets or mempolicies, you must ensure that all tasks 
attached to either of them are not set to OOM_DISABLE.  It seems unlikely 
that you're using those, so it seems like a system-wide oom condition.  Do 
cat /proc/*/oom_score and make sure at least some threads have a non-zero 
badness score.  Otherwise, you'll need to adjust their 
/proc/pid/oom_score_adj settings to not be -1000.

Randy also added linux-mm@kvack.org to the cc, but you removed it; please 
don't do that.
--397155492-1484682820-1312905696=:30199--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
