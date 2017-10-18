Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id B22516B0033
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 02:56:35 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id o187so5598202qke.1
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 23:56:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 128si89914qkd.368.2017.10.17.23.56.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Oct 2017 23:56:35 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9I6u3Fj002499
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 02:56:34 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dnya9eemg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 02:56:33 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 18 Oct 2017 07:56:31 +0100
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v9I6uSiP27000954
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 06:56:29 GMT
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v9I6uRb3031322
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 17:56:27 +1100
Subject: Re: [rfc 1/2] mm/hmm: Allow smaps to see zone device public pages
References: <20171018063123.21983-1-bsingharora@gmail.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 18 Oct 2017 12:26:25 +0530
MIME-Version: 1.0
In-Reply-To: <20171018063123.21983-1-bsingharora@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <8d49e1b3-a342-c06e-8e03-e0da2b34ef43@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, jglisse@redhat.com
Cc: linux-mm@kvack.org, mhocko@suse.com

On 10/18/2017 12:01 PM, Balbir Singh wrote:
> vm_normal_page() normally does not return zone device public
> pages. In the absence of the visibility the output from smaps

It never does, as it calls _vm_normal_page() with with_public
_device = false, which skips all ZONE_DEVICE pages which are
MEMORY_DEVICE_PUBLIC.

> is limited and confusing. It's hard to figure out where the
> pages are. This patch uses _vm_normal_page() to expose them

Just a small nit, 'uses _vm_normal_page() with with_public_
device as true'.

> for accounting

Makes sense. It will help to have a small snippet of smaps output
with and without this patch demonstrating the difference. That
apart change looks good.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
