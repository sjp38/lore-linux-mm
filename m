Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1252C6B0039
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 11:53:31 -0500 (EST)
Received: by mail-qc0-f169.google.com with SMTP id r5so5237438qcx.0
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 08:53:30 -0800 (PST)
Received: from mail-ve0-x22e.google.com (mail-ve0-x22e.google.com [2607:f8b0:400c:c01::22e])
        by mx.google.com with ESMTPS id q6si10672120qai.69.2013.12.05.08.53.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Dec 2013 08:53:30 -0800 (PST)
Received: by mail-ve0-f174.google.com with SMTP id pa12so14170547veb.33
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 08:53:29 -0800 (PST)
Date: Thu, 5 Dec 2013 11:53:25 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 08/23] mm/memblock: Add memblock memory allocation apis
Message-ID: <20131205165325.GA24062@mtj.dyndns.org>
References: <1386037658-3161-1-git-send-email-santosh.shilimkar@ti.com>
 <1386037658-3161-9-git-send-email-santosh.shilimkar@ti.com>
 <20131203232445.GX8277@htj.dyndns.org>
 <52A0AB34.2030703@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52A0AB34.2030703@ti.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Cc: Santosh Shilimkar <santosh.shilimkar@ti.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Yinghai Lu <yinghai@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

Hello,

On Thu, Dec 05, 2013 at 06:35:00PM +0200, Grygorii Strashko wrote:
> >> +#define memblock_virt_alloc_align(x, align) \
> >> +	memblock_virt_alloc_try_nid(x, align, BOOTMEM_LOW_LIMIT, \
> >> +				     BOOTMEM_ALLOC_ACCESSIBLE, MAX_NUMNODES)
> > 
> > Also, do we really need this align variant separate when the caller
> > can simply specify 0 for the default?
> 
> Unfortunately Yes. 
> We need it to keep compatibility with bootmem/nobootmem
> which don't handle 0 as default align value.

Hmm... why wouldn't just interpreting 0 to SMP_CACHE_BYTES in the
memblock_virt*() function work?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
