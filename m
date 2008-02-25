Received: from zps19.corp.google.com (zps19.corp.google.com [172.25.146.19])
	by smtp-out.google.com with ESMTP id m1PHW1hr026299
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 09:32:01 -0800
Received: from nf-out-0910.google.com (nfcd3.prod.google.com [10.48.105.3])
	by zps19.corp.google.com with ESMTP id m1PHVZmJ001755
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 09:32:00 -0800
Received: by nf-out-0910.google.com with SMTP id d3so976892nfc.0
        for <linux-mm@kvack.org>; Mon, 25 Feb 2008 09:32:00 -0800 (PST)
Message-ID: <6599ad830802250932s5eaa3bcchbfc49fe0e76d3f7d@mail.gmail.com>
Date: Mon, 25 Feb 2008 09:32:00 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] Memory Resource Controller Add Boot Option
In-Reply-To: <47C2F86A.9010709@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080225115509.23920.66231.sendpatchset@localhost.localdomain>
	 <20080225115550.23920.43199.sendpatchset@localhost.localdomain>
	 <6599ad830802250816m1f83dbeekbe919a60d4b51157@mail.gmail.com>
	 <47C2F86A.9010709@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2008 at 9:18 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
>  I thought about it, but it did not work out all that well. The reason being,
>  that the memory controller is called in from places besides cgroup.
>  mem_cgroup_charge_common() for example is called from several places in mm.
>  Calling into cgroups to check, enabled/disabled did not seem right.

You wouldn't need to call into cgroups - if it's a flag in the subsys
object (which is defined in memcontrol.c) you'd just say

if (mem_cgroup_subsys.disabled) {
...
}

I'll send out a prototype for comment.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
