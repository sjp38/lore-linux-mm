Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 667736B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 10:27:11 -0500 (EST)
Date: Wed, 18 Jan 2012 16:27:08 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/2] mm: memcg: hierarchical soft limit reclaim
Message-ID: <20120118152708.GG31112@tiehlicka.suse.cz>
References: <1326207772-16762-3-git-send-email-hannes@cmpxchg.org>
 <CALWz4izwNBN_qcSsqg-qYw-Esc9vBL3=4cv3Wsg1jf6001_fWQ@mail.gmail.com>
 <20120112085904.GG24386@cmpxchg.org>
 <CALWz4iz3sQX+pCr19rE3_SwV+pRFhDJ7Lq-uJuYBq6u3mRU3AQ@mail.gmail.com>
 <20120113224424.GC1653@cmpxchg.org>
 <4F158418.2090509@gmail.com>
 <20120117145348.GA3144@cmpxchg.org>
 <CAFj3OHWY2Biw54gaGeH5fkxzgOhxn7NAibeYT_Jmga-_ypNSRg@mail.gmail.com>
 <20120118092509.GI24386@cmpxchg.org>
 <4F16AC27.1080906@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F16AC27.1080906@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha <handai.szj@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 18-01-12 19:25:27, Sha wrote:
[...]
> Er... I'm even more confused: mem_cgroup_soft_limit_reclaim indeed
> choses the biggest soft-limit excessor first, but in the succeeding reclaim
> mem_cgroup_hierarchical_reclaim just selects a child cgroup  by css_id

mem_cgroup_soft_limit_reclaim picks up the hierarchy root (most
excessing one) and mem_cgroup_hierarchical_reclaim reclaims from that
subtree). It doesn't care who exceeds the soft limit under that
hierarchy it just tries to push the root under its limit as much as it
can. This is what Johannes tried to explain in the other email in the
thred.

> which has nothing to do with soft limit (see mem_cgroup_select_victim).
> IMHO, it's not a genuine hierarchical reclaim.

It is hierarchical because it iterates over hierarchy it is not and
never was recursively soft-hierarchical...

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
