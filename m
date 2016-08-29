Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CC110830DE
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 01:43:53 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 63so284312548pfx.0
        for <linux-mm@kvack.org>; Sun, 28 Aug 2016 22:43:53 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id sq1si37280735pab.29.2016.08.28.22.43.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Aug 2016 22:43:53 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7T5hm3c034345
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 01:43:52 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2536xrvks8-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 01:43:52 -0400
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 29 Aug 2016 15:43:49 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 812E73578052
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 15:43:47 +1000 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u7T5hlvo55574674
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 15:43:47 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u7T5hls3015872
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 15:43:47 +1000
Date: Mon, 29 Aug 2016 11:13:43 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Use zonelist name instead of using hardcoded index
References: <1472227078-24852-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1472227078-24852-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57C3CB8F.9060501@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/26/2016 09:27 PM, Aneesh Kumar K.V wrote:
> This use the existing enums instead of hardcoded index when looking at the

Small nit. 'use' --> 'uses'

> zonelist. This makes it more readable. No functionality change by this
> patch.

Came across this some time back, yeah it really makes sense to replace
those hard coded indices.

> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Reviewed-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
