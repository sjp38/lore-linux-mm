Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 62D316B0037
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 05:35:22 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id fp1so6927457pdb.24
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 02:35:21 -0800 (PST)
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com. [122.248.162.8])
        by mx.google.com with ESMTPS id pg10si18557381pbb.144.2014.02.11.02.35.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 02:35:20 -0800 (PST)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 11 Feb 2014 16:05:10 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 1EECC1258055
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 16:07:02 +0530 (IST)
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1BAZ2mk48955528
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 16:05:03 +0530
Received: from d28av02.in.ibm.com (localhost [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1BAZ61g031383
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 16:05:06 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH 0/3] powerpc: Fix random application crashes with NUMA_BALANCING enabled
Date: Tue, 11 Feb 2014 16:04:52 +0530
Message-Id: <1392114895-14997-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, riel@redhat.com, mgorman@suse.de, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Hello,

This patch series fix random application crashes observed on ppc64 with numa
balancing enabled. Without the patch we see crashes like

anacron[14551]: unhandled signal 11 at 0000000000000041 nip 000000003cfd54b4 lr 000000003cfd5464 code 30001
anacron[14599]: unhandled signal 11 at 0000000000000041 nip 000000003efc54b4 lr 000000003efc5464 code 30001

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
