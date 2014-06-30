Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id A5B656B0031
	for <linux-mm@kvack.org>; Sun, 29 Jun 2014 21:44:43 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id g10so7406319pdj.0
        for <linux-mm@kvack.org>; Sun, 29 Jun 2014 18:44:43 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id rz10si21351899pbc.56.2014.06.29.18.44.41
        for <linux-mm@kvack.org>;
        Sun, 29 Jun 2014 18:44:42 -0700 (PDT)
Message-ID: <53B0C13C.20206@cn.fujitsu.com>
Date: Mon, 30 Jun 2014 09:45:32 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 1/1] Move two pinned pages to non-movable node in
 kvm.
References: <1403070600-6083-1-git-send-email-tangchen@cn.fujitsu.com> <20140618061230.GA10948@minantech.com> <53A136C4.5070206@cn.fujitsu.com> <20140619092031.GA429@minantech.com> <20140619190024.GA3887@amt.cnet> <20140620111509.GE20764@minantech.com> <20140620125326.GA22283@amt.cnet> <20140620142622.GA28698@minantech.com> <20140620203146.GA6580@amt.cnet> <20140620203903.GA7838@amt.cnet>
In-Reply-To: <20140620203903.GA7838@amt.cnet>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcelo Tosatti <mtosatti@redhat.com>
Cc: Gleb Natapov <gleb@kernel.org>, pbonzini@redhat.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, mgorman@suse.de, yinghai@kernel.org, isimatu.yasuaki@jp.fujitsu.com, guz.fnst@cn.fujitsu.com, laijs@cn.fujitsu.com, kvm@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Avi Kivity <avi.kivity@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>

On 06/21/2014 04:39 AM, Marcelo Tosatti wrote:
> On Fri, Jun 20, 2014 at 05:31:46PM -0300, Marcelo Tosatti wrote:
>>> IIRC your shadow page pinning patch series support flushing of ptes
>>> by mmu notifier by forcing MMU reload and, as a result, faulting in of
>>> pinned pages during next entry.  Your patch series does not pin pages
>>> by elevating their page count.
>>
>> No but PEBS series does and its required to stop swap-out
>> of the page.
>
> Well actually no because of mmu notifiers.
>
> Tang, can you implement mmu notifiers for the other breaker of
> mem hotplug ?

Hi Marcelo,

I made a patch to update ept and apic pages when finding them in the
next ept violation. And I also updated the APIC_ACCESS_ADDR phys_addr.
The pages can be migrated, but the guest crached.

How do I stop guest from access apic pages in mmu_notifier when the
page migration starts ?  Do I need to stop all the vcpus by set vcpu
state to KVM_MP_STATE_HALTED ?  If so, the vcpu will not able to go
to the next ept violation.

So, may I write any specific value into APIC_ACCESS_ADDR to stop guest
from access to apic page ?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
