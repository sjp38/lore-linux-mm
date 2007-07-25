Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6PM0PK3015576
	for <linux-mm@kvack.org>; Wed, 25 Jul 2007 18:00:25 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6PM0Ptt420314
	for <linux-mm@kvack.org>; Wed, 25 Jul 2007 18:00:25 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6PM0Ose006425
	for <linux-mm@kvack.org>; Wed, 25 Jul 2007 18:00:24 -0400
Date: Wed, 25 Jul 2007 15:00:23 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH take3] Memoryless nodes:  use "node_memory_map" for cpuset mems_allowed validation
Message-ID: <20070725220023.GK18510@us.ibm.com>
References: <20070711182219.234782227@sgi.com> <20070711182250.005856256@sgi.com> <Pine.LNX.4.64.0707111204470.17503@schroedinger.engr.sgi.com> <1185309019.5649.69.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1185309019.5649.69.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Christoph Lameter <clameter@sgi.com>, Paul Jackson <pj@sgi.com>, akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 24.07.2007 [16:30:19 -0400], Lee Schermerhorn wrote:
> Memoryless Nodes:  use "node_memory_map" for cpusets - take 3
> 
> Against 2.6.22-rc6-mm1 atop Christoph Lameter's memoryless nodes
> series
> 
> take 2:
> + replaced node_online_map in cpuset_current_mems_allowed()
>   with node_states[N_MEMORY]
> + replaced node_online_map in cpuset_init_smp() with
>   node_states[N_MEMORY]
> 
> take 3:
> + fix up comments and top level cpuset tracking of nodes
>   with memory [instead of on-line nodes].
> + maybe I got them all this time?

My ack stands, but I believe Documentation/cpusets.txt will need
updating too :)

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
