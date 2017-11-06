Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5D16B0253
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 03:11:41 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id 14so9605911oii.2
        for <linux-mm@kvack.org>; Mon, 06 Nov 2017 00:11:41 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z7si1222502otb.330.2017.11.06.00.11.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Nov 2017 00:11:40 -0800 (PST)
Subject: Re: POWER: Unexpected fault when writing to brk-allocated memory
References: <f251fc3e-c657-ebe8-acc8-f55ab4caa667@redhat.com>
 <20171105231850.5e313e46@roar.ozlabs.ibm.com>
 <871slcszfl.fsf@linux.vnet.ibm.com>
 <20171106174707.19f6c495@roar.ozlabs.ibm.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <24b93038-76f7-33df-d02e-facb0ce61cd2@redhat.com>
Date: Mon, 6 Nov 2017 09:11:37 +0100
MIME-Version: 1.0
In-Reply-To: <20171106174707.19f6c495@roar.ozlabs.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, linux-mm <linux-mm@kvack.org>

On 11/06/2017 07:47 AM, Nicholas Piggin wrote:
> "You get < 128TB unless explicitly requested."
> 
> Simple, reasonable, obvious rule. Avoids breaking apps that store
> some bits in the top of pointers (provided that memory allocator
> userspace libraries also do the right thing).

So brk would simplify fail instead of crossing the 128 TiB threshold?

glibc malloc should cope with that and switch to malloc, but this code 
path is obviously less well-tested than the regular way.

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
