Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id CBC896B015E
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 09:24:05 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so5899530wib.11
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 06:24:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id i5si21993049wiw.11.2014.06.11.06.23.59
        for <linux-mm@kvack.org>;
        Wed, 11 Jun 2014 06:24:00 -0700 (PDT)
Date: Wed, 11 Jun 2014 09:23:37 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: Re: [PATCH] x86: numa: drop ZONE_ALIGN
Message-ID: <20140611092337.35794bc0@redhat.com>
In-Reply-To: <CAE9FiQUWZxvCS82cH=n-NF+nhTQ83J+7M3gHdXGu2S1Qk3xL_g@mail.gmail.com>
References: <20140608181436.17de69ac@redhat.com>
	<CAE9FiQXpUbAOinEK-1PSFyGKqpC_FHN0sjP0xvD0ChrXR5GdAw@mail.gmail.com>
	<20140609150353.75eff02b@redhat.com>
	<CAE9FiQUWZxvCS82cH=n-NF+nhTQ83J+7M3gHdXGu2S1Qk3xL_g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>


Yinghai, sorry for my late reply.

On Mon, 9 Jun 2014 15:13:41 -0700
Yinghai Lu <yinghai@kernel.org> wrote:

> On Mon, Jun 9, 2014 at 12:03 PM, Luiz Capitulino <lcapitulino@redhat.com> wrote:
> > On Sun, 8 Jun 2014 18:29:11 -0700
> > Yinghai Lu <yinghai@kernel.org> wrote:
> >
> >> On Sun, Jun 8, 2014 at 3:14 PM, Luiz Capitulino <lcapitulino@redhat.com> wrote:
> > [    0.000000] e820: BIOS-provided physical RAM map:
> > [    0.000000] BIOS-e820: [mem 0x0000000000000000-0x000000000009fbff] usable
> > [    0.000000] BIOS-e820: [mem 0x000000000009fc00-0x000000000009ffff] reserved
> > [    0.000000] BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
> > [    0.000000] BIOS-e820: [mem 0x0000000000100000-0x000000003ffeffff] usable
> > [    0.000000] BIOS-e820: [mem 0x000000003fff0000-0x000000003fffefff] ACPI data
> > [    0.000000] BIOS-e820: [mem 0x000000003ffff000-0x000000003fffffff] ACPI NVS
> > [    0.000000] BIOS-e820: [mem 0x0000000040200000-0x00000000801fffff] usable
> ...
> > [    0.000000] SRAT: PXM 0 -> APIC 0x00 -> Node 0
> > [    0.000000] SRAT: PXM 0 -> APIC 0x01 -> Node 0
> > [    0.000000] SRAT: PXM 1 -> APIC 0x02 -> Node 1
> > [    0.000000] SRAT: PXM 1 -> APIC 0x03 -> Node 1
> > [    0.000000] SRAT: Node 0 PXM 0 [mem 0x00000000-0x3fffffff]
> > [    0.000000] SRAT: Node 1 PXM 1 [mem 0x40200000-0x801fffff]
> > [    0.000000] Initmem setup node 0 [mem 0x00000000-0x3fffffff]
> > [    0.000000]   NODE_DATA [mem 0x3ffec000-0x3ffeffff]
> > [    0.000000] Initmem setup node 1 [mem 0x40800000-0x801fffff]
> > [    0.000000]   NODE_DATA [mem 0x801fb000-0x801fefff]
> 
> so node1 start is aligned to 8M from 2M
> 
> node0: [0, 1G)
> node1: [1G+2M, 2G+2M)
> 
> The zone should not cross the 8M boundary?

Yes, but the question is: why?

> In the case should we trim the memblock for numa to be 8M alignment ?

My current thinking, after discussing this with David, is to just page
align the memory range. This should fix the hyperv-triggered bug in 2.6.32
and seems to be the right thing for upstream too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
