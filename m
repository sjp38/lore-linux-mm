Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 900976B0005
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 02:55:17 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id b126so137583192ite.3
        for <linux-mm@kvack.org>; Mon, 06 Jun 2016 23:55:17 -0700 (PDT)
Received: from mx0b-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id qz3si31545948pab.82.2016.06.06.23.55.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jun 2016 23:55:17 -0700 (PDT)
Received: from pps.filterd (m0048827.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u576t56A002207
	for <linux-mm@kvack.org>; Tue, 7 Jun 2016 02:55:16 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23dq0t5p6w-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 07 Jun 2016 02:55:08 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 7 Jun 2016 16:54:24 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id B16BB2CE809C
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 16:53:14 +1000 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u576qvU315859906
	for <linux-mm@kvack.org>; Tue, 7 Jun 2016 16:52:57 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u576qvGZ032022
	for <linux-mm@kvack.org>; Tue, 7 Jun 2016 16:52:57 +1000
Date: Tue, 07 Jun 2016 12:22:54 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm/debug: Add VM_WARN which maps to WARN()
References: <1464692688-6612-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1464692688-6612-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57566F46.9010607@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 05/31/2016 04:34 PM, Aneesh Kumar K.V wrote:
> This enables us to do VM_WARN(condition, "warn message");
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Reviewed-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
