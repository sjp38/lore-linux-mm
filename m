Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7AD556B006E
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 12:09:01 -0400 (EDT)
Received: by qgej70 with SMTP id j70so24872246qge.2
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 09:09:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g88si11775118qgf.66.2015.04.24.09.09.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 09:09:00 -0700 (PDT)
Message-ID: <553A6A94.1010508@redhat.com>
Date: Fri, 24 Apr 2015 12:08:52 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Interacting with coherent memory on external devices
References: <20150421214445.GA29093@linux.vnet.ibm.com> <alpine.DEB.2.11.1504211839120.6294@gentwo.org> <1429663372.27410.75.camel@kernel.crashing.org> <20150422005757.GP5561@linux.vnet.ibm.com> <1429664686.27410.84.camel@kernel.crashing.org> <alpine.DEB.2.11.1504221020160.24979@gentwo.org> <20150422163135.GA4062@gmail.com> <alpine.DEB.2.11.1504221206080.25607@gentwo.org> <1429756456.4915.22.camel@kernel.crashing.org> <alpine.DEB.2.11.1504230925250.32297@gentwo.org> <20150423185240.GO5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504240929340.7582@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1504240929340.7582@gentwo.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On 04/24/2015 10:30 AM, Christoph Lameter wrote:
> On Thu, 23 Apr 2015, Paul E. McKenney wrote:
> 
>> If by "entire industry" you mean everyone who might want to use hardware
>> acceleration, for example, including mechanical computer-aided design,
>> I am skeptical.
> 
> The industry designs GPUs with super fast special ram and accellerators
> with special ram designed to do fast searches and you think you can demand page
> that stuff in from the main processor?

DRAM access latencies are a few hundred CPU cycles, but somehow
CPUs can still do computations at a fast speed, and we do not
require gigabytes of L2-cache-speed memory in the system.

It turns out the vast majority of programs have working sets,
and data access patterns where prefetching works satisfactorily.

With GPU calculations done transparently by libraries, and
largely hidden from programs, why would this be any different?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
