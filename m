Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 8620A6B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 11:53:27 -0400 (EDT)
Received: by qkhg7 with SMTP id g7so32426031qkh.2
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 08:53:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r64si9104938qha.27.2015.04.24.08.53.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Apr 2015 08:53:26 -0700 (PDT)
Message-ID: <553A66EB.3050802@redhat.com>
Date: Fri, 24 Apr 2015 11:53:15 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Interacting with coherent memory on external devices
References: <20150421214445.GA29093@linux.vnet.ibm.com> <alpine.DEB.2.11.1504211839120.6294@gentwo.org> <20150422000538.GB6046@gmail.com> <alpine.DEB.2.11.1504211942040.6294@gentwo.org> <20150422131832.GU5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504221105130.24979@gentwo.org> <20150422170737.GB4062@gmail.com> <alpine.DEB.2.11.1504221306200.26217@gentwo.org> <20150422185230.GD5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504230910190.32297@gentwo.org> <20150423192456.GQ5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504240859080.7582@gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1504240859080.7582@gentwo.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, airlied@redhat.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On 04/24/2015 10:01 AM, Christoph Lameter wrote:
> On Thu, 23 Apr 2015, Paul E. McKenney wrote:
> 
>>> As far as I know Jerome is talkeing about HPC loads and high performance
>>> GPU processing. This is the same use case.
>>
>> The difference is sensitivity to latency.  You have latency-sensitive
>> HPC workloads, and Jerome is talking about HPC workloads that need
>> high throughput, but are insensitive to latency.
> 
> Those are correlated.
> 
>>> What you are proposing for High Performacne Computing is reducing the
>>> performance these guys trying to get. You cannot sell someone a Volkswagen
>>> if he needs the Ferrari.
>>
>> You do need the low-latency Ferrari.  But others are best served by a
>> high-throughput freight train.
> 
> The problem is that they want to run 2000 trains at the same time
> and they all must arrive at the destination before they can be send on
> their next trip. 1999 trains will be sitting idle because they need
> to wait of the one train that was delayed. This reduces the troughput.
> People really would like all 2000 trains to arrive on schedule so that
> they get more performance.

So you run 4000 or even 6000 trains, and have some subset of them
run at full steam, while others are waiting on memory accesses.

In reality the overcommit factor is likely much smaller, because
the GPU threads run and block on memory in smaller, more manageable
numbers, say a few dozen at a time.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
