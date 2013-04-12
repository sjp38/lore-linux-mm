Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 6808C6B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:10:23 -0400 (EDT)
Message-ID: <51675FA1.9000203@cn.fujitsu.com>
Date: Fri, 12 Apr 2013 09:13:05 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] mm: vmemmap: add vmemmap_verify check for hot-add
 node/memory case
References: <1365415000-10389-1-git-send-email-linfeng@cn.fujitsu.com> <CAE9FiQVaByGOTjLVthRkEze_ekXm5LAKgKdHzrD+q1iYmjgZFQ@mail.gmail.com> <51666930.6090702@cn.fujitsu.com> <CAE9FiQU-zqFdSz-7yq5EgV1YCzyNH_BY36Ym3tdHVEHHY6cdNg@mail.gmail.com>
In-Reply-To: <CAE9FiQU-zqFdSz-7yq5EgV1YCzyNH_BY36Ym3tdHVEHHY6cdNg@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Lin Feng <linfeng@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Catalin Marinas <catalin.marinas@arm.com>, will.deacon@arm.com, Arnd Bergmann <arnd@arndb.de>, tony@atomide.com, Ben Hutchings <ben@decadent.org.uk>, linux-arm-kernel@lists.infradead.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>

On 04/11/2013 11:10 PM, Yinghai Lu wrote:
> On Thu, Apr 11, 2013 at 12:41 AM, Tang Chen<tangchen@cn.fujitsu.com>  wro=
te:
>>
>> 3. If we add flag to memblock, we can mark different memory. And I remem=
ber
>>     you mentioned before that we can use memblock to reserve local node =
data
>>     for node-life-cycle data, like vmemmap, pagetable.
>>
>>     So are you doing the similar work now ?
>
> No, i did not start it yet.
>
>>
>>     If not, I think I can merge it into mine, and push a new patch-set w=
ith
>>     hot-add, hot-remove code modified to support putting vmemmap, pageta=
ble,
>>     pgdat, page=5Fcgroup, ..., on local node.
>
> Need to have it separated with moving=5Fzone.
>
> 1. rework memblock to keep alive all the way for hotplug usage.
> 2. put pagetable and vmemap on the local node range with help of memblock.
>

OK=EF=BC=8Cthanks for the comments. I'll merge it into my work and post an =
RFC=20
patch-set soon.

Thanks. :)
=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
