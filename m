Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id B1B556B0038
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 05:20:59 -0400 (EDT)
Received: by mail-qa0-f47.google.com with SMTP id s7so4356785qap.6
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 02:20:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id y10si21900989qaj.18.2014.06.03.02.20.58
        for <linux-mm@kvack.org>;
        Tue, 03 Jun 2014 02:20:59 -0700 (PDT)
Message-ID: <538D9363.7020203@redhat.com>
Date: Tue, 03 Jun 2014 11:20:35 +0200
From: Paolo Bonzini <pbonzini@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 3/3] PPC, KVM, CMA: use general CMA reserved area
 management framework
References: <1401757919-30018-1-git-send-email-iamjoonsoo.kim@lge.com> <1401757919-30018-4-git-send-email-iamjoonsoo.kim@lge.com> <xa1ttx82jx1i.fsf@mina86.com>
In-Reply-To: <xa1ttx82jx1i.fsf@mina86.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Il 03/06/2014 09:02, Michal Nazarewicz ha scritto:
> On Tue, Jun 03 2014, Joonsoo Kim wrote:
>> Now, we have general CMA reserved area management framework,
>> so use it for future maintainabilty. There is no functional change.
>>
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
>

Acked-by: Paolo Bonzini <pbonzini@redhat.com>

Aneesh, can you test this series?

Paolo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
