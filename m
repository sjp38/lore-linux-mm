Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id F015C6B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 01:43:47 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id d28so14004208pfe.2
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 22:43:47 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id w13si233399pgs.806.2017.10.09.22.43.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 22:43:47 -0700 (PDT)
Date: Tue, 10 Oct 2017 13:43:43 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v2] mm/page_alloc.c: inline __rmqueue()
Message-ID: <20171010054342.GF1798@intel.com>
References: <20171009054434.GA1798@intel.com>
 <3a46edcf-88f8-e4f4-8b15-3c02620308e4@intel.com>
 <20171010025151.GD1798@intel.com>
 <20171010025601.GE1798@intel.com>
 <8d6a98d3-764e-fd41-59dc-88a9d21822c7@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8d6a98d3-764e-fd41-59dc-88a9d21822c7@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>

On Mon, Oct 09, 2017 at 10:19:52PM -0700, Dave Hansen wrote:
> On 10/09/2017 07:56 PM, Aaron Lu wrote:
> > This patch adds inline to __rmqueue() and vmlinux' size doesn't have any
> > change after this patch according to size(1).
> > 
> > without this patch:
> >    text    data     bss     dec     hex     filename
> > 9968576 5793372 17715200  33477148  1fed21c vmlinux
> > 
> > with this patch:
> >    text    data     bss     dec     hex     filename
> > 9968576 5793372 17715200  33477148  1fed21c vmlinux
> 
> This is unexpected.  Could you double-check this, please?

mm/page_alloc.o has size changes:

Without this patch:
$ size mm/page_alloc.o
  text    data     bss     dec     hex filename
 36695    9792    8396   54883    d663 mm/page_alloc.o

With this patch:
$ size mm/page_alloc.o
  text    data     bss     dec     hex filename
 37511    9792    8396   55699    d993 mm/page_alloc.o

But vmlinux doesn't.

It's not clear to me what happened, do you want to me dig this out?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
