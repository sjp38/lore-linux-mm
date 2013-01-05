Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 3E0D36B005D
	for <linux-mm@kvack.org>; Sat,  5 Jan 2013 05:45:43 -0500 (EST)
Date: Sat, 5 Jan 2013 11:45:38 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V3 2/8] Make TestSetPageDirty and dirty page accounting
 in one func
Message-ID: <20130105104538.GB24698@dhcp22.suse.cz>
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com>
 <1356456156-14535-1-git-send-email-handai.szj@taobao.com>
 <20130102090803.GB22160@dhcp22.suse.cz>
 <CAFj3OHUCQkqB2+ky9wxFpkNYcn2=6t9Qd7XFf3RBY0F4Wxyqcg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFj3OHUCQkqB2+ky9wxFpkNYcn2=6t9Qd7XFf3RBY0F4Wxyqcg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, dchinner@redhat.com, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, Sha Zhengju <handai.szj@taobao.com>

On Sat 05-01-13 10:49:00, Sha Zhengju wrote:
[...]
> >> Here is some test numbers that before/after this patch:
> >> Test steps(Mem-4g, ext4):
> >> drop_cache; sync
> >> fio (ioengine=sync/write/buffered/bs=4k/size=1g/numjobs=2/group_reporting/thread)
> >
> > Could also add some rationale why you think this test is relevant?
> >
> 
> The test is aiming at finding the impact of performance due to lock
> contention by writing parallel
> to the same file. I'll add the reason next version too.

Please make sure to describe which locks are exercised during that test
and how much.

Thanks
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
