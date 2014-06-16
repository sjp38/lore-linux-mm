Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 38C8E6B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 03:04:48 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id eu11so4197769pac.11
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 00:04:47 -0700 (PDT)
Received: from e28smtp05.in.ibm.com (e28smtp05.in.ibm.com. [122.248.162.5])
        by mx.google.com with ESMTPS id rt15si12663863pab.21.2014.06.16.00.04.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 00:04:47 -0700 (PDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 16 Jun 2014 12:34:43 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 797C7394005E
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 12:34:39 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5G74qnv57475134
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 12:34:52 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s5G74bEo026894
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 12:34:38 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 00/10] CMA: generalize CMA reserved area management code
In-Reply-To: <20140616053209.GG23210@js1304-P5Q-DELUXE>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com> <87r42seyvg.fsf@linux.vnet.ibm.com> <20140616053209.GG23210@js1304-P5Q-DELUXE>
Date: Mon, 16 Jun 2014 12:34:14 +0530
Message-ID: <87tx7lcp3l.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> On Sat, Jun 14, 2014 at 12:55:39PM +0530, Aneesh Kumar K.V wrote:
>> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
>> 
>> > Currently, there are two users on CMA functionality, one is the DMA
>> > subsystem and the other is the kvm on powerpc. They have their own code
>> > to manage CMA reserved area even if they looks really similar.
>> > From my guess, it is caused by some needs on bitmap management. Kvm side
>> > wants to maintain bitmap not for 1 page, but for more size. Eventually it
>> > use bitmap where one bit represents 64 pages.
>> >
>> > When I implement CMA related patches, I should change those two places
>> > to apply my change and it seem to be painful to me. I want to change
>> > this situation and reduce future code management overhead through
>> > this patch.
>> >
>> > This change could also help developer who want to use CMA in their
>> > new feature development, since they can use CMA easily without
>> > copying & pasting this reserved area management code.
>> >
>> > v2:
>> >   Although this patchset looks very different with v1, the end result,
>> >   that is, mm/cma.c is same with v1's one. So I carry Ack to patch 6-7.
>> >
>> > Patch 1-5 prepare some features to cover ppc kvm's requirements.
>> > Patch 6-7 generalize CMA reserved area management code and change users
>> > to use it.
>> > Patch 8-10 clean-up minor things.
>> 
>> 
>> I wanted to test the ppc changes and found that the patch series doesn't apply
>> against v3.15 . Do you have a kernel tree which I can clone to test this
>> series ?
>
> This is based on linux-next -next-20140610.
> And my tree is on following link.
>
> https://github.com/JoonsooKim/linux/tree/cma-general-v2.0-next-20140610
>
> But, I think I'm late, because you have already added a Tested-by tag.

linux-next kexec is broken on ppc64, hence I hand picked few of
dependent patches for dma CMA on top of 3.15 and used that for testing.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
