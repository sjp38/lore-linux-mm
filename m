Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id m9NLK82q001293
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 22:20:08 +0100
Received: from rv-out-0708.google.com (rvbf25.prod.google.com [10.140.82.25])
	by zps76.corp.google.com with ESMTP id m9NLJQXn022048
	for <linux-mm@kvack.org>; Thu, 23 Oct 2008 14:20:06 -0700
Received: by rv-out-0708.google.com with SMTP id f25so504034rvb.50
        for <linux-mm@kvack.org>; Thu, 23 Oct 2008 14:20:05 -0700 (PDT)
Message-ID: <6599ad830810231420t675fa8aalc13f7357ec876c9e@mail.gmail.com>
Date: Thu, 23 Oct 2008 14:20:05 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][PATCH 2/11] cgroup: make cgroup kconfig as submenu
In-Reply-To: <20081023180057.791eeba4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081023175800.73afc957.kamezawa.hiroyu@jp.fujitsu.com>
	 <20081023180057.791eeba4.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

On Thu, Oct 23, 2008 at 2:00 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> @@ -337,6 +284,8 @@ config GROUP_SCHED
>        help
>          This feature lets CPU scheduler recognize task groups and control CPU
>          bandwidth allocation to such task groups.
> +         For allowing to make a group from arbitrary set of processes, use
> +         CONFIG_CGROUPS. (See Control Group support.)

Please can we make this:

In order to create a scheduler group from an arbitrary set of
processes, use CONFIG_CGROUPS (See Control Group support).

>
> +         This option will let you use process cgroup subsystems
> +         such as Cpusets

This option adds support for grouping sets of processes together, for
use with process control subsystems such as Cpusets, CFS, memory
controls or device isolation.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
