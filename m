Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id D53C86B027B
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 12:52:58 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id s64so16816238lfs.1
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 09:52:58 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id g5si31872493wjm.202.2016.09.21.09.52.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 09:52:57 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id 133so9650928wmq.2
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 09:52:57 -0700 (PDT)
Date: Wed, 21 Sep 2016 18:52:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memory-hotplug: Fix bad area access on
 dissolve_free_huge_pages()
Message-ID: <20160921165254.GD24210@dhcp22.suse.cz>
References: <566c04af-c937-cbe0-5646-2cc2c816cc3f@linux.vnet.ibm.com>
 <57DC1CE0.5070400@linux.intel.com>
 <7e642622-72ee-87f6-ceb0-890ce9c28382@linux.vnet.ibm.com>
 <57E14D64.6090609@linux.intel.com>
 <fc05ee3c-097f-709b-7484-1cadc9f3ce22@linux.vnet.ibm.com>
 <57E17531.6050008@linux.intel.com>
 <20160921120507.GG10300@dhcp22.suse.cz>
 <57E2AF8F.6030202@linux.intel.com>
 <20160921162715.GC24210@dhcp22.suse.cz>
 <57E2B60A.2060200@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57E2B60A.2060200@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Rui Teng <rui.teng@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Santhosh G <santhog4@in.ibm.com>

On Wed 21-09-16 09:32:10, Dave Hansen wrote:
> On 09/21/2016 09:27 AM, Michal Hocko wrote:
> > That was not my point. I wasn't very clear probably. Offlining can fail
> > which shouldn't be really surprising. There might be a kernel allocation
> > in the particular block which cannot be migrated so failures are to be
> > expected. I just do not see how offlining in the middle of a gigantic
> > page is any different from having any other unmovable allocation in a
> > block. That being said, why don't we simply refuse to offline a block
> > which is in the middle of a gigantic page.
> 
> Don't we want to minimize the things that can cause an offline to fail?
> The code to fix it here doesn't seem too bad.

I am not really sure. So say somebody wants to offline few blocks (does
offlining anything but whole nodes make any sense btw.?) and that
happens to be in the middle of a gigantic huge page which is not really
that easy to allocate, do we want to free it in order to do the offline?
To me it sounds like keeping the gigantic page should be preffered but
I have to admit I do not really understand the per-block offlining
though.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
