Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0DDF56B0031
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 04:28:35 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id q10so1103929pdj.8
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 01:28:35 -0800 (PST)
Received: from psmtp.com ([74.125.245.158])
        by mx.google.com with SMTP id yd9si9136123pab.263.2013.11.18.01.28.33
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 01:28:34 -0800 (PST)
Received: from /spool/local
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 18 Nov 2013 19:28:30 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id C2F502CE8056
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 20:28:28 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAI9ATvN2163048
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 20:10:35 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rAI9SM6O019627
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 20:28:22 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH -V2 0/5] powerpc: mm: Numa faults support for ppc64
Date: Mon, 18 Nov 2013 14:58:08 +0530
Message-Id: <1384766893-10189-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: benh@kernel.crashing.org, paulus@samba.org, linux-mm@kvack.org
Cc: linuxppc-dev@lists.ozlabs.org

Hi,

This patch series add support for numa faults on ppc64 architecture. We steal the
_PAGE_COHERENCE bit and use that for indicating _PAGE_NUMA. We clear the _PAGE_PRESENT bit
and also invalidate the hpte entry on setting _PAGE_NUMA. The next fault on that
page will be considered a numa fault.

Changes from V1:
* Dropped few patches related pmd update because batch handling of pmd pages got dropped from core code
   0f19c17929c952c6f0966d93ab05558e7bf814cc "mm: numa: Do not batch handle PMD pages"
   This also avoided the large lock contention on page_table_lock that we observed with the previous series.

 -aneesh
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
