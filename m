Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3FA296B0279
	for <linux-mm@kvack.org>; Fri, 26 May 2017 15:10:08 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id z142so5759694qkz.8
        for <linux-mm@kvack.org>; Fri, 26 May 2017 12:10:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q67si1539340qkb.106.2017.05.26.12.10.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 May 2017 12:10:07 -0700 (PDT)
Date: Fri, 26 May 2017 16:09:29 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [patch 2/2] MM: allow per-cpu vmstat_threshold and vmstat_worker
 configuration
Message-ID: <20170526190926.GA8974@amt.cnet>
References: <alpine.DEB.2.20.1705121103120.22831@east.gentwo.org>
 <20170512161915.GA4185@amt.cnet>
 <alpine.DEB.2.20.1705121154240.23503@east.gentwo.org>
 <20170515191531.GA31483@amt.cnet>
 <alpine.DEB.2.20.1705160825480.32761@east.gentwo.org>
 <20170519143407.GA19282@amt.cnet>
 <alpine.DEB.2.20.1705191205580.19631@east.gentwo.org>
 <20170519134934.0c298882@redhat.com>
 <20170525193508.GA30252@amt.cnet>
 <alpine.DEB.2.20.1705252220130.7596@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1705252220130.7596@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>, cmetcalf@mellanox.com

On Thu, May 25, 2017 at 10:24:46PM -0500, Christoph Lameter wrote:
> On Thu, 25 May 2017, Marcelo Tosatti wrote:
> 
> > Argument? We're showing you the data that this is causing a latency
> > problem for us.
> 
> Sorry I am not sure where the data shows a latency problem. There are
> interrupts and scheduler ticks. But what does this have to do with vmstat?
> 
> Show me your dpdk code running and trace the tick on / off events  as well
> as the vmstat invocations. Also show all system calls occurring on the cpu
> that runs dpdk. That is necessary to see what triggers vmstat and how the
> system reacts to the changes to the differentials.

Sure, i can get that to you. The question remains: Are you arguing
its not valid for a realtime application to use any system call
which changes a vmstat counter? 

Because if they are allowed, then its obvious something like
this is needed.

> Then please rerun the test by setting the vmstat_interval to 60.
> 
> Do another run with your modifications and show the difference.

Will do so.

> > > Something that crossed my mind was to add a new tunable to set
> > > the vmstat_interval for each CPU, this way we could essentially
> > > disable it to the CPUs where DPDK is running. What's the implications
> > > of doing this besides not getting up to date stats in /proc/vmstat
> > > (which I still have to confirm would be OK)? Can this break anything
> > > in the kernel for example?
> >
> > Well, you get incorrect statistics.
> 
> The statistics are never completely accurate. You will get less accurate
> statistics but they will be correct. The differentials may not be
> reflected in the counts shown via /proc but there is a cap on how
> inaccurate those can becore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
