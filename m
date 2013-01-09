Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 6F8556B005A
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 14:32:39 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id un3so2579902obb.21
        for <linux-mm@kvack.org>; Wed, 09 Jan 2013 11:32:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <50EB76DF.5070508@huawei.com>
References: <1357248967-24959-1-git-send-email-tj@kernel.org>
 <50E93554.3070102@huawei.com> <20130107164453.GH3926@htj.dyndns.org> <50EB76DF.5070508@huawei.com>
From: Paul Menage <paul@paulmenage.org>
Date: Wed, 9 Jan 2013 11:32:18 -0800
Message-ID: <CALdu-PCmeXNF7FCVstVBNRzQDgkhBAPnWs0Czt9HOHZ4mT68-A@mail.gmail.com>
Subject: Re: [PATCHSET] cpuset: decouple cpuset locking from cgroup core, take#2
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Tejun Heo <tj@kernel.org>, glommer@parallels.com, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 7, 2013 at 5:31 PM, Li Zefan <lizefan@huawei.com> wrote:
>
> I don't think Paul's still maintaining cpusets. Normally it's Andrew
> that picks up cpuset patches. It's fine you route it through cgroup
> tree.

Yes, I'm sorry - I should have handed on cpusets at the time I had to
hand on cgroups. I was only really ever the maintainer for cpusets
because Paul Jackson asked me to take it over when he retired, as I
understood the cgroups-related parts of it. I never really had a good
grasp of how the some of the lower-level parts of it interacted with
the rest of the system (e.g. offlining, CPUs, scheduler domains, etc)
anyway ...

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
