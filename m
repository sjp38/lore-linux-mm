Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id A745D6B0035
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 13:00:12 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id up15so1367891pbc.16
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 10:00:12 -0700 (PDT)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [122.248.162.2])
        by mx.google.com with ESMTPS id zv2si13929637pbb.131.2014.06.05.10.00.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 10:00:10 -0700 (PDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 5 Jun 2014 22:30:06 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 10BCF1258054
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 22:29:23 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s55H0Hhe6816236
	for <linux-mm@kvack.org>; Thu, 5 Jun 2014 22:30:17 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s55H03Yr025421
	for <linux-mm@kvack.org>; Thu, 5 Jun 2014 22:30:04 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 3/3] PPC, KVM, CMA: use general CMA reserved area management framework
In-Reply-To: <538D9363.7020203@redhat.com>
References: <1401757919-30018-1-git-send-email-iamjoonsoo.kim@lge.com> <1401757919-30018-4-git-send-email-iamjoonsoo.kim@lge.com> <xa1ttx82jx1i.fsf@mina86.com> <538D9363.7020203@redhat.com>
Date: Thu, 05 Jun 2014 22:30:02 +0530
Message-ID: <8761kfuwa5.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Paolo Bonzini <pbonzini@redhat.com> writes:

> Il 03/06/2014 09:02, Michal Nazarewicz ha scritto:
>> On Tue, Jun 03 2014, Joonsoo Kim wrote:
>>> Now, we have general CMA reserved area management framework,
>>> so use it for future maintainabilty. There is no functional change.
>>>
>>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>
>> Acked-by: Michal Nazarewicz <mina86@mina86.com>
>>
>
> Acked-by: Paolo Bonzini <pbonzini@redhat.com>
>
> Aneesh, can you test this series?

Sorry for the late reply. I will test this and update here.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
