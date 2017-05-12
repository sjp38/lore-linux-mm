Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9E2FB6B0038
	for <linux-mm@kvack.org>; Fri, 12 May 2017 12:19:41 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id v27so20633409qtg.6
        for <linux-mm@kvack.org>; Fri, 12 May 2017 09:19:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j42si799279qtj.224.2017.05.12.09.19.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 May 2017 09:19:40 -0700 (PDT)
Date: Fri, 12 May 2017 13:19:16 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [patch 2/2] MM: allow per-cpu vmstat_threshold and vmstat_worker
 configuration
Message-ID: <20170512161915.GA4185@amt.cnet>
References: <20170425135717.375295031@redhat.com>
 <20170425135846.203663532@redhat.com>
 <20170502102836.4a4d34ba@redhat.com>
 <20170502165159.GA5457@amt.cnet>
 <20170502131527.7532fc2e@redhat.com>
 <alpine.DEB.2.20.1705111035560.2894@east.gentwo.org>
 <20170512122704.GA30528@amt.cnet>
 <alpine.DEB.2.20.1705121002310.22243@east.gentwo.org>
 <20170512154026.GA3556@amt.cnet>
 <alpine.DEB.2.20.1705121103120.22831@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1705121103120.22831@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>, cmetcalf@mellanox.com

On Fri, May 12, 2017 at 11:07:48AM -0500, Christoph Lameter wrote:
> On Fri, 12 May 2017, Marcelo Tosatti wrote:
> 
> > In our case, vmstat updates are very rare (CPU is dominated by DPDK).
> 
> What is the OS doing on the cores that DPDK runs on? I mean we here can
> clean a processor of all activities and are able to run for a long time
> without any interruptions.
> 
> Why would you still let the OS do things on that processor? If activities
> by the OS are required then the existing NOHZ setup already minimizes
> latency to a short burst (and Chris Metcalf's work improves on that).
> 
> 
> What exactly is the issue you are seeing and want to address? I think we
> have similar aims and as far as I know the current situation is already
> good enough for what you may need. You may just not be aware of how to
> configure this.

I want to disable vmstat worker thread completly from an isolated CPU.
Because it adds overhead to a latency target, target which 
the lower the better.

> I doubt that doing inline updates will do much good compared to what we
> already have and what the dataplan mode can do.

Can the dataplan mode disable vmstat worker thread completly on a given
CPU?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
