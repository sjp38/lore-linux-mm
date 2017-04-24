Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7E99C6B02F2
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:57:39 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id j8so70615768ita.11
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 06:57:39 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id g68si3090739iog.86.2017.04.24.06.57.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 06:57:38 -0700 (PDT)
Date: Mon, 24 Apr 2017 08:57:34 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
In-Reply-To: <1492809331.25766.172.camel@kernel.crashing.org>
Message-ID: <alpine.DEB.2.20.1704240856510.15223@east.gentwo.org>
References: <20170419075242.29929-1-bsingharora@gmail.com> <alpine.DEB.2.20.1704191355280.9478@east.gentwo.org> <1492651508.1015.2.camel@gmail.com> <alpine.DEB.2.20.1704201025360.26403@east.gentwo.org> <1492723609.25766.152.camel@kernel.crashing.org>
 <alpine.DEB.2.20.1704211108120.14734@east.gentwo.org> <1492809331.25766.172.camel@kernel.crashing.org>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, arbab@linux.vnet.ibm.com, vbabka@suse.cz

On Sat, 22 Apr 2017, Benjamin Herrenschmidt wrote:

> On Fri, 2017-04-21 at 11:13 -0500, Christoph Lameter wrote:
> > > Other things are possibly more realistic to do that way, such as
> > > taking
> > > KSM and AutoNuma off the picture for it.
> >
> > Well just pinning those pages or mlocking those will stop these
> > scans.
>
> But that will stop migration too :-) These are mostly policy
> adjustement, we need to look at other options here.

Well yes that probably means some sort of policy layer that allows the
exclusion of certain nodes from KSM and AutoNUMA.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
