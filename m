Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7DED66B0269
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 08:05:11 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id s64so8699187lfs.1
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 05:05:11 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id h4si35514838wje.203.2016.09.21.05.05.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 05:05:10 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id 133so8208111wmq.2
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 05:05:10 -0700 (PDT)
Date: Wed, 21 Sep 2016 14:05:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memory-hotplug: Fix bad area access on
 dissolve_free_huge_pages()
Message-ID: <20160921120507.GG10300@dhcp22.suse.cz>
References: <1473755948-13215-1-git-send-email-rui.teng@linux.vnet.ibm.com>
 <57D83821.4090804@linux.intel.com>
 <a789f3ef-bd49-8811-e1df-e949f0758ad1@linux.vnet.ibm.com>
 <57D97CAF.7080005@linux.intel.com>
 <566c04af-c937-cbe0-5646-2cc2c816cc3f@linux.vnet.ibm.com>
 <57DC1CE0.5070400@linux.intel.com>
 <7e642622-72ee-87f6-ceb0-890ce9c28382@linux.vnet.ibm.com>
 <57E14D64.6090609@linux.intel.com>
 <fc05ee3c-097f-709b-7484-1cadc9f3ce22@linux.vnet.ibm.com>
 <57E17531.6050008@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57E17531.6050008@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Rui Teng <rui.teng@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Paul Gortmaker <paul.gortmaker@windriver.com>, Santhosh G <santhog4@in.ibm.com>

On Tue 20-09-16 10:43:13, Dave Hansen wrote:
> On 09/20/2016 08:52 AM, Rui Teng wrote:
> > On 9/20/16 10:53 PM, Dave Hansen wrote:
> ...
> >> That's good, but aren't we still left with a situation where we've
> >> offlined and dissolved the _middle_ of a gigantic huge page while the
> >> head page is still in place and online?
> >>
> >> That seems bad.
> >>
> > What about refusing to change the status for such memory block, if it
> > contains a huge page which larger than itself? (function
> > memory_block_action())
> 
> How will this be visible to users, though?  That sounds like you simply
> won't be able to offline memory with gigantic huge pages.

I might be missing something but Is this any different from a regular
failure when the memory cannot be freed? I mean
/sys/devices/system/memory/memory API doesn't give you any hint whether
the memory in the particular block is used and
unmigrateable.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
