Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5716B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 10:12:44 -0400 (EDT)
Received: by igblo3 with SMTP id lo3so23862373igb.1
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 07:12:40 -0700 (PDT)
Received: from resqmta-po-08v.sys.comcast.net (resqmta-po-08v.sys.comcast.net. [2001:558:fe16:19:96:114:154:167])
        by mx.google.com with ESMTPS id mg1si16056895igb.35.2015.04.23.07.12.39
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 23 Apr 2015 07:12:39 -0700 (PDT)
Date: Thu, 23 Apr 2015 09:12:38 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <20150422185230.GD5561@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.11.1504230910190.32297@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com> <alpine.DEB.2.11.1504211839120.6294@gentwo.org> <20150422000538.GB6046@gmail.com> <alpine.DEB.2.11.1504211942040.6294@gentwo.org> <20150422131832.GU5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
 <20150422170737.GB4062@gmail.com> <alpine.DEB.2.11.1504221306200.26217@gentwo.org> <20150422185230.GD5561@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Wed, 22 Apr 2015, Paul E. McKenney wrote:

> Agreed, the use case that Jerome is thinking of differs from yours.
> You would not (and should not) tolerate things like page faults because
> it would destroy your worst-case response times.  I believe that Jerome
> is more interested in throughput with minimal change to existing code.

As far as I know Jerome is talkeing about HPC loads and high performance
GPU processing. This is the same use case.

> Let's suppose that you and Jerome were using GPGPU hardware that had
> 32,768 hardware threads.  You would want very close to 100% of the full
> throughput out of the hardware with pretty much zero unnecessary latency.
> In contrast, Jerome might be OK with (say) 20,000 threads worth of
> throughput with the occasional latency hiccup.
>
> And yes, support for both use cases is needed.

What you are proposing for High Performacne Computing is reducing the
performance these guys trying to get. You cannot sell someone a Volkswagen
if he needs the Ferrari.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
