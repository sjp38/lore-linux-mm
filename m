Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 93CAF6B04AB
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 11:49:10 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u17so215306218pfa.6
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 08:49:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id n15si9351285pgt.530.2017.07.27.08.49.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 08:49:09 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6RFmxg3051927
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 11:49:08 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2byjs713xa-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 11:49:02 -0400
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 27 Jul 2017 09:48:48 -0600
Subject: Re: [RFC PATCH 1/3] powerpc/mm: update pmdp_invalidate to return old
 pmd value
References: <20170727083756.32217-1-aneesh.kumar@linux.vnet.ibm.com>
 <20170727125449.GB27766@dhcp22.suse.cz>
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Date: Thu, 27 Jul 2017 21:18:35 +0530
MIME-Version: 1.0
In-Reply-To: <20170727125449.GB27766@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <a30c566c-20ab-d3ad-1f5f-47524a97c2a3@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, "Kirill A . Shutemov" <kirill@shutemov.name>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org



On 07/27/2017 06:24 PM, Michal Hocko wrote:
> EMISSING_CHANGELOG
> 
> besides that no user actually uses the return value. Please fold this
> into the patch which uses the new functionality.


The patch series was suppose to help Kirill to make progress with the 
his series at


https://lkml.kernel.org/r/20170615145224.66200-1-kirill.shutemov@linux.intel.com

It is essentially implementing the pmdp_invalidate update for ppc64. His 
series does it for x86-64.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
