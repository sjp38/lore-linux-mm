Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id B56D66B0033
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 07:05:15 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id j18so140217837ioe.3
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 04:05:15 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o124si2626968itc.58.2017.01.16.04.05.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 04:05:15 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0GC4q9f083501
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 07:05:14 -0500
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0b-001b2d01.pphosted.com with ESMTP id 280sn7t7af-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 07:05:11 -0500
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 16 Jan 2017 22:05:07 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 1522B3578052
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 23:05:04 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0GC54ta29819018
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 23:05:04 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0GC53ar030272
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 23:05:03 +1100
Subject: Re: [LSF/MM ATTEND] Un-addressable device memory and block/fs
 implications
References: <20161213181511.GB2305@redhat.com>
 <87lgvgwoos.fsf@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 16 Jan 2017 17:34:51 +0530
MIME-Version: 1.0
In-Reply-To: <87lgvgwoos.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <6304634e-3351-ea81-2970-506b69bc588f@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Jerome Glisse <jglisse@redhat.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org

On 12/16/2016 08:44 AM, Aneesh Kumar K.V wrote:
> Jerome Glisse <jglisse@redhat.com> writes:
> 
>> I would like to discuss un-addressable device memory in the context of
>> filesystem and block device. Specificaly how to handle write-back, read,
>> ... when a filesystem page is migrated to device memory that CPU can not
>> access.
>>
>> I intend to post a patchset leveraging the same idea as the existing
>> block bounce helper (block/bounce.c) to handle this. I believe this is
>> worth discussing during summit see how people feels about such plan and
>> if they have better ideas.
>>
>>
>> I also like to join discussions on:
>>   - Peer-to-Peer DMAs between PCIe devices
>>   - CDM coherent device memory
>>   - PMEM
>>   - overall mm discussions
> I would like to attend this discussion. I can talk about coherent device
> memory and how having HMM handle that will make it easy to have one
> interface for device driver. For Coherent device case we definitely need
> page cache migration support.

I have been in the discussion on the mailing list about HMM since V13 which
got posted back in October. Touched upon many points including how it changes
ZONE_DEVICE to accommodate un-addressable device memory, migration capability
of currently supported ZONE_DEVICE based persistent memory etc. Looked at the
HMM more closely from the perspective whether it can also accommodate coherent
device memory which has been already discussed by others on this thread. I too
would like to attend to discuss more on this topic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
