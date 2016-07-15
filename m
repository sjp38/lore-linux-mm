Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 19C886B0261
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 12:57:12 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r190so20011919wmr.0
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 09:57:12 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id 78si21498wms.98.2016.07.15.09.57.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 09:57:11 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id o80so2917961wme.0
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 09:57:10 -0700 (PDT)
Subject: Re: [PATCH 00/14] Present useful limits to user (v2)
References: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
 <20160715124330.GR30154@twins.programming.kicks-ass.net>
 <28b4b919-4f50-d9f6-c5e1-d1e92ea1ba1c@gmail.com>
 <20160715135956.GA3115@twins.programming.kicks-ass.net>
From: Topi Miettinen <toiwoton@gmail.com>
Message-ID: <485128c4-61c6-45ac-7ae2-2d4819697ec4@gmail.com>
Date: Fri, 15 Jul 2016 16:57:00 +0000
MIME-Version: 1.0
In-Reply-To: <20160715135956.GA3115@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Alexander Graf <agraf@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim Kr??m???? <rkrcmar@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>, Dave Goodell <dgoodell@cisco.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Alex Williamson <alex.williamson@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Alexei Starovoitov <ast@kernel.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Balbir Singh <bsingharora@gmail.com>, Markus Elfring <elfring@users.sourceforge.net>, "David S. Miller" <davem@davemloft.net>, Nicolas Dichtel <nicolas.dichtel@6wind.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Jiri Slaby <jslaby@suse.cz>, Cyrill Gorcunov <gorcunov@openvz.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Carpenter <dan.carpenter@oracle.com>, Michael Kerrisk <mtk.manpages@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Marcus Gelderie <redmnic@gmail.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Joe Perches <joe@perches.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andi Kleen <ak@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Stas Sergeev <stsp@list.ru>, Amanieu d'Antras <amanieu@gmail.com>, Richard Weinberger <richard@nod.at>, Wang Xiaoqiang <wangxq10@lzu.edu.cn>, Helge Deller <deller@gmx.de>, Mateusz Guzik <mguzik@redhat.com>, Alex Thorlton <athorlton@sgi.com>, Ben Segall <bsegall@google.com>, John Stultz <john.stultz@linaro.org>, Rik van Riel <riel@redhat.com>, Eric B Munson <emunson@akamai.com>, Alexey Klimov <klimov.linux@gmail.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE (KVM) FOR POWERPC" <kvm-ppc@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE (KVM)" <kvm@vger.kernel.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, "open list:INFINIBAND SUBSYSTEM" <linux-rdma@vger.kernel.org>, "open list:FILESYSTEMS (VFS and infrastructure)" <linux-fsdevel@vger.kernel.org>, "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>, "open list:BPF (Safe dynamic programs and tools)" <netdev@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On 07/15/16 13:59, Peter Zijlstra wrote:
> On Fri, Jul 15, 2016 at 01:52:48PM +0000, Topi Miettinen wrote:
>> On 07/15/16 12:43, Peter Zijlstra wrote:
>>> On Fri, Jul 15, 2016 at 01:35:47PM +0300, Topi Miettinen wrote:
>>>> Hello,
>>>>
>>>> There are many basic ways to control processes, including capabilities,
>>>> cgroups and resource limits. However, there are far fewer ways to find out
>>>> useful values for the limits, except blind trial and error.
>>>>
>>>> This patch series attempts to fix that by giving at least a nice starting
>>>> point from the highwater mark values of the resources in question.
>>>> I looked where each limit is checked and added a call to update the mark
>>>> nearby.
>>>
>>> And how is that useful? Setting things to the high watermark is
>>> basically the same as not setting the limit at all.
>>
>> What else would you use, too small limits?
> 
> That question doesn't make sense.
> 
> What's the point of setting a limit if it ends up being the same as
> no-limit (aka unlimited).

Having a limit is not the same as not having any limits at all. You're
in a way right that good limits don't affect the program normally. But
they can make a difference if the flow is not normal. For example a
successful exploit or a memory leak bug could cause RLIMIT_AS to trigger.

> 
> If you cannot explain; and you have not so far; what use these values
> are, why would we look at the patches.
> 

The use case is to allow system administrators, distro maintainers and
developers to configure systems to use the resource limits. The limits
are not very useful right now, as there is no way to figure out what
values to use. There are a few /proc files to look, for example current
number of file descriptors (for RLIMIT_NOFILE) could be counted via
/proc/pid/fd. But now there is no way to know if there were more in use
at some point. Likewise, a program can use more address space when you
are not looking. The source code does not tell these things explicitly.

-Topi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
