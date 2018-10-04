Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9D2ED6B000E
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 04:12:37 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id x75-v6so7288002qka.18
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 01:12:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r2-v6si2696580qkd.14.2018.10.04.01.12.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Oct 2018 01:12:36 -0700 (PDT)
Subject: Re: [PATCH RFC] mm/memory_hotplug: Introduce memory block types
References: <20180928150357.12942-1-david@redhat.com>
 <20181001084038.GD18290@dhcp22.suse.cz>
 <d54a8509-725f-f771-72f0-15a9d93e8a49@redhat.com>
 <20181002134734.GT18290@dhcp22.suse.cz>
 <98fb8d65-b641-2225-f842-8804c6f79a06@redhat.com>
 <8736tndubn.fsf@vitty.brq.redhat.com> <20181003134444.GH4714@dhcp22.suse.cz>
 <87zhvvcf3b.fsf@vitty.brq.redhat.com> <20181003142444.GJ4714@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Message-ID: <db839c89-0ce8-52f8-8199-4a28197a91e8@redhat.com>
Date: Thu, 4 Oct 2018 10:12:22 +0200
MIME-Version: 1.0
In-Reply-To: <20181003142444.GJ4714@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Vitaly Kuznetsov <vkuznets@redhat.com>
Cc: Kate Stewart <kstewart@linuxfoundation.org>, Rich Felker <dalias@libc.org>, linux-ia64@vger.kernel.org, linux-sh@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Balbir Singh <bsingharora@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, Pavel Tatashin <pavel.tatashin@microsoft.com>, Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>, Rashmica Gupta <rashmica.g@gmail.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-s390@vger.kernel.org, Michael Neuling <mikey@neuling.org>, Stephen Hemminger <sthemmin@microsoft.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Michael Ellerman <mpe@ellerman.id.au>, linux-acpi@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, xen-devel@lists.xenproject.org, Rob Herring <robh@kernel.org>, Len Brown <lenb@kernel.org>, Fenghua Yu <fenghua.yu@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Haiyang Zhang <haiyangz@microsoft.com>, Dan Williams <dan.j.williams@intel.com>, =?UTF-8?Q?Jonathan_Neusch=c3=a4fer?= <j.neuschaefer@gmx.net>, Nicholas Piggin <npiggin@gmail.com>, Joe Perches <joe@perches.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Oscar Salvador <osalvador@suse.de>, Juergen Gross <jgross@suse.com>, Tony Luck <tony.luck@intel.com>, Mathieu Malaterre <malat@debian.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-kernel@vger.kernel.org, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Philippe Ombredanne <pombredanne@nexb.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, devel@linuxdriverproject.org, Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 03/10/2018 16:24, Michal Hocko wrote:
> On Wed 03-10-18 15:52:24, Vitaly Kuznetsov wrote:
> [...]
>>> As David said some of the memory cannot be onlined without further steps
>>> (e.g. when it is standby as David called it) and then I fail to see how
>>> eBPF help in any way.
>>
>> and also, we can fight till the end of days here trying to come up with
>> an onlining solution which would work for everyone and eBPF would move
>> this decision to distro level.
> 
> The point is that there is _no_ general onlining solution. This is
> basically policy which belongs to the userspace.
> 

Vitalys point was that this policy is to be formulated by user space via
eBPF and handled by the kernel. So the work of formulating the policy
would still have to be done by user space.

I guess the only problem this would partially solve is onlining of
memory failing as we can no longer fork in user space. Just as you said,
I also think this is rather some serious misconfiguration. We will
already most probably have other applications triggering OOM already.

-- 

Thanks,

David / dhildenb
