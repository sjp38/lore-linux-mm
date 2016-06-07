Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A79096B007E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 02:55:39 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 132so74797199lfz.3
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 23:55:39 -0700 (PDT)
Received: from mx0b-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s68si23385025wme.28.2016.06.06.23.55.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 23:55:38 -0700 (PDT)
Received: from pps.filterd (m0049461.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u576sUVL027053
	for <linux-mm@kvack.org>; Tue, 7 Jun 2016 02:55:37 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23drc3b0q2-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 07 Jun 2016 02:55:36 -0400
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 7 Jun 2016 16:55:30 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 4A68C2BB008F
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 16:54:52 +1000 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u576sfa47143928
	for <linux-mm@kvack.org>; Tue, 7 Jun 2016 16:54:41 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u576sfGC002613
	for <linux-mm@kvack.org>; Tue, 7 Jun 2016 16:54:41 +1000
Date: Tue, 07 Jun 2016 12:24:34 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] powerpc/mm: check for irq disabled() only if DEBUG_VM
 is enabled.
References: <1464692688-6612-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1464692688-6612-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1464692688-6612-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57566FAA.7040401@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/31/2016 04:34 PM, Aneesh Kumar K.V wrote:
> We don't need to check this always. The idea here is to capture the
> wrong usage of find_linux_pte_or_hugepte and we can do that by
> occasionally running with DEBUG_VM enabled.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Reviewed-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
