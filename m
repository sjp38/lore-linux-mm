Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f178.google.com (mail-qc0-f178.google.com [209.85.216.178])
	by kanga.kvack.org (Postfix) with ESMTP id 5FDE86B0031
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 08:54:38 -0500 (EST)
Received: by mail-qc0-f178.google.com with SMTP id m20so12812482qcx.37
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 05:54:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id u90si12436169qge.3.2014.02.11.05.54.37
        for <linux-mm@kvack.org>;
        Tue, 11 Feb 2014 05:54:37 -0800 (PST)
Message-ID: <52FA2B94.8050709@redhat.com>
Date: Tue, 11 Feb 2014 08:54:28 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] powerpc: mm: Add new set flag argument to pte/pmd
 update function
References: <1392114895-14997-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1392114895-14997-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1392114895-14997-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, benh@kernel.crashing.org, paulus@samba.org, mgorman@suse.de, mpe@ellerman.id.au
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On 02/11/2014 05:34 AM, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> We will use this later to set the _PAGE_NUMA bit.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
