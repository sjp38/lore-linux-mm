Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id BAE356B000E
	for <linux-mm@kvack.org>; Thu,  3 May 2018 04:46:17 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w74so8767238wmw.0
        for <linux-mm@kvack.org>; Thu, 03 May 2018 01:46:17 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h2-v6si8550072edc.197.2018.05.03.01.46.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 01:46:16 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w438hvJ2051576
	for <linux-mm@kvack.org>; Thu, 3 May 2018 04:46:15 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hqx3ujtm1-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 03 May 2018 04:46:14 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 3 May 2018 09:46:11 +0100
Subject: Re: [RFC PATCH] Add /proc/<pid>/numa_vamaps for numa node information
References: <1525240686-13335-1-git-send-email-prakash.sangappa@oracle.com>
 <20180502143323.1c723ccb509c3497050a2e0a@linux-foundation.org>
 <2ce01d91-5fba-b1b7-2956-c8cc1853536d@intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 3 May 2018 14:16:02 +0530
MIME-Version: 1.0
In-Reply-To: <2ce01d91-5fba-b1b7-2956-c8cc1853536d@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <33f96879-351f-674a-ca23-43f233f4eb1d@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Prakash Sangappa <prakash.sangappa@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, drepper@gmail.com, rientjes@google.com, Naoya Horiguchi <nao.horiguchi@gmail.com>

On 05/03/2018 03:58 AM, Dave Hansen wrote:
> On 05/02/2018 02:33 PM, Andrew Morton wrote:
>> On Tue,  1 May 2018 22:58:06 -0700 Prakash Sangappa <prakash.sangappa@oracle.com> wrote:
>>> For analysis purpose it is useful to have numa node information
>>> corresponding mapped address ranges of the process. Currently
>>> /proc/<pid>/numa_maps provides list of numa nodes from where pages are
>>> allocated per VMA of the process. This is not useful if an user needs to
>>> determine which numa node the mapped pages are allocated from for a
>>> particular address range. It would have helped if the numa node information
>>> presented in /proc/<pid>/numa_maps was broken down by VA ranges showing the
>>> exact numa node from where the pages have been allocated.
> 
> I'm finding myself a little lost in figuring out what this does.  Today,
> numa_maps might us that a 3-page VMA has 1 page from Node 0 and 2 pages
> from Node 1.  We group *entirely* by VMA:
> 
> 1000-4000 N0=1 N1=2
> 
> We don't want that.  We want to tell exactly where each node's memory is
> despite if they are in the same VMA, like this:
> 
> 1000-2000 N1=1
> 2000-3000 N0=1
> 3000-4000 N1=1

I am kind of wondering on a big memory system how many lines of output
we might have for a large (consuming lets say 80 % of system RAM) VMA
in interleave policy. Is not that a problem ?
