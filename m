Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9E2FD6B02B4
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 11:28:00 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id l82so15648916ywc.1
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 08:28:00 -0700 (PDT)
Received: from mail-yw0-x22f.google.com (mail-yw0-x22f.google.com. [2607:f8b0:4002:c05::22f])
        by mx.google.com with ESMTPS id v18si703698ybd.252.2017.08.10.08.27.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Aug 2017 08:27:57 -0700 (PDT)
Received: by mail-yw0-x22f.google.com with SMTP id s143so6800528ywg.1
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 08:27:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170810114052.GP23863@dhcp22.suse.cz>
References: <20170801124111.28881-1-mhocko@kernel.org> <20170807070029.GD32434@dhcp22.suse.cz>
 <CAPcyv4gYGohbfme8Ouih_L2mzDiz=7g-KTTwmQNZaw=VXxB4uQ@mail.gmail.com> <20170810114052.GP23863@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 10 Aug 2017 08:27:56 -0700
Message-ID: <CAPcyv4jxdhJ0VSViqKxBzD0-H+3dvrWh3OOmM1diX7i_go_4Mg@mail.gmail.com>
Subject: Re: [RFC PATCH v2 0/6] mm, memory_hotplug: allocate memmap from
 hotadded memory
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Catalin Marinas <catalin.marinas@arm.com>, Fenghua Yu <fenghua.yu@intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Will Deacon <will.deacon@arm.com>, X86 ML <x86@kernel.org>

On Thu, Aug 10, 2017 at 4:40 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Tue 08-08-17 13:01:36, Dan Williams wrote:
>> On Mon, Aug 7, 2017 at 12:00 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> > Any comments? Especially for the arch specific? Has anybody had a chance
>> > to test this? I do not want to rush this but I would be really glag if
>> > we could push this work in 4.14 merge window.
>>
>> Hi Michal,
>>
>> I'm interested in taking a look at this especially if we might be able
>> to get rid of vmem_altmap, but this is currently stuck behind some
>> other work in my queue. I'll try to circle back in the next couple
>> weeks.
>
> Well, vmem_altmap was there and easy to reuse. Replacing with something
> else is certainly possible but I really need something to hook a
> dedicated allocator into vmemmap code.

Oh, you're reusing it, that's great. Then I definitely got the wrong
impression from the first glance at the patch set, I'll dig deeper.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
