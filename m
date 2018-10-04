Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5792E6B000A
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 02:28:18 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i76-v6so5303406pfk.14
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 23:28:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u37-v6si3355453pgl.585.2018.10.03.23.28.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 23:28:17 -0700 (PDT)
Date: Thu, 4 Oct 2018 08:28:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC] mm/memory_hotplug: Introduce memory block types
Message-ID: <20181004062811.GC22173@dhcp22.suse.cz>
References: <20180928150357.12942-1-david@redhat.com>
 <20181001084038.GD18290@dhcp22.suse.cz>
 <d54a8509-725f-f771-72f0-15a9d93e8a49@redhat.com>
 <20181002134734.GT18290@dhcp22.suse.cz>
 <98fb8d65-b641-2225-f842-8804c6f79a06@redhat.com>
 <20181003135407.GI4714@dhcp22.suse.cz>
 <9fef1f7d-2d7c-03f1-00e3-5fa657eda019@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9fef1f7d-2d7c-03f1-00e3-5fa657eda019@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, xen-devel@lists.xenproject.org, devel@linuxdriverproject.org, linux-acpi@vger.kernel.org, linux-sh@vger.kernel.org, linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "K. Y. Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nicholas Piggin <npiggin@gmail.com>, Jonathan =?iso-8859-1?Q?Neusch=E4fer?= <j.neuschaefer@gmx.net>, Joe Perches <joe@perches.com>, Michael Neuling <mikey@neuling.org>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Balbir Singh <bsingharora@gmail.com>, Rashmica Gupta <rashmica.g@gmail.com>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Rob Herring <robh@kernel.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, "mike.travis@hpe.com" <mike.travis@hpe.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Oscar Salvador <osalvador@suse.de>, Mathieu Malaterre <malat@debian.org>

On Wed 03-10-18 19:00:29, David Hildenbrand wrote:
[...]
> Let me rephrase: You state that user space has to make the decision and
> that user should be able to set/reconfigure rules. That is perfectly fine.
> 
> But then we should give user space access to sufficient information to
> make a decision. This might be the type of memory as we learned (what
> some part of this patch proposes), but maybe later more, e.g. to which
> physical device memory belongs (e.g. to hotplug it all movable or all
> normal) ...

I am pretty sure that user knows he/she wants to use ballooning in
HyperV or Xen, or that the memory hotplug should be used as a "RAS"
feature to allow add and remove DIMMs for reliability. Why shouldn't we
have a package to deploy an appropriate set of udev rules for each of
those usecases? I am pretty sure you need some other plumbing to enable
them anyway (e.g. RAS would require to have movable_node kernel
parameters, ballooning a kernel module etc.).

Really, one udev script to rule them all will simply never work.
-- 
Michal Hocko
SUSE Labs
