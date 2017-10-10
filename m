Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 44D576B025E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 22:51:59 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id j64so53826002pfj.6
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 19:51:59 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 22si7994383pfk.171.2017.10.09.19.51.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 19:51:57 -0700 (PDT)
Date: Tue, 10 Oct 2017 10:51:51 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH] page_alloc.c: inline __rmqueue()
Message-ID: <20171010025151.GD1798@intel.com>
References: <20171009054434.GA1798@intel.com>
 <3a46edcf-88f8-e4f4-8b15-3c02620308e4@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3a46edcf-88f8-e4f4-8b15-3c02620308e4@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>

On Mon, Oct 09, 2017 at 01:23:34PM -0700, Dave Hansen wrote:
> On 10/08/2017 10:44 PM, Aaron Lu wrote:
> > On a 2 sockets Intel-Skylake machine:
> >       base          %change       head
> >      77342            +6.3%      82203        will-it-scale.per_process_ops
> 
> What's the unit here?  That seems ridiculously low for page_fault1.
> It's usually in the millions.

per_process_ops = processes/nr_process

since nr_process here is nr_cpu, so on the 2 sockets machine with 104
CPUs, processes are 8043568(base) and 8549112(head), which are in the
millions as you correctly pointed out.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
