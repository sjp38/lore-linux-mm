Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8F6CC6B0098
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 11:05:44 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id f10so867646yha.21
        for <linux-mm@kvack.org>; Thu, 20 Feb 2014 08:05:44 -0800 (PST)
Received: from qmta03.emeryville.ca.mail.comcast.net (qmta03.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:32])
        by mx.google.com with ESMTP id r24si6153488yho.112.2014.02.20.08.05.42
        for <linux-mm@kvack.org>;
        Thu, 20 Feb 2014 08:05:42 -0800 (PST)
Date: Thu, 20 Feb 2014 10:05:39 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] mm: return NUMA_NO_NODE in local_memory_node if
 zonelists are not setup
In-Reply-To: <20140219231714.GB413@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1402201004460.11829@nuc>
References: <20140219231641.GA413@linux.vnet.ibm.com> <20140219231714.GB413@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ben Herrenschmidt <benh@kernel.crashing.org>, Anton Blanchard <anton@samba.org>, linuxppc-dev@lists.ozlabs.org

On Wed, 19 Feb 2014, Nishanth Aravamudan wrote:

> We can call local_memory_node() before the zonelists are setup. In that
> case, first_zones_zonelist() will not set zone and the reference to
> zone->node will Oops. Catch this case, and, since we presumably running
> very early, just return that any node will do.

Really? Isnt there some way to avoid this call if zonelists are not setup
yet?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
