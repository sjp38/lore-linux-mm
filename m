Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id m1PGGqCF009318
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 16:16:52 GMT
Received: from wx-out-0506.google.com (wxcs11.prod.google.com [10.70.120.11])
	by zps35.corp.google.com with ESMTP id m1PGGnJT010706
	for <linux-mm@kvack.org>; Mon, 25 Feb 2008 08:16:51 -0800
Received: by wx-out-0506.google.com with SMTP id s11so1691892wxc.17
        for <linux-mm@kvack.org>; Mon, 25 Feb 2008 08:16:51 -0800 (PST)
Message-ID: <6599ad830802250816m1f83dbeekbe919a60d4b51157@mail.gmail.com>
Date: Mon, 25 Feb 2008 08:16:40 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] Memory Resource Controller Add Boot Option
In-Reply-To: <20080225115550.23920.43199.sendpatchset@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080225115509.23920.66231.sendpatchset@localhost.localdomain>
	 <20080225115550.23920.43199.sendpatchset@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2008 at 3:55 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
>
>  A boot option for the memory controller was discussed on lkml. It is a good
>  idea to add it, since it saves memory for people who want to turn off the
>  memory controller.
>
>  By default the option is on for the following two reasons
>
>  1. It provides compatibility with the current scheme where the memory
>    controller turns on if the config option is enabled
>  2. It allows for wider testing of the memory controller, once the config
>    option is enabled
>
>  We still allow the create, destroy callbacks to succeed, since they are
>  not aware of boot options. We do not populate the directory will
>  memory resource controller specific files.

Would it make more sense to have a generic cgroups boot option for this?

Something like cgroup_disable=xxx, which would be parsed by cgroups
and would cause:

- a "disabled" flag to be set to true in the subsys object (you could
use this in place of the mem_cgroup_on flag)

- prevent the disabled cgroup from being bound to any mounted
hierarchy (so it would be ignored in a mount with no subsystem
options, and a mount with options that specifically pick that
subsystem would give an error)

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
