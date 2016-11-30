Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 355266B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 06:46:21 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id g186so17907274pgc.2
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 03:46:21 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 12si64050267pfi.251.2016.11.30.03.46.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 03:46:20 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAUBj0AY139663
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 06:46:19 -0500
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 271u5626c3-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 06:46:19 -0500
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 30 Nov 2016 21:46:17 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 28E972BB0055
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 22:46:14 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAUBkDn829819114
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 22:46:13 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAUBkDao024952
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 22:46:13 +1100
Subject: Re: [RFC 1/4] mm: Define coherent device memory node
References: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1479824388-30446-2-git-send-email-khandual@linux.vnet.ibm.com>
 <692074f0-184f-e506-40a1-8fc078d1e706@intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 30 Nov 2016 17:16:04 +0530
MIME-Version: 1.0
In-Reply-To: <692074f0-184f-e506-40a1-8fc078d1e706@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <583EBBFC.7090700@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com

On 11/29/2016 11:27 PM, Dave Hansen wrote:
> On 11/22/2016 06:19 AM, Anshuman Khandual wrote:
>> @@ -393,6 +393,9 @@ enum node_states {
>>  	N_MEMORY = N_HIGH_MEMORY,
>>  #endif
>>  	N_CPU,		/* The node has one or more cpus */
>> +#ifdef CONFIG_COHERENT_DEVICE
>> +	N_COHERENT_DEVICE,
>> +#endif
>>  	NR_NODE_STATES
>>  };
> 
> Don't we really want this to be N_MEMORY_ISOLATED?  Or, better yet,

Sure, If we move from a CDM description to a purely node isolation one.
I am still thinking through this.

> N_MEMORY_UNISOLATED so that we can just drop the bitmap in for N_MEMORY

Did not get that, N_MEMORY_UNISOLATED for the system RAM nodes which are
not isolated ? Then where the isolated/CDM nodes go in ?

> and not have to do any bit manipulation operations at runtime.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
