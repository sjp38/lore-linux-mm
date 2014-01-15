Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id A02D06B0039
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 20:25:13 -0500 (EST)
Received: by mail-yh0-f46.google.com with SMTP id 29so357889yhl.19
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 17:25:13 -0800 (PST)
Received: from mail-gg0-x22a.google.com (mail-gg0-x22a.google.com [2607:f8b0:4002:c02::22a])
        by mx.google.com with ESMTPS id z48si2906012yha.256.2014.01.14.17.25.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 17:25:12 -0800 (PST)
Received: by mail-gg0-f170.google.com with SMTP id l4so329969ggi.29
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 17:25:12 -0800 (PST)
Date: Tue, 14 Jan 2014 17:25:08 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] x86/mm: memblock: switch to use NUMA_NO_NODE
In-Reply-To: <1389198198-31027-1-git-send-email-grygorii.strashko@ti.com>
Message-ID: <alpine.DEB.2.02.1401141724480.32645@chino.kir.corp.google.com>
References: <20140107022559.GE14055@localhost> <1389198198-31027-1-git-send-email-grygorii.strashko@ti.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, santosh.shilimkar@ti.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Tejun Heo <tj@kernel.org>, Yinghai Lu <yinghai@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

On Wed, 8 Jan 2014, Grygorii Strashko wrote:

> Update X86 code to use NUMA_NO_NODE instead of MAX_NUMNODES while
> calling memblock APIs, because memblock API is changed to use NUMA_NO_NODE and
> will produce warning during boot otherwise.
> 
> See:
>  https://lkml.org/lkml/2013/12/9/898
> 
> Cc: Santosh Shilimkar <santosh.shilimkar@ti.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> Cc: Tejun Heo <tj@kernel.org>
> Cc: Yinghai Lu <yinghai@kernel.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> 
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>

Acked-by: David Rientjes <rientjes@google.com>

Thanks for following through with this, Grygorii!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
