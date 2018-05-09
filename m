Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 73F206B0327
	for <linux-mm@kvack.org>; Tue,  8 May 2018 21:57:11 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id u10-v6so9411215pgp.8
        for <linux-mm@kvack.org>; Tue, 08 May 2018 18:57:11 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id v12-v6si24807951plo.264.2018.05.08.18.57.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 08 May 2018 18:57:10 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 8/8] mm/pkeys, x86, powerpc: Display pkey in smaps if arch supports pkeys
In-Reply-To: <cd58dbfe-55f9-bb9a-d907-0f92740a8c2e@intel.com>
References: <20180508145948.9492-1-mpe@ellerman.id.au> <20180508145948.9492-9-mpe@ellerman.id.au> <cd58dbfe-55f9-bb9a-d907-0f92740a8c2e@intel.com>
Date: Wed, 09 May 2018 11:57:08 +1000
Message-ID: <87lgctzj4b.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linuxram@us.ibm.com
Cc: mingo@redhat.com, linuxppc-dev@ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

Dave Hansen <dave.hansen@intel.com> writes:

> On 05/08/2018 07:59 AM, Michael Ellerman wrote:
>> Currently the architecture specific code is expected to display the
>> protection keys in smap for a given vma. This can lead to redundant
>> code and possibly to divergent formats in which the key gets
>> displayed.
>> 
>> This patch changes the implementation. It displays the pkey only if
>> the architecture support pkeys, i.e arch_pkeys_enabled() returns true.
>
>
> For this, along with 6/8 and 7/8:
>
> Reviewed-by: Dave Hansen <dave.hansen@intel.com>

Thanks for reviewing them all.

cheers
