Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0B09F6B0038
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 23:55:06 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id y16so2024117wmd.6
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 20:55:05 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p127si632182wmp.101.2016.11.21.20.55.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 20:55:05 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAM4rTXt143931
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 23:55:03 -0500
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26vcxkcw0t-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 23:55:03 -0500
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 22 Nov 2016 14:55:00 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 6B6493578053
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 15:54:57 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAM4svSl3604842
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 15:54:57 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAM4suoi024524
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 15:54:57 +1100
Subject: Re: [HMM v13 05/18] mm/ZONE_DEVICE/devmem_pages_remove: allow early
 removal of device memory
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-6-git-send-email-jglisse@redhat.com>
 <5832CE7A.3060802@linux.vnet.ibm.com> <20161121123910.GE2392@redhat.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 22 Nov 2016 10:24:54 +0530
MIME-Version: 1.0
In-Reply-To: <20161121123910.GE2392@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Message-Id: <5833CF9E.1030804@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On 11/21/2016 06:09 PM, Jerome Glisse wrote:
> On Mon, Nov 21, 2016 at 04:07:46PM +0530, Anshuman Khandual wrote:
>> On 11/18/2016 11:48 PM, Jerome Glisse wrote:
>>> HMM wants to remove device memory early before device tear down so add an
>>> helper to do that.
>>
>> Could you please explain why HMM wants to remove device memory before
>> device tear down ?
>>
> 
> Some device driver want to manage memory for several physical devices from a
> single fake device driver. Because it fits their driver architecture better
> and those physical devices can have dedicated link between them.
> 
> Issue is that the fake device driver can outlive any of the real device for a
> long time so we want to be able to remove device memory before the fake device
> goes away to free up resources early.

Got it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
