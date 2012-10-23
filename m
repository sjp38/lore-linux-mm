Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 00A2E6B0062
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 05:08:41 -0400 (EDT)
Received: by mail-vb0-f41.google.com with SMTP id v13so4731623vbk.14
        for <linux-mm@kvack.org>; Tue, 23 Oct 2012 02:08:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20121023083556.GB15397@dhcp22.suse.cz>
References: <op.wmbi5kbrn27o5l@gaoqiang-d1.corp.qihoo.net>
	<20121019160425.GA10175@dhcp22.suse.cz>
	<CAKWKT+ZRMHzgCLJ1quGnw-_T1b9OboYKnQdRc2_Z=rdU_PFVtw@mail.gmail.com>
	<20121023083556.GB15397@dhcp22.suse.cz>
Date: Tue, 23 Oct 2012 17:08:40 +0800
Message-ID: <CAKWKT+ZG-Rw5spLUdn74H3QQ1RGrax2B4X_ksZB-OCHY5WXC6w@mail.gmail.com>
Subject: Re: process hangs on do_exit when oom happens
From: Qiang Gao <gaoqiangscut@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, linux-mm@kvack.org, bsingharora@gmail.com

this is just an example to show how to reproduce. actually,the first time I saw
this situation was on a machine with 288G RAM with many tasks running and
we limit 30G for each.  but finanlly, no one exceeds this limit the the system
oom.


On Tue, Oct 23, 2012 at 4:35 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Tue 23-10-12 11:35:52, Qiang Gao wrote:
>> I'm sure this is a global-oom,not cgroup-oom. [the dmesg output in the end]
>
> Yes this is the global oom killer because:
>> cglimit -M 700M ./tt
>> then after global-oom,the process hangs..
>
>> 179184 pages RAM
>
> So you have ~700M of RAM so the memcg limit is basically pointless as it
> cannot be reached...
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
