Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 18C886B0088
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 18:08:09 -0500 (EST)
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id nAPN86pK005581
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 15:08:07 -0800
Received: from pxi11 (pxi11.prod.google.com [10.243.27.11])
	by spaceape10.eur.corp.google.com with ESMTP id nAPN82Uj005363
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 15:08:03 -0800
Received: by pxi11 with SMTP id 11so137209pxi.9
        for <linux-mm@kvack.org>; Wed, 25 Nov 2009 15:08:02 -0800 (PST)
Date: Wed, 25 Nov 2009 15:08:00 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: memcg: slab control
Message-ID: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Suleiman Souhlal <suleiman@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I wanted to see what the current ideas are concerning kernel memory 
accounting as it relates to the memory controller.  Eventually we'll want 
the ability to restrict cgroups to a hard slab limit.  That'll require 
accounting to map slab allocations back to user tasks so that we can 
enforce a policy based on the cgroup's aggregated slab usage similiar to 
how the memory controller currently does for user memory.

Is this currently being thought about within the memcg community?  We'd 
like to start a discussion and get everybody's requirements and interests 
on the table and then become actively involved in the development of such 
a feature.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
