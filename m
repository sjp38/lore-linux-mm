Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 3DA458D0002
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 10:19:19 -0500 (EST)
Date: Tue, 29 Jan 2013 16:19:15 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: simplify lock of memcg page stat accounting
Message-ID: <20130129151915.GJ29574@dhcp22.suse.cz>
References: <1359198756-3752-1-git-send-email-handai.szj@taobao.com>
 <20130128141010.GD14241@dhcp22.suse.cz>
 <CAFj3OHUE_grS-Syg+ZhYK-W-TksXpqPjQRZC4Ti4+=zSJUEGMA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFj3OHUE_grS-Syg+ZhYK-W-TksXpqPjQRZC4Ti4+=zSJUEGMA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, gthelen@google.com, hannes@cmpxchg.org, hughd@google.com, Sha Zhengju <handai.szj@taobao.com>

On Tue 29-01-13 21:44:44, Sha Zhengju wrote:
> On Mon, Jan 28, 2013 at 10:10 PM, Michal Hocko <mhocko@suse.cz> wrote:
[...]
> >> But CPU-B may do "moving" in advance that
> >> "old_memcg->nr_dirty --" will make old_memcg->nr_dirty incorrect but
> >> soon CPU-A will do "memcg->nr_dirty ++" finally that amend the stats.
> >
> > The counter is per-cpu so we are safe wrt. atomic increments and we can
> > probably tolerate off-by 1 temporal errors (mem_cgroup_read_stat would
> > need val = min(val, 0);).
> 
> Sorry, I cannot catch the 'min(val, 0)' part.. or do you mean max?

Ohh, yeah. Head was telling max, fingers disagreed.
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
