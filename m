Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 3876C6B0036
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 10:25:41 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id up15so3374960pbc.0
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 07:25:38 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id fv4si1562756pbd.62.2014.01.24.07.25.37
        for <linux-mm@kvack.org>;
        Fri, 24 Jan 2014 07:25:37 -0800 (PST)
Message-ID: <52E285DA.1090107@intel.com>
Date: Fri, 24 Jan 2014 07:25:14 -0800
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: Panic on 8-node system in memblock_virt_alloc_try_nid()
References: <52E19C7D.7050603@intel.com> <CAE9FiQX9kTxnaqpWNgg3dUzr7+60YCrEx3q3xxO-G1n6z64xVQ@mail.gmail.com> <52E28067.1060507@intel.com>
In-Reply-To: <52E28067.1060507@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>
Cc: Grygorii Strashko <grygorii.strashko@ti.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Santosh Shilimkar <santosh.shilimkar@ti.com>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 01/24/2014 07:01 AM, Dave Hansen wrote:
> There are two failure modes I'm seeing: one when (failing to) allocate
> the first node's mem_map[], and a second where it oopses accessing the
> numa_distance[] table.  This is the numa_distance[] one, and it happens
> even with the patch you suggested applied.

And with my second (lots of debugging enabled) config, I get the
mem_map[] oops.  In other words, none of the reverts or patches are
helping either of the conditions that I'm able to trigger.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
