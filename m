Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id C8D4A6B0031
	for <linux-mm@kvack.org>; Mon, 14 Oct 2013 10:58:39 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id g10so7430092pdj.30
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 07:58:39 -0700 (PDT)
Received: by mail-qe0-f44.google.com with SMTP id 6so5312587qeb.3
        for <linux-mm@kvack.org>; Mon, 14 Oct 2013 07:58:36 -0700 (PDT)
Date: Mon, 14 Oct 2013 10:58:33 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC 06/23] mm/memblock: Add memblock early memory allocation
 apis
Message-ID: <20131014145833.GK4722@htj.dyndns.org>
References: <1381615146-20342-1-git-send-email-santosh.shilimkar@ti.com>
 <1381615146-20342-7-git-send-email-santosh.shilimkar@ti.com>
 <20131013175648.GC5253@mtj.dyndns.org>
 <525C023A.8070608@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <525C023A.8070608@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: "yinghai@kernel.org" <yinghai@kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "Strashko, Grygorii" <grygorii.strashko@ti.com>, Andrew Morton <akpm@linux-foundation.org>

Hello,

On Mon, Oct 14, 2013 at 10:39:54AM -0400, Santosh Shilimkar wrote:
> >> +void __memblock_free_early(phys_addr_t base, phys_addr_t size);
> >> +void __memblock_free_late(phys_addr_t base, phys_addr_t size);
> > 
> > Would it be possible to drop "early"?  It's redundant and makes the
> > function names unnecessarily long.  When memblock is enabled, these
> > are basically doing about the same thing as memblock_alloc() and
> > friends, right?  Wouldn't it make more sense to define these as
> > memblock_alloc_XXX()?
> > 
> A small a difference w.r.t existing memblock_alloc() vs these new
> exports returns virtual mapped memory pointers. Actually I started
> with memblock_alloc_xxx() but then memblock already exports memblock_alloc_xx()
> returning physical memory pointer. So just wanted to make these interfaces
> distinct and added "early". But I agree with you that the 'early' can
> be dropped. Will fix it.

Hmmm, so while this removes address limit on the base / limit side, it
keeps virt address on the result.  In that case, we probably want to
somehow distinguish the two sets of interfaces - one set dealing with
phys and the other dealing with virts.  Maybe we want to build the
base interface on phys address and add convenience wrappers for virts?
Would that make more sense?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
