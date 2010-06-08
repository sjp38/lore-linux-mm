Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A54566B01AF
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 11:51:51 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp04.in.ibm.com (8.14.4/8.13.1) with ESMTP id o58FpkqM029027
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 21:21:46 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o58Fpkw51573074
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 21:21:46 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o58FpjV9011083
	for <linux-mm@kvack.org>; Wed, 9 Jun 2010 01:51:45 +1000
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Date: Tue, 08 Jun 2010 21:21:40 +0530
Message-Id: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com>
Subject: [RFC/T/D][PATCH 0/2] KVM page cache optimization (v2)
Sender: owner-linux-mm@kvack.org
To: kvm <kvm@vger.kernel.org>
Cc: Avi Kivity <avi@redhat.com>, linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This is version 2 of the page cache control patches for
KVM. This series has two patches, the first controls
the amount of unmapped page cache usage via a boot
parameter and sysctl. The second patch controls page
and slab cache via the balloon driver. Both the patches
make heavy use of the zone_reclaim() functionality
already present in the kernel.

page-cache-control
balloon-page-cache

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
