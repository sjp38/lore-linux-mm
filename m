Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 750AE6B026A
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 09:52:59 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p41so74261756lfi.0
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 06:52:59 -0700 (PDT)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id gw5si852352wjb.103.2016.07.15.06.52.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jul 2016 06:52:58 -0700 (PDT)
Received: by mail-wm0-x233.google.com with SMTP id o80so31092786wme.1
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 06:52:58 -0700 (PDT)
Subject: Re: [PATCH 00/14] Present useful limits to user (v2)
References: <1468578983-28229-1-git-send-email-toiwoton@gmail.com>
 <20160715124330.GR30154@twins.programming.kicks-ass.net>
From: Topi Miettinen <toiwoton@gmail.com>
Message-ID: <28b4b919-4f50-d9f6-c5e1-d1e92ea1ba1c@gmail.com>
Date: Fri, 15 Jul 2016 13:52:48 +0000
MIME-Version: 1.0
In-Reply-To: <20160715124330.GR30154@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-kernel@vger.kernel.org, Jonathan Corbet <corbet@lwn.net>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Alexander Graf <agraf@suse.com>, Paolo Bonzini <pbonzini@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>, Doug Ledford <dledford@redhat.com>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>, Dave Goodell <dgoodell@cisco.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Alex Williamson <alex.williamson@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Alexei Starovoitov <ast@kernel.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Balbir Singh <bsingharora@gmail.com>, Markus Elfring <elfring@users.sourceforge.net>, "David S. Miller" <davem@davemloft.net>, Nicolas Dichtel <nicolas.dichtel@6wind.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Jiri Slaby <jslaby@suse.cz>, Cyrill Gorcunov <gorcunov@openvz.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dan Carpenter <dan.carpenter@oracle.com>, Michael Kerrisk <mtk.manpages@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Marcus Gelderie <redmnic@gmail.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Joe Perches <joe@perches.com>, Frederic Weisbecker <fweisbec@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andi Kleen <ak@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Stas Sergeev <stsp@list.ru>, Amanieu d'Antras <amanieu@gmail.com>, Richard Weinberger <richard@nod.at>, Wang Xiaoqiang <wangxq10@lzu.edu.cn>, Helge Deller <deller@gmx.de>, Mateusz Guzik <mguzik@redhat.com>, Alex Thorlton <athorlton@sgi.com>, Ben Segall <bsegall@google.com>, John Stultz <john.stultz@linaro.org>, Rik van Riel <riel@redhat.com>, Eric B Munson <emunson@akamai.com>, Alexey Klimov <klimov.linux@gmail.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Alexander Kuleshov <kuleshovmail@gmail.com>, "open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, "open list:IA64 (Itanium) PLATFORM" <linux-ia64@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE (KVM) FOR POWERPC" <kvm-ppc@vger.kernel.org>, "open list:KERNEL VIRTUAL MACHINE (KVM)" <kvm@vger.kernel.org>, "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, "open list:INFINIBAND SUBSYSTEM" <linux-rdma@vger.kernel.org>, "open list:FILESYSTEMS (VFS and infrastructure)" <linux-fsdevel@vger.kernel.org>, "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>, "open list:BPF (Safe dynamic programs and tools)" <netdev@vger.kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On 07/15/16 12:43, Peter Zijlstra wrote:
> On Fri, Jul 15, 2016 at 01:35:47PM +0300, Topi Miettinen wrote:
>> Hello,
>>
>> There are many basic ways to control processes, including capabilities,
>> cgroups and resource limits. However, there are far fewer ways to find out
>> useful values for the limits, except blind trial and error.
>>
>> This patch series attempts to fix that by giving at least a nice starting
>> point from the highwater mark values of the resources in question.
>> I looked where each limit is checked and added a call to update the mark
>> nearby.
> 
> And how is that useful? Setting things to the high watermark is
> basically the same as not setting the limit at all.

What else would you use, too small limits?

-Topi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
