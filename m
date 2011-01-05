Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F0AE46B0088
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 12:00:38 -0500 (EST)
Date: Wed, 5 Jan 2011 12:00:37 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <10614407.141974.1294246837885.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <20110105164413.GB31436@tiehlicka.suse.cz>
Subject: Re: [RFC]
 /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>


> Then you can use the patch I sent earlier and make just a size check
> patch on top of it, right?
There is a sysfs path needs to be checked for invalid input too. Eric
said he had patchs ready, so I can just let him to post it.

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
