Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8AF806B04E4
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 05:37:54 -0500 (EST)
Received: by mail-yw0-f200.google.com with SMTP id b66so331513751ywh.2
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 02:37:54 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a81si4563717ywc.159.2016.11.21.02.37.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 02:37:53 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uALAYrhb104127
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 05:37:53 -0500
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26utr0cbdc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 05:37:52 -0500
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 21 Nov 2016 20:37:50 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id BD3652BB0057
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 21:37:48 +1100 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uALAbm3Z57016436
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 21:37:48 +1100
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uALAbmwU019733
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 21:37:48 +1100
Subject: Re: [HMM v13 05/18] mm/ZONE_DEVICE/devmem_pages_remove: allow early
 removal of device memory
References: <1479493107-982-1-git-send-email-jglisse@redhat.com>
 <1479493107-982-6-git-send-email-jglisse@redhat.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Mon, 21 Nov 2016 16:07:46 +0530
MIME-Version: 1.0
In-Reply-To: <1479493107-982-6-git-send-email-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Message-Id: <5832CE7A.3060802@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>

On 11/18/2016 11:48 PM, JA(C)rA'me Glisse wrote:
> HMM wants to remove device memory early before device tear down so add an
> helper to do that.

Could you please explain why HMM wants to remove device memory before
device tear down ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
