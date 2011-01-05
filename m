Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 92A7B6B0088
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 04:51:25 -0500 (EST)
Date: Wed, 5 Jan 2011 10:51:20 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC]
 /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_overcommit_hugepages
Message-ID: <20110105095120.GB21349@tiehlicka.suse.cz>
References: <20110105084357.GA21349@tiehlicka.suse.cz>
 <666501532.135624.1294217656273.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <666501532.135624.1294217656273.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Sender: owner-linux-mm@kvack.org
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed 05-01-11 03:54:16, CAI Qian wrote:
> 
> > OK, this explains the bogus value because hugetlb_overcommit_handler
> > doesn't check the return value of proc_doulongvec_minmax which fails
> > for
> > "\n" string which you are writing to the file so we end up setting a
> > random value from the stack. The following patch should fix this:
> > 
> > Btw. what did you want to achieve by this command?
> Just to do some testing for robustness. :)

OK, you hit the nail ;)
I have just noticed I forgot to add your Reported-by: tag and I guess
this is also a stable material. I will repost the patch once Andrew says
he is going to take it.

Thanks

> 
> CAI Qian
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
L3 team 
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
