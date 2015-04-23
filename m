Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9446B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 13:29:09 -0400 (EDT)
Received: by wiun10 with SMTP id n10so100466081wiu.1
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 10:29:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a17si14875523wjz.67.2015.04.23.10.29.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Apr 2015 10:29:07 -0700 (PDT)
Message-ID: <55392BD9.6070305@redhat.com>
Date: Thu, 23 Apr 2015 13:28:57 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Interacting with coherent memory on external devices
References: <20150421214445.GA29093@linux.vnet.ibm.com> <alpine.DEB.2.11.1504211839120.6294@gentwo.org> <1429663372.27410.75.camel@kernel.crashing.org> <20150422005757.GP5561@linux.vnet.ibm.com> <1429664686.27410.84.camel@kernel.crashing.org> <alpine.DEB.2.11.1504221020160.24979@gentwo.org> <20150422163135.GA4062@gmail.com> <alpine.DEB.2.11.1504221206080.25607@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1504221206080.25607@gentwo.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Jerome Glisse <j.glisse@gmail.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, paulmck@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On 04/22/2015 01:14 PM, Christoph Lameter wrote:
> On Wed, 22 Apr 2015, Jerome Glisse wrote:
> 
>> Glibc hooks will not work, this is about having same address space on
>> CPU and GPU/accelerator while allowing backing memory to be regular
>> system memory or device memory all this in a transparent manner to
>> userspace program and library.
> 
> If you control the address space used by malloc and provide your own
> implementation then I do not see why this would not work.

Your program does not know how many other programs it is
sharing the co-processor / GPU device with, which means
it does not know how much of the co-processor or GPU
memory will be available for it at any point in time.

Well, in your specific case your program might know,
but in the typical case it will not.

This means the OS will have to manage the resource.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
