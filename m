Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3B33E6B0350
	for <linux-mm@kvack.org>; Fri, 21 Apr 2017 17:16:10 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id j130so25707769qkj.3
        for <linux-mm@kvack.org>; Fri, 21 Apr 2017 14:16:10 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id 12si8183479qkp.330.2017.04.21.14.16.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 21 Apr 2017 14:16:08 -0700 (PDT)
Message-ID: <1492809331.25766.172.camel@kernel.crashing.org>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sat, 22 Apr 2017 07:15:31 +1000
In-Reply-To: <alpine.DEB.2.20.1704211108120.14734@east.gentwo.org>
References: <20170419075242.29929-1-bsingharora@gmail.com>
	 <alpine.DEB.2.20.1704191355280.9478@east.gentwo.org>
	 <1492651508.1015.2.camel@gmail.com>
	 <alpine.DEB.2.20.1704201025360.26403@east.gentwo.org>
	 <1492723609.25766.152.camel@kernel.crashing.org>
	 <alpine.DEB.2.20.1704211108120.14734@east.gentwo.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, arbab@linux.vnet.ibm.com, vbabka@suse.cz

On Fri, 2017-04-21 at 11:13 -0500, Christoph Lameter wrote:
> > Other things are possibly more realistic to do that way, such as
> > taking
> > KSM and AutoNuma off the picture for it.
> 
> Well just pinning those pages or mlocking those will stop these
> scans.

But that will stop migration too :-) These are mostly policy
adjustement, we need to look at other options here.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
