Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id WAA28853
	for <linux-mm@kvack.org>; Thu, 12 Sep 2002 22:47:30 -0700 (PDT)
Message-ID: <3D817F94.4F4171FD@digeo.com>
Date: Thu, 12 Sep 2002 23:03:00 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] per-zone kswapd process
References: <3D817BC8.785F5C44@digeo.com> <619179322.1031870337@[10.10.2.3]>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Dave Hansen <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> ..
> Can we make a simple default of 1 per node, which is what 99%
> of people want, and then make it more complicated later if people
> complain? It's really pretty easy:
> 
> for (node = 0; node < numnodes; ++node) {
>         kswapd = kick_off_kswapd_for_node(node);
>         kswapd->cpus_allowed = node_to_cpus(node);
> }

Seems sane.
 
> Or whatever the current cpus_allowed method is. All we seem to need
> is node_to_cpus ... I can give that to you tommorow with no problem,
> it's trivial.

Tomorrow sounds too early - it'd be nice to get some before-n-after
performance testing to go along with that patch ;)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
