Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id A34D86B004D
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 10:49:56 -0400 (EDT)
Date: Fri, 13 Apr 2012 16:49:54 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: question about memsw of memory cgroup-subsystem
Message-ID: <20120413144954.GA9227@tiehlicka.suse.cz>
References: <op.wco7ekvhn27o5l@gaoqiang-d1.corp.qihoo.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <op.wco7ekvhn27o5l@gaoqiang-d1.corp.qihoo.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gaoqiang <gaoqiangscut@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org

[CC linux-mm]

Hi,

On Fri 13-04-12 18:00:10, gaoqiang wrote:
> 
> 
> I put a single process into a cgroup and set memory.limit_in_bytes
> to 100M,and memory.memsw.limit_in_bytes to 1G.
> 
> howevery,the process was oom-killed before mem+swap hit 1G. I tried
> many times,and it was killed randomly when memory+swap
> 
> exceed 100M but less than 1G.  what is the matter ?

could you be more specific about your kernel version, workload and could
you provide us with GROUP/memory.stat snapshots taken during your test?

One reason for oom might be that you are hitting the hard limit (you
cannot get over even if memsw limit says more) and you cannot swap out
any pages (e.g. they are mlocked or under writeback).

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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
