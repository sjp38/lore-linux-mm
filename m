Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id m279Pr1n002429
	for <linux-mm@kvack.org>; Fri, 7 Mar 2008 01:25:53 -0800
Received: from wx-out-0506.google.com (wxdi26.prod.google.com [10.70.135.26])
	by zps19.corp.google.com with ESMTP id m279PnXJ004419
	for <linux-mm@kvack.org>; Fri, 7 Mar 2008 01:25:52 -0800
Received: by wx-out-0506.google.com with SMTP id i26so717220wxd.31
        for <linux-mm@kvack.org>; Fri, 07 Mar 2008 01:25:52 -0800 (PST)
Message-ID: <6599ad830803070125o1ebfd7d1r728cdadf726ecbe2@mail.gmail.com>
Date: Fri, 7 Mar 2008 01:25:51 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] Add cgroup support for enabling controllers at boot time (v2)
In-Reply-To: <20080307085735.25567.314.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080307085735.25567.314.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 7, 2008 at 12:57 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
>  This doesn't handle early_init subsystems (their "disabled" bit isn't
>  set be,

I think you meant something like

(their "disabled" bit isn't set before their initial "create" call is made)

>  +static int __init cgroup_disable(char *str)
>  +{
>  +       int i;
>  +
>  +       while (*str) {
>  +               for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
>  +                       struct cgroup_subsys *ss = subsys[i];
>  +
>  +                       if (!strncmp(str, ss->name, strlen(ss->name))) {
>  +                               ss->disabled = 1;
>  +                               printk(KERN_INFO "Disabling %s control group"
>  +                                       " subsystem\n", ss->name);
>  +                               break;

Doesn't this mean that cgroup_disable=cpu will disable whichever comes
first out of cpuset, cpuacct or cpu in the subsystem list?

I suggest just sticking with the original simpler version that
required separate cgroup_disabled=foo options for each system that you
want to disable.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
