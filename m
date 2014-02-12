Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3949F6B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 22:43:58 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id rd3so8604435pab.30
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 19:43:57 -0800 (PST)
Received: from e28smtp05.in.ibm.com (e28smtp05.in.ibm.com. [122.248.162.5])
        by mx.google.com with ESMTPS id oq9si21081935pac.151.2014.02.11.19.43.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 19:43:56 -0800 (PST)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 12 Feb 2014 09:13:53 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 01BD0E0059
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 09:17:10 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1C3hq999699682
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 09:13:52 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1C3hn6r020050
	for <linux-mm@kvack.org>; Wed, 12 Feb 2014 09:13:49 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH V2 0/3]  powerpc: Fix random application crashes with NUMA_BALANCING enabled
Date: Wed, 12 Feb 2014 09:13:35 +0530
Message-Id: <1392176618-23667-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, riel@redhat.com, mgorman@suse.de, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Hello,

This patch series fix random application crashes observed on ppc64 with numa
balancing enabled. Without the patch we see crashes like

anacron[14551]: unhandled signal 11 at 0000000000000041 nip 000000003cfd54b4 lr 000000003cfd5464 code 30001
anacron[14599]: unhandled signal 11 at 0000000000000041 nip 000000003efc54b4 lr 000000003efc5464 code 30001

Changes from V1:
* Build fix for CONFIG_NUMA_BALANCING disabled

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
