Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id D02196B0062
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 01:38:41 -0400 (EDT)
Received: by mail-vb0-f41.google.com with SMTP id v13so3032981vbk.14
        for <linux-mm@kvack.org>; Sun, 21 Oct 2012 22:38:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAKWKT+Z-SZb1=3rwLm+urs3fghQ3M6pdOR_rzXKCevoad11a5g@mail.gmail.com>
References: <op.wmbi5kbrn27o5l@gaoqiang-d1.corp.qihoo.net>
	<20121019160425.GA10175@dhcp22.suse.cz>
	<CAKWKT+Z-SZb1=3rwLm+urs3fghQ3M6pdOR_rzXKCevoad11a5g@mail.gmail.com>
Date: Mon, 22 Oct 2012 11:08:40 +0530
Message-ID: <CAKTCnzmDhSd-POHSC0wx-ziVPUg9wFverK33Q1_SvCx3Gzuugg@mail.gmail.com>
Subject: Re: process hangs on do_exit when oom happens
From: Balbir Singh <bsingharora@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiang Gao <gaoqiangscut@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Mon, Oct 22, 2012 at 7:46 AM, Qiang Gao <gaoqiangscut@gmail.com> wrote:
> I don't know whether  the process will exit finally, bug this stack lasts
> for hours, which is obviously unnormal.
> The situation:  we use a command calld "cglimit" to fork-and-exec the worker
> process,and the "cglimit" will
> set some limitation on the worker with cgroup. for now,we limit the
> memory,and we also use cpu cgroup,but with
> no limiation,so when the worker is running, the cgroup directory looks like
> following:
>
> /cgroup/memory/worker : this directory limit the memory
> /cgroup/cpu/worker :with no limit,but worker process is in.
>
> for some reason(some other process we didn't consider),  the worker process
> invoke global oom-killer,
> not cgroup-oom-killer.  then the worker process hangs there.
>
> Actually, if we didn't set the worker process into the cpu cgroup, this will
> never happens.
>

You said you don't use CPU limits right? can you also send in the
output of /proc/sched_debug. Can you also send in your
/etc/cgconfig.conf? If the OOM is not caused by cgroup memory limit
and the global system is under pressure in 2.6.32, it can trigger an
OOM.

Also

1. Have you turned off swapping (seems like it) right?
2. Do you have a NUMA policy setup for this task?

Can you also share the .config (not sure if any special patches are
being used) in the version you've mentioned.

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
