Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id B7E626B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 10:14:05 -0400 (EDT)
Received: by qcrf4 with SMTP id f4so26281824qcr.0
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 07:14:05 -0700 (PDT)
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com. [32.97.110.153])
        by mx.google.com with ESMTPS id k81si11522635qkh.32.2015.04.24.07.14.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 07:14:04 -0700 (PDT)
Received: from /spool/local
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 24 Apr 2015 08:14:03 -0600
Received: from b03cxnp08026.gho.boulder.ibm.com (b03cxnp08026.gho.boulder.ibm.com [9.17.130.18])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 81B5C19D8047
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 08:05:06 -0600 (MDT)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by b03cxnp08026.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t3OEDwE920906120
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 07:13:59 -0700
Received: from d03av05.boulder.ibm.com (localhost [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t3OEE1I8007883
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 08:14:01 -0600
Date: Fri, 24 Apr 2015 07:13:59 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Interacting with coherent memory on external devices
Message-ID: <20150424141359.GX5561@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20150422000538.GB6046@gmail.com>
 <alpine.DEB.2.11.1504211942040.6294@gentwo.org>
 <20150422131832.GU5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
 <20150422170737.GB4062@gmail.com>
 <alpine.DEB.2.11.1504221306200.26217@gentwo.org>
 <20150422185230.GD5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504230910190.32297@gentwo.org>
 <20150423192456.GQ5561@linux.vnet.ibm.com>
 <alpine.DEB.2.11.1504240859080.7582@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.11.1504240859080.7582@gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Fri, Apr 24, 2015 at 09:01:47AM -0500, Christoph Lameter wrote:
> On Thu, 23 Apr 2015, Paul E. McKenney wrote:
> 
> > > As far as I know Jerome is talkeing about HPC loads and high performance
> > > GPU processing. This is the same use case.
> >
> > The difference is sensitivity to latency.  You have latency-sensitive
> > HPC workloads, and Jerome is talking about HPC workloads that need
> > high throughput, but are insensitive to latency.
> 
> Those are correlated.

In some cases, yes.  But are you -really- claiming that -all- HPC
workloads are highly sensitive to latency?  That would be quite a claim!

> > > What you are proposing for High Performacne Computing is reducing the
> > > performance these guys trying to get. You cannot sell someone a Volkswagen
> > > if he needs the Ferrari.
> >
> > You do need the low-latency Ferrari.  But others are best served by a
> > high-throughput freight train.
> 
> The problem is that they want to run 2000 trains at the same time
> and they all must arrive at the destination before they can be send on
> their next trip. 1999 trains will be sitting idle because they need
> to wait of the one train that was delayed. This reduces the troughput.
> People really would like all 2000 trains to arrive on schedule so that
> they get more performance.

Yes, there is some portion of the market that needs both high throughput
and highly predictable latencies.  You are claiming that the -entire- HPC
market has this sort of requirement?  Again, this would be quite a claim!

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
