Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 444AA280393
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 03:01:34 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 77so5265078wms.0
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 00:01:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 6si12457418wmt.84.2017.07.28.00.01.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 00:01:33 -0700 (PDT)
Date: Fri, 28 Jul 2017 09:01:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/3] powerpc/mm: update pmdp_invalidate to return old
 pmd value
Message-ID: <20170728070131.GE2274@dhcp22.suse.cz>
References: <20170727083756.32217-1-aneesh.kumar@linux.vnet.ibm.com>
 <20170727125449.GB27766@dhcp22.suse.cz>
 <a30c566c-20ab-d3ad-1f5f-47524a97c2a3@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a30c566c-20ab-d3ad-1f5f-47524a97c2a3@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, "Kirill A . Shutemov" <kirill@shutemov.name>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Thu 27-07-17 21:18:35, Aneesh Kumar K.V wrote:
> 
> 
> On 07/27/2017 06:24 PM, Michal Hocko wrote:
> >EMISSING_CHANGELOG
> >
> >besides that no user actually uses the return value. Please fold this
> >into the patch which uses the new functionality.
> 
> 
> The patch series was suppose to help Kirill to make progress with the his
> series at
> 
> 
> https://lkml.kernel.org/r/20170615145224.66200-1-kirill.shutemov@linux.intel.com
> 
> It is essentially implementing the pmdp_invalidate update for ppc64. His
> series does it for x86-64.

OK, that was not clear from the patch, however. You could either reply
to the original thread or make it explicitly clear in the cover letter.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
