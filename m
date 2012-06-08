Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 8A6306B0070
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 10:51:50 -0400 (EDT)
Date: Fri, 8 Jun 2012 16:51:47 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memcg cgroup controller & sbrk interaction
Message-ID: <20120608145147.GA15332@tiehlicka.suse.cz>
References: <1339118347.78794.YahooMailNeo@web112018.mail.gq1.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1339118347.78794.YahooMailNeo@web112018.mail.gq1.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ron Chen <ron_chen_123@yahoo.com>
Cc: Linux Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>

On Thu 07-06-12 18:19:07, Ron Chen wrote:
[...]
> However, not only us, but others have found that the memcg controller
> does not cause sbrk(2) or mmap(2) to return error when the cgroup is
> under high memory pressure.

Yes, because memory controller tracks the allocated memory (with page
granularity) rather than address space. So the memory is accounted when
it is faulted in.

> Further, when the amount of free memory is really low, the Linux
> Kernel OOM killer picks something and kills it.

Yes, this is the result of the design when the memory is tracked during
page faults.

> http://www.spinics.net/lists/cgroups/msg02622.html
> 
> 
> We also would like to see if it is technically possible for the
> Virtual Memory Manager to interact with the memory controller
> properly and give us the semantics of setrlimit(2).

What prevents you from using setrlimit from inside the group?

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
