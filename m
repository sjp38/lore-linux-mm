Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id E33156B008A
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 03:54:17 -0500 (EST)
Date: Wed, 5 Jan 2011 03:54:16 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <666501532.135624.1294217656273.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <20110105084357.GA21349@tiehlicka.suse.cz>
Subject: Re: [RFC]
 /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>


> OK, this explains the bogus value because hugetlb_overcommit_handler
> doesn't check the return value of proc_doulongvec_minmax which fails
> for
> "\n" string which you are writing to the file so we end up setting a
> random value from the stack. The following patch should fix this:
> 
> Btw. what did you want to achieve by this command?
Just to do some testing for robustness. :)

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
