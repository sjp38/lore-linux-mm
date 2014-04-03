Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8A0036B0038
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 18:31:24 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id rp16so2506014pbb.17
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 15:31:24 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id xt7si3677540pab.471.2014.04.03.15.31.23
        for <linux-mm@kvack.org>;
        Thu, 03 Apr 2014 15:31:23 -0700 (PDT)
Message-ID: <533DE12C.9030203@intel.com>
Date: Thu, 03 Apr 2014 15:31:08 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC] mm,tracing: improve current situation
References: <1396561440.4661.33.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1396561440.4661.33.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Dave Jones <davej@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/03/2014 02:44 PM, Davidlohr Bueso wrote:
> Now, on a more general scenario, I basically would like to know, 1) is
> this actually useful... I'm hoping that, if in fact something like this
> gets merged, it won't just sit there. 2) What other general data would
> be useful for debugging purposes? I'm happy to collect feedback and send
> out something we can all benefit from.

One thing that would be nice, specifically for the VM, would be to turn
all of the things that touch the /proc/vmstat counters
(count_vm_event(), etc...) in to tracepoints.

I started on it once, but ran in to some header dependency hell and gave
up before I got anything useful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
