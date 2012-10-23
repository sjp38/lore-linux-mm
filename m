Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 57AB86B0070
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 05:43:20 -0400 (EDT)
Date: Tue, 23 Oct 2012 11:43:17 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: process hangs on do_exit when oom happens
Message-ID: <20121023094317.GC15397@dhcp22.suse.cz>
References: <op.wmbi5kbrn27o5l@gaoqiang-d1.corp.qihoo.net>
 <20121019160425.GA10175@dhcp22.suse.cz>
 <CAKWKT+ZRMHzgCLJ1quGnw-_T1b9OboYKnQdRc2_Z=rdU_PFVtw@mail.gmail.com>
 <20121023083556.GB15397@dhcp22.suse.cz>
 <CAKWKT+ZG-Rw5spLUdn74H3QQ1RGrax2B4X_ksZB-OCHY5WXC6w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKWKT+ZG-Rw5spLUdn74H3QQ1RGrax2B4X_ksZB-OCHY5WXC6w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiang Gao <gaoqiangscut@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, linux-mm@kvack.org, bsingharora@gmail.com

On Tue 23-10-12 17:08:40, Qiang Gao wrote:
> this is just an example to show how to reproduce. actually,the first time I saw
> this situation was on a machine with 288G RAM with many tasks running and
> we limit 30G for each.  but finanlly, no one exceeds this limit the the system
> oom.

Yes but mentioning memory controller then might be misleading... It
seems that the only factor in your load is the cpu controller.

And please stop top-posting. It makes the discussion messy.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
