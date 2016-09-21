Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6E2D46B026E
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 12:32:12 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id wk8so100785481pab.3
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 09:32:12 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id n79si76403432pfb.225.2016.09.21.09.32.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 09:32:11 -0700 (PDT)
Subject: Re: [PATCH] memory-hotplug: Fix bad area access on
 dissolve_free_huge_pages()
References: <a789f3ef-bd49-8811-e1df-e949f0758ad1@linux.vnet.ibm.com>
 <57D97CAF.7080005@linux.intel.com>
 <566c04af-c937-cbe0-5646-2cc2c816cc3f@linux.vnet.ibm.com>
 <57DC1CE0.5070400@linux.intel.com>
 <7e642622-72ee-87f6-ceb0-890ce9c28382@linux.vnet.ibm.com>
 <57E14D64.6090609@linux.intel.com>
 <fc05ee3c-097f-709b-7484-1cadc9f3ce22@linux.vnet.ibm.com>
 <57E17531.6050008@linux.intel.com> <20160921120507.GG10300@dhcp22.suse.cz>
 <57E2AF8F.6030202@linux.intel.com> <20160921162715.GC24210@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <57E2B60A.2060200@linux.intel.com>
Date: Wed, 21 Sep 2016 09:32:10 -0700
MIME-Version: 1.0
In-Reply-To: <20160921162715.GC24210@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Rui Teng <rui.teng@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Santhosh G <santhog4@in.ibm.com>

On 09/21/2016 09:27 AM, Michal Hocko wrote:
> That was not my point. I wasn't very clear probably. Offlining can fail
> which shouldn't be really surprising. There might be a kernel allocation
> in the particular block which cannot be migrated so failures are to be
> expected. I just do not see how offlining in the middle of a gigantic
> page is any different from having any other unmovable allocation in a
> block. That being said, why don't we simply refuse to offline a block
> which is in the middle of a gigantic page.

Don't we want to minimize the things that can cause an offline to fail?
 The code to fix it here doesn't seem too bad.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
