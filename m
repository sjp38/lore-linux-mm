Message-ID: <47DDCDA7.4020108@cn.fujitsu.com>
Date: Mon, 17 Mar 2008 10:47:19 +0900
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC][0/3] Virtual address space control for cgroups
References: <20080316172942.8812.56051.sendpatchset@localhost.localdomain> <6599ad830803161626q1fcf261bta52933bb5e7a6bdd@mail.gmail.com>
In-Reply-To: <6599ad830803161626q1fcf261bta52933bb5e7a6bdd@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On Mon, Mar 17, 2008 at 1:29 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> This is an early patchset for virtual address space control for cgroups.
>>  The patches are against 2.6.25-rc5-mm1 and have been tested on top of
>>  User Mode Linux.
> 
> What's the performance hit of doing these accounting checks on every
> mmap/munmap? If it's not totally lost in the noise, couldn't it be
> made a separate control group, so that it could be just enabled (and
> the performance hit taken) for users that actually want it?
> 

It will be code duplication to make it a new subsystem, and it will be useful
to control both of them, am I right? :)

So could we just add a CONFIG to this patch series, like:
	CONFIG_CGROUP_MEM_RES_AS_CTLR
?

> Paul
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
