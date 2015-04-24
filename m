Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6AB446B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 12:06:48 -0400 (EDT)
Received: by qgfi89 with SMTP id i89so24877731qgf.1
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 09:06:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b62si11781907qka.56.2015.04.24.09.06.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 09:06:47 -0700 (PDT)
Message-ID: <553A6A0F.2010808@redhat.com>
Date: Fri, 24 Apr 2015 12:06:39 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Interacting with coherent memory on external devices
References: <1429663372.27410.75.camel@kernel.crashing.org> <20150422005757.GP5561@linux.vnet.ibm.com> <1429664686.27410.84.camel@kernel.crashing.org> <alpine.DEB.2.11.1504221020160.24979@gentwo.org> <20150422163135.GA4062@gmail.com> <alpine.DEB.2.11.1504221206080.25607@gentwo.org> <1429756456.4915.22.camel@kernel.crashing.org> <alpine.DEB.2.11.1504230925250.32297@gentwo.org> <20150423185240.GO5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504240929340.7582@gentwo.org> <20150424145459.GY5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504241048490.9889@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1504241048490.9889@gentwo.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On 04/24/2015 11:49 AM, Christoph Lameter wrote:
> On Fri, 24 Apr 2015, Paul E. McKenney wrote:
> 
>> can deliver, but where the cost of full-fledge hand tuning cannot be
>> justified.
>>
>> You seem to believe that this latter category is the empty set, which
>> I must confess does greatly surprise me.
> 
> If there are already compromises are being made then why would you want to
> modify the kernel for this? Some user space coding and device drivers
> should be sufficient.

You assume only one program at a time would get to use the GPU
for accelerated computations, and the GPU would get dedicated
to that program.

That will not be the case when you have libraries using the GPU
for computations. There could be dozens of programs in the system
using that library, with no knowledge of how many GPU resources
are used by the other programs.

There is a very clear cut case for having the OS manage the
GPU resources transparently, just like it does for all the
other resources in the system.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
