Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id AF8566B0038
	for <linux-mm@kvack.org>; Mon, 15 May 2017 11:53:31 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id h101so85137899ioi.10
        for <linux-mm@kvack.org>; Mon, 15 May 2017 08:53:31 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id b19si12196099iof.159.2017.05.15.08.53.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 May 2017 08:53:30 -0700 (PDT)
Date: Mon, 15 May 2017 10:53:28 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
In-Reply-To: <20170515125530.GH6056@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1705151050530.12308@east.gentwo.org>
References: <20170419075242.29929-1-bsingharora@gmail.com> <20170502143608.GM14593@dhcp22.suse.cz> <1493875615.7934.1.camel@gmail.com> <20170504125250.GH31540@dhcp22.suse.cz> <1493912961.25766.379.camel@kernel.crashing.org> <20170505145238.GE31461@dhcp22.suse.cz>
 <1493999822.25766.397.camel@kernel.crashing.org> <20170509113638.GJ6481@dhcp22.suse.cz> <1494337392.25766.446.camel@kernel.crashing.org> <20170515125530.GH6056@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, arbab@linux.vnet.ibm.com, vbabka@suse.cz

On Mon, 15 May 2017, Michal Hocko wrote:

> With the proposed solution, they would need to set up mempolicy/cpuset
> so I must be missing something here...
>
> > Of course, the special case of the HPC user trying to milk the last
> > cycle out of the system is probably going to do what you suggest. But
> > most users won't.

Its going to be the HPC users who will be trying to take advantage of it
anyways. I doubt that enterprise class users will even be buying the
accellerators. If it goes that way (after a couple of years) we hopefully
have matured things a bit and have experience how to configure the special
NUMA nodes in the system to behave properly with an accellerator.

I think the simplest way is to just go ahead create the NUMA node
approach and see how much can be covered with the existing NUMA features.
Then work from there to simplify and enhance.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
