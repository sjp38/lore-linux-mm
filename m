Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 76CCD6B0032
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 12:16:55 -0400 (EDT)
Received: by iget9 with SMTP id t9so107184906ige.1
        for <linux-mm@kvack.org>; Wed, 22 Apr 2015 09:16:54 -0700 (PDT)
Received: from resqmta-po-03v.sys.comcast.net (resqmta-po-03v.sys.comcast.net. [2001:558:fe16:19:96:114:154:162])
        by mx.google.com with ESMTPS id v13si4608475ioi.40.2015.04.22.09.16.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 22 Apr 2015 09:16:53 -0700 (PDT)
Date: Wed, 22 Apr 2015 11:16:49 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Interacting with coherent memory on external devices
In-Reply-To: <20150422131832.GU5561@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.11.1504221105130.24979@gentwo.org>
References: <20150421214445.GA29093@linux.vnet.ibm.com> <alpine.DEB.2.11.1504211839120.6294@gentwo.org> <20150422000538.GB6046@gmail.com> <alpine.DEB.2.11.1504211942040.6294@gentwo.org> <20150422131832.GU5561@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Jerome Glisse <j.glisse@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, benh@kernel.crashing.org, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Wed, 22 Apr 2015, Paul E. McKenney wrote:

> I completely agree that some critically important use cases, such as
> yours, will absolutely require that the application explicitly choose
> memory placement and have the memory stay there.



Most of what you are trying to do here is already there and has been done.
GPU memory is accessible. NICs work etc etc. All without CAPI. What
exactly are the benefits of CAPI? Is driver simplification? Reduction of
overhead? If so then the measures proposed are a bit radical and
may result in just the opposite.


For my use cases the advantage of CAPI lies in the reduction of latency
for coprocessor communication. I hope that CAPI will allow fast cache to
cache transactions between a coprocessor and the main one. This is
improving the ability to exchange data rapidly between a application code
and some piece of hardware (NIC, GPU, custom hardware etc etc)

Fundamentally this is currently an design issue since CAPI is running on
top of PCI-E and PCI-E transactions establish a minimum latency that
cannot be avoided. So its hard to see how CAPI can improve the situation.

The new thing about CAPI are the cache to cache transactions and
participation in cache coherency at the cacheline level. That is a
different approach than the device memory oriented PCI transcactions.
Perhaps even CAPI over PCI-E can improve the situation there (maybe the
transactions are lower latency than going to device memory) and hopefully
CAPI will not forever be bound to PCI-E and thus at some point shake off
the shackles of a bus designed by a competitor.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
