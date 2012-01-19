Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 9E2E56B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 01:38:18 -0500 (EST)
Received: by iadj38 with SMTP id j38so7360507iad.14
        for <linux-mm@kvack.org>; Wed, 18 Jan 2012 22:38:17 -0800 (PST)
Message-ID: <4F17BA58.2090403@gmail.com>
Date: Thu, 19 Jan 2012 14:38:16 +0800
From: Sha <handai.szj@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch 2/2] mm: memcg: hierarchical soft limit reclaim
References: <1326207772-16762-3-git-send-email-hannes@cmpxchg.org> <CALWz4izwNBN_qcSsqg-qYw-Esc9vBL3=4cv3Wsg1jf6001_fWQ@mail.gmail.com> <20120112085904.GG24386@cmpxchg.org> <CALWz4iz3sQX+pCr19rE3_SwV+pRFhDJ7Lq-uJuYBq6u3mRU3AQ@mail.gmail.com> <20120113224424.GC1653@cmpxchg.org> <4F158418.2090509@gmail.com> <20120117145348.GA3144@cmpxchg.org> <CAFj3OHWY2Biw54gaGeH5fkxzgOhxn7NAibeYT_Jmga-_ypNSRg@mail.gmail.com> <20120118092509.GI24386@cmpxchg.org> <4F16AC27.1080906@gmail.com> <20120118152708.GG31112@tiehlicka.suse.cz>
In-Reply-To: <20120118152708.GG31112@tiehlicka.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 01/18/2012 11:27 PM, Michal Hocko wrote:
> On Wed 18-01-12 19:25:27, Sha wrote:
> [...]
>> Er... I'm even more confused: mem_cgroup_soft_limit_reclaim indeed
>> choses the biggest soft-limit excessor first, but in the succeeding reclaim
>> mem_cgroup_hierarchical_reclaim just selects a child cgroup  by css_id
> mem_cgroup_soft_limit_reclaim picks up the hierarchy root (most
> excessing one) and mem_cgroup_hierarchical_reclaim reclaims from that
> subtree). It doesn't care who exceeds the soft limit under that
> hierarchy it just tries to push the root under its limit as much as it
> can. This is what Johannes tried to explain in the other email in the
> thred.
yeah, I finally twig what  he meant... I'm not quite familiar with this 
part.
Thanks a lot for the explanation. :-)

Sha
>> which has nothing to do with soft limit (see mem_cgroup_select_victim).
>> IMHO, it's not a genuine hierarchical reclaim.
> It is hierarchical because it iterates over hierarchy it is not and
> never was recursively soft-hierarchical...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
