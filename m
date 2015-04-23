Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id EA3006B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 12:04:15 -0400 (EDT)
Received: by wiun10 with SMTP id n10so97849286wiu.1
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 09:04:15 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k3si14444049wjr.135.2015.04.23.09.04.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Apr 2015 09:04:14 -0700 (PDT)
Message-ID: <553917F4.4080300@redhat.com>
Date: Thu, 23 Apr 2015 12:04:04 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Interacting with coherent memory on external devices
References: <20150421214445.GA29093@linux.vnet.ibm.com> <alpine.DEB.2.11.1504211839120.6294@gentwo.org> <20150422000538.GB6046@gmail.com> <alpine.DEB.2.11.1504211942040.6294@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1504211942040.6294@gentwo.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Jerome Glisse <j.glisse@gmail.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, airlied@redhat.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On 04/21/2015 08:50 PM, Christoph Lameter wrote:
> On Tue, 21 Apr 2015, Jerome Glisse wrote:

>> So big use case here, let say you have an application that rely on a
>> scientific library that do matrix computation. Your application simply
>> use malloc and give pointer to this scientific library. Now let say
>> the good folks working on this scientific library wants to leverage
>> the GPU, they could do it by allocating GPU memory through GPU specific
>> API and copy data in and out. For matrix that can be easy enough, but
>> still inefficient. What you really want is the GPU directly accessing
>> this malloced chunk of memory, eventualy migrating it to device memory
>> while performing the computation and migrating it back to system memory
>> once done. Which means that you do not want some kind of filesystem or
>> anything like that.
> 
> With a filesystem the migration can be controlled by the application.

Which is absolutely the wrong thing to do when using the "GPU"
(or whatever co-processor it is) transparently from libraries,
without the applications having to know about it.

Your use case is legitimate, but so is this other case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
