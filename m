Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9E40F6B025F
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 09:04:51 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y134so162616841pfg.1
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 06:04:51 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id d81si4147634pfb.192.2016.07.15.06.04.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 06:04:50 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id ez1so2676170pab.3
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 06:04:50 -0700 (PDT)
Date: Fri, 15 Jul 2016 23:04:58 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH 00/14] Present useful limits to user (v2)
Message-ID: <20160715130458.GB21685@350D>
Reply-To: bsingharora@gmail.com
References: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Topi Miettinen <toiwoton@gmail.com>
Cc: linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Alexander Graf <agraf@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>, Dave Goodell <dgoodell@cisco.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Alex Williamson <alex.williamson@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Alexei Starovoitov <ast@kernel.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Balbir Singh <bsingharora@gmail.com>, Markus Elfring <elfring@users.sourceforge.net>, "David S. Miller" <davem@davemloft.net>, Nicolas Dichtel <nicolas.dichtel@6wind.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Jiri Slaby <jslaby@suse.cz>, Cyrill Gorcunov <gorcunov@openvz.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Carpenter <dan.carpenter@oracle.com>, Michael Kerrisk <mtk.manpages@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Marcus Gelderie <redmnic@gmail.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Joe Perches <joe@perches.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andi Kleen <ak@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Stas Sergeev <stsp@list.ru>, Amanieu d'Antras <amanieu@gmail.com>, Richard Weinberger <richard@nod.at>, Wang Xiaoqiang <wangxq10@lzu.edu.cn>, Helge Deller <deller@gmx.de>, Mateusz Guzik <mguzik@redhat.com>, Alex Thorlton <athorlton@sgi.com>, Ben Segall <bsegall@google.com>, John Stultz <john.stultz@linaro.org>, Rik van Riel <riel@redhat.com>, Eric B Munson <emunson@akamai.com>, Alexey Klimov <klimov.linux@gmail.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE (KVM) FOR POWERPC" <kvm-ppc@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE (KVM)" <kvm@vger.kernel.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, "open list:INFINIBAND SUBSYSTEM" <linux-rdma@vger.kernel.org>, "open list:FILESYSTEMS (VFS and infrastructure)" <linux-fsdevel@vger.kernel.org>, "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>, "open list:BPF (Safe dynamic programs and tools)" <netdev@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Fri, Jul 15, 2016 at 01:35:47PM +0300, Topi Miettinen wrote:
> Hello,
> 
> There are many basic ways to control processes, including capabilities,
> cgroups and resource limits. However, there are far fewer ways to find out
> useful values for the limits, except blind trial and error.
> 
> This patch series attempts to fix that by giving at least a nice starting
> point from the highwater mark values of the resources in question.
> I looked where each limit is checked and added a call to update the mark
> nearby.
> 
> Example run of program from Documentation/accounting/getdelauys.c:
> 
> ./getdelays -R -p `pidof smartd`
> printing resource accounting
> RLIMIT_CPU=0
> RLIMIT_FSIZE=0
> RLIMIT_DATA=18198528
> RLIMIT_STACK=135168
> RLIMIT_CORE=0
> RLIMIT_RSS=0
> RLIMIT_NPROC=1
> RLIMIT_NOFILE=55
> RLIMIT_MEMLOCK=0
> RLIMIT_AS=130879488
> RLIMIT_LOCKS=0
> RLIMIT_SIGPENDING=0
> RLIMIT_MSGQUEUE=0
> RLIMIT_NICE=0
> RLIMIT_RTPRIO=0
> RLIMIT_RTTIME=0
> 
> ./getdelays -R -C /sys/fs/cgroup/systemd/system.slice/smartd.service/
> printing resource accounting
> sleeping 1, blocked 0, running 0, stopped 0, uninterruptible 0
> RLIMIT_CPU=0
> RLIMIT_FSIZE=0
> RLIMIT_DATA=18198528
> RLIMIT_STACK=135168
> RLIMIT_CORE=0
> RLIMIT_RSS=0
> RLIMIT_NPROC=1
> RLIMIT_NOFILE=55
> RLIMIT_MEMLOCK=0
> RLIMIT_AS=130879488
> RLIMIT_LOCKS=0
> RLIMIT_SIGPENDING=0
> RLIMIT_MSGQUEUE=0
> RLIMIT_NICE=0
> RLIMIT_RTPRIO=0
> RLIMIT_RTTIME=0

Does this mean that rlimit_data and rlimit_stack should be set to the
values as specified by the data above?

Do we expect a smart user space daemon to then tweak the RLIMIT values?

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
