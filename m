Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id EC3726B0069
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 09:48:02 -0500 (EST)
Date: Wed, 9 Jan 2013 15:47:58 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V3 4/8] memcg: add per cgroup dirty pages accounting
Message-ID: <20130109144758.GC5095@dhcp22.suse.cz>
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
 <1356456367-14660-1-git-send-email-handai.szj@taobao.com>
 <20130102104421.GC22160@dhcp22.suse.cz>
 <CAFj3OHXKyMO3gwghiBAmbowvqko-JqLtKroX2kzin1rk=q9tZg@mail.gmail.com>
 <alpine.LNX.2.00.1301061135400.29149@eggly.anvils>
 <CAFj3OHVUx0bZyEGQU_CApVbgz7SrX3BQ+0U5fRV=En800wv+cQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFj3OHVUx0bZyEGQU_CApVbgz7SrX3BQ+0U5fRV=En800wv+cQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, dchinner@redhat.com, Sha Zhengju <handai.szj@taobao.com>

On Wed 09-01-13 22:35:12, Sha Zhengju wrote:
[...]
> To my knowledge, each task is forked in root memcg, and there's a
> moving while attaching it to a cgroup. So move_account is also a
> frequent behavior to some extent.

Not really. Every fork/exec is copies the current group (see
cgroup_fork) so there is no moving on that path.
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
