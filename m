Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id E2C086B0037
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 11:10:28 -0400 (EDT)
Received: by mail-ia0-f180.google.com with SMTP id l29so1489456iag.39
        for <linux-mm@kvack.org>; Thu, 11 Apr 2013 08:10:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <51666930.6090702@cn.fujitsu.com>
References: <1365415000-10389-1-git-send-email-linfeng@cn.fujitsu.com>
	<CAE9FiQVaByGOTjLVthRkEze_ekXm5LAKgKdHzrD+q1iYmjgZFQ@mail.gmail.com>
	<51666930.6090702@cn.fujitsu.com>
Date: Thu, 11 Apr 2013 08:10:28 -0700
Message-ID: <CAE9FiQU-zqFdSz-7yq5EgV1YCzyNH_BY36Ym3tdHVEHHY6cdNg@mail.gmail.com>
Subject: Re: [PATCH 0/2] mm: vmemmap: add vmemmap_verify check for hot-add
 node/memory case
From: Yinghai Lu <yinghai@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: Lin Feng <linfeng@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Catalin Marinas <catalin.marinas@arm.com>, will.deacon@arm.com, Arnd Bergmann <arnd@arndb.de>, tony@atomide.com, Ben Hutchings <ben@decadent.org.uk>, linux-arm-kernel@lists.infradead.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Linux MM <linux-mm@kvack.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>

On Thu, Apr 11, 2013 at 12:41 AM, Tang Chen <tangchen@cn.fujitsu.com> wrote:
>
> 3. If we add flag to memblock, we can mark different memory. And I remember
>    you mentioned before that we can use memblock to reserve local node data
>    for node-life-cycle data, like vmemmap, pagetable.
>
>    So are you doing the similar work now ?

No, i did not start it yet.

>
>    If not, I think I can merge it into mine, and push a new patch-set with
>    hot-add, hot-remove code modified to support putting vmemmap, pagetable,
>    pgdat, page_cgroup, ..., on local node.

Need to have it separated with moving_zone.

1. rework memblock to keep alive all the way for hotplug usage.
2. put pagetable and vmemap on the local node range with help of memblock.


Thanks

Yinghai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
