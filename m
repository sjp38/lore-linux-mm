Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9E94D6B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 10:01:50 -0400 (EDT)
Received: by qgej70 with SMTP id j70so23003154qge.2
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 07:01:50 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id w74si11488261qkw.3.2015.04.24.07.01.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 07:01:49 -0700 (PDT)
Date: Fri, 24 Apr 2015 09:01:47 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <20150423192456.GQ5561@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.11.1504240859080.7582@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com> <alpine.DEB.2.11.1504211839120.6294@gentwo.org> <20150422000538.GB6046@gmail.com> <alpine.DEB.2.11.1504211942040.6294@gentwo.org> <20150422131832.GU5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
 <20150422170737.GB4062@gmail.com> <alpine.DEB.2.11.1504221306200.26217@gentwo.org> <20150422185230.GD5561@linux.vnet.ibm.com> <alpine.DEB.2.11.1504230910190.32297@gentwo.org> <20150423192456.GQ5561@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Thu, 23 Apr 2015, Paul E. McKenney wrote:

> > As far as I know Jerome is talkeing about HPC loads and high performance
> > GPU processing. This is the same use case.
>
> The difference is sensitivity to latency.  You have latency-sensitive
> HPC workloads, and Jerome is talking about HPC workloads that need
> high throughput, but are insensitive to latency.

Those are correlated.

> > What you are proposing for High Performacne Computing is reducing the
> > performance these guys trying to get. You cannot sell someone a Volkswagen
> > if he needs the Ferrari.
>
> You do need the low-latency Ferrari.  But others are best served by a
> high-throughput freight train.

The problem is that they want to run 2000 trains at the same time
and they all must arrive at the destination before they can be send on
their next trip. 1999 trains will be sitting idle because they need
to wait of the one train that was delayed. This reduces the troughput.
People really would like all 2000 trains to arrive on schedule so that
they get more performance.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
