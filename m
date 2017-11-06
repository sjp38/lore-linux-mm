Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 09AB16B0253
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 03:10:16 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id s185so9474804oif.16
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 00:10:16 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a2si1356261otd.64.2017.11.06.00.10.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 00:10:15 -0800 (PST)
Subject: Re: POWER: Unexpected fault when writing to brk-allocated memory
References: <f251fc3e-c657-ebe8-acc8-f55ab4caa667@redhat.com>
 <20171105231850.5e313e46@roar.ozlabs.ibm.com>
 <871slcszfl.fsf@linux.vnet.ibm.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <fed9e04f-e69d-df8d-a930-2f71d7814a64@redhat.com>
Date: Mon, 6 Nov 2017 09:10:10 +0100
MIME-Version: 1.0
In-Reply-To: <871slcszfl.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Nicholas Piggin <npiggin@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm <linux-mm@kvack.org>

On 11/06/2017 07:18 AM, Aneesh Kumar K.V wrote:
> We should not return that address, unless we requested with a hint value
> of > 128TB. IIRC we discussed this early during the mmap interface
> change and said, we will return an address > 128T only if the hint
> address is above 128TB (not hint addr + length). I am not sure why
> we are finding us returning and address > 128TB with paca limit set to
> 128TB?

See the memory maps I posted.  I think it was not anticipated that the 
heap could be near the 128 TiB limit because it is placed next to the 
initially mapped object.

I think this could become worse once we have static PIE support because 
static PIE binaries likely have the same memory layout.  (Ordinary PIE 
does not.)

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
