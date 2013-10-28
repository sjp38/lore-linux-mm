Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6EAE36B0031
	for <linux-mm@kvack.org>; Mon, 28 Oct 2013 14:14:47 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ld10so7550174pab.38
        for <linux-mm@kvack.org>; Mon, 28 Oct 2013 11:14:47 -0700 (PDT)
Received: from psmtp.com ([74.125.245.109])
        by mx.google.com with SMTP id ru9si12694064pbc.318.2013.10.28.11.14.45
        for <linux-mm@kvack.org>;
        Mon, 28 Oct 2013 11:14:46 -0700 (PDT)
Message-ID: <526EA947.7060608@intel.com>
Date: Mon, 28 Oct 2013 11:13:27 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: Unnecessary mass OOM kills on Linux 3.11 virtualization host
References: <20131024224326.GA19654@alpha.arachsys.com> <20131025103946.GA30649@alpha.arachsys.com> <20131028082825.GA30504@alpha.arachsys.com>
In-Reply-To: <20131028082825.GA30504@alpha.arachsys.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Johannes Weiner <hannes@cmpxchg.org>

On 10/28/2013 01:28 AM, Richard Davies wrote:
> I further attach some other types of memory manager errors found in the
> kernel logs around the same time. There are several occurrences of each, but
> I have only copied one here for brevity:
> 
> 19:18:27 kernel: BUG: Bad page map in process qemu-system-x86  pte:00000608 pmd:1d57fd067

FWIW, I took a quick look through your OOM report and didn't see any
obvious causes for it.  But, INMHO, you should probably ignore the OOM
issue until you've fixed these "Bad page map" problems.   Those are a
sign of a much deeper problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
