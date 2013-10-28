Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 528FE6B0031
	for <linux-mm@kvack.org>; Mon, 28 Oct 2013 14:23:18 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id x10so7163582pdj.23
        for <linux-mm@kvack.org>; Mon, 28 Oct 2013 11:23:17 -0700 (PDT)
Received: from psmtp.com ([74.125.245.163])
        by mx.google.com with SMTP id ud7si13710422pac.33.2013.10.28.11.23.15
        for <linux-mm@kvack.org>;
        Mon, 28 Oct 2013 11:23:16 -0700 (PDT)
Date: Mon, 28 Oct 2013 18:23:09 +0000
From: Richard Davies <richard@arachsys.com>
Subject: Re: Unnecessary mass OOM kills on Linux 3.11 virtualization host
Message-ID: <20131028182309.GA21822@alpha.arachsys.com>
References: <20131024224326.GA19654@alpha.arachsys.com>
 <20131025103946.GA30649@alpha.arachsys.com>
 <20131028082825.GA30504@alpha.arachsys.com>
 <526EA947.7060608@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <526EA947.7060608@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>

Dave Hansen wrote:
> Richard Davies wrote:
> > I further attach some other types of memory manager errors found in the
> > kernel logs around the same time. There are several occurrences of each, but
> > I have only copied one here for brevity:
> >
> > 19:18:27 kernel: BUG: Bad page map in process qemu-system-x86  pte:00000608 pmd:1d57fd067
>
> FWIW, I took a quick look through your OOM report and didn't see any
> obvious causes for it.  But, INMHO, you should probably ignore the OOM
> issue until you've fixed these "Bad page map" problems.   Those are a
> sign of a much deeper problem.

Thanks! What investigation should I do for these? It is on stock 3.11.3.

Richard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
