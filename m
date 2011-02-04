Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2E3278D003B
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 18:40:37 -0500 (EST)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p14NeQJ2023924
	for <linux-mm@kvack.org>; Fri, 4 Feb 2011 15:40:26 -0800
Received: from qyk12 (qyk12.prod.google.com [10.241.83.140])
	by hpaq7.eem.corp.google.com with ESMTP id p14Ncm4Q028777
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 4 Feb 2011 15:40:25 -0800
Received: by qyk12 with SMTP id 12so2472344qyk.5
        for <linux-mm@kvack.org>; Fri, 04 Feb 2011 15:40:24 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 4 Feb 2011 15:40:24 -0800
Message-ID: <AANLkTimTSE2OrgFSmsYPk7uW+8zAuwfjbeku8WCbGONP@mail.gmail.com>
Subject: [LSF/MM TOPIC][ATTEND]cold page tracking / working set estimation
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lsf-pc@lists.linuxfoundation.org, linux-mm@kvack.org
Cc: Hugh Dickins <hughd@google.com>

Google uses an automated system to assign compute jobs to individual
machines within a cluster. In order to improve memory utilization in
the cluster, this system collects memory utilization statistics for
each cgroup on each machine. The following properties are desired for
the working set estimation mechanism:

- Low impact on the normal MM algorithms - we don't want to stress the
VM just by enabling working set estimation;

- Collected statistics should be comparable across multiple machines -
we don't just want to know which cgroup to reclaim from on an
individual machine, we also need to know which machine is best to
target a job onto within a large cluster;

- Low, predictable CPU usage;

- Among cold pages, differentiate between these that are immediately
reclaimable and these that would require a disk write.

We use a very simple approach, scanning memory at a fixed rate and
identifying pages that haven't been touched in a number of scans. We
are currently switching from a fakenuma based implementation (which we
don't think is very upstreamable) to a memcg based one. We think this
could be of interest to the wider community & would like to discuss
requirement with other interested folks.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
