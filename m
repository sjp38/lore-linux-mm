Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 750506B006C
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 15:25:01 -0400 (EDT)
Received: by igbyr2 with SMTP id yr2so33035137igb.0
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 12:25:01 -0700 (PDT)
Received: from e39.co.us.ibm.com (e39.co.us.ibm.com. [32.97.110.160])
        by mx.google.com with ESMTPS id sd11si139115igb.20.2015.04.23.12.25.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 23 Apr 2015 12:25:00 -0700 (PDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 23 Apr 2015 13:25:00 -0600
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 2BC823E40048
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 13:24:58 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3NJOwRY26673356
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 12:24:58 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3NJOvRo002209
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 13:24:57 -0600
Date: Thu, 23 Apr 2015 12:24:56 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150423192456.GQ5561@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20150421214445.GA29093@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504211839120.6294@gentwo.org>
 <20150422000538.GB6046@gmail.com>
 <alpine.DEB.2.11.1504211942040.6294@gentwo.org>
 <20150422131832.GU5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
 <20150422170737.GB4062@gmail.com>
 <alpine.DEB.2.11.1504221306200.26217@gentwo.org>
 <20150422185230.GD5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504230910190.32297@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1504230910190.32297@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Thu, Apr 23, 2015 at 09:12:38AM -0500, Christoph Lameter wrote:
> On Wed, 22 Apr 2015, Paul E. McKenney wrote:
> 
> > Agreed, the use case that Jerome is thinking of differs from yours.
> > You would not (and should not) tolerate things like page faults because
> > it would destroy your worst-case response times.  I believe that Jerome
> > is more interested in throughput with minimal change to existing code.
> 
> As far as I know Jerome is talkeing about HPC loads and high performance
> GPU processing. This is the same use case.

The difference is sensitivity to latency.  You have latency-sensitive
HPC workloads, and Jerome is talking about HPC workloads that need
high throughput, but are insensitive to latency.

> > Let's suppose that you and Jerome were using GPGPU hardware that had
> > 32,768 hardware threads.  You would want very close to 100% of the full
> > throughput out of the hardware with pretty much zero unnecessary latency.
> > In contrast, Jerome might be OK with (say) 20,000 threads worth of
> > throughput with the occasional latency hiccup.
> >
> > And yes, support for both use cases is needed.
> 
> What you are proposing for High Performacne Computing is reducing the
> performance these guys trying to get. You cannot sell someone a Volkswagen
> if he needs the Ferrari.

You do need the low-latency Ferrari.  But others are best served by a
high-throughput freight train.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
