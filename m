Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E50C6C76192
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 14:35:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A1C92173C
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 14:35:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DcDJmgjq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A1C92173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B968E8E0001; Tue, 16 Jul 2019 10:35:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1ED26B000D; Tue, 16 Jul 2019 10:35:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9989C8E0001; Tue, 16 Jul 2019 10:35:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 32F8E6B0007
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 10:35:36 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id f24so1813834lfk.6
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 07:35:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:date:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=zUyofHCcnv9SWgv1ygBVjBzYVGWvD7z+3V3WVJoCxMM=;
        b=A1rNBOC+H3rIYzT35C8M5H5S/F1dgNzMesD0q0N743930kaEBpdgPLkPGXdWzSM5Lo
         P0I34icvncx1OTCXzXH8i8TPTY0tokPRdyhO9xZVgh9zELKnhA6184zz/7KYDIrl76af
         U2ybEPXT+OVn4G3hSwRXcLO3AK+vg01AriKfIsPvmhZMYG62qIiuBafraJ1D8vuRgynM
         aopivcpzu9vCx1CDJn46QQ+O199sgDaBLAFtl9RQNGkkRtzhESVUCKbk2vI6TkV/fA3z
         IP4SWPA2YOwG7s0AUGIXisJGJ+rT2upbs52HhDW9B0sSyKGQDk4Kejj4jx9ie6hgAV7y
         StGg==
X-Gm-Message-State: APjAAAU3rJJOvtMoppNXveu1MxDNMXxHDgT6eMgz4zb7BkITij3AkwM8
	8ItVRFd/tKyiI73L9806RJLPyL9Q+W/VYd3nBguuw/5Cpco8S32T/SwrJMvnnW7Gr+RILjlxTIt
	u95joV4HKv+ehGEn5ijKJryOTfq8sVuMs4kT/eIkZ+ZWhHNaQHzI/UJmqx/rutf7XkA==
X-Received: by 2002:a2e:870f:: with SMTP id m15mr17825157lji.223.1563287735333;
        Tue, 16 Jul 2019 07:35:35 -0700 (PDT)
X-Received: by 2002:a2e:870f:: with SMTP id m15mr17825092lji.223.1563287733769;
        Tue, 16 Jul 2019 07:35:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563287733; cv=none;
        d=google.com; s=arc-20160816;
        b=uefhx0X5yELyzj6pEntPpVbBtYKkTu4wfKQS/A5KWJxl8JwQlb4+LTAbvWvti1CyWU
         Afi+mCBnk1J5DaMCDNuMCjRfZ1wgfB9s0q5BAabIKNUh8g0y+zU5AUXzGrLTunRccKLJ
         +QGm2cOkkJ6Y/j2cC/dlxmxnN3Q57glMqylq2TICceFEWLTCLIx7YV5D5zCbXEC09dSO
         Zdei1zWa6rWQryqVmPqsAF9CIVfTB796qnaD9YRcY4vL0Y7vh9LlGua/MKgxROm2Z9rq
         /3GZ6BQHz7lgtiY9RjnsaXBvUz+3NhHJEpcEC1gVciL/L36XXaBs+YbFxRwu6Zps5DVv
         F2CA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:date:from:dkim-signature;
        bh=zUyofHCcnv9SWgv1ygBVjBzYVGWvD7z+3V3WVJoCxMM=;
        b=cKtcbO2NoKPocAxRHf6KY/X7vI505gysDuynHGr3kiND8lzhp8OzIu+aBUAIELHsfN
         UYY7Xkv7NSjg7N1LLpMmUiFQVX7cJWUvlMEiy8SQ9uh6n8cZhPZIHqseVZ4MJ4QLUg+9
         X4qdlGgEI6Ed/YsYQFr6Qdlr0daEPHPycw5+jnMwUUvJudi3n1OX0rJQlDG9sax7L4wM
         z7yclAJn7LrptNNIqPZgpt00evyGZG8w7Wq+RwkjzJunpPcz8xXkanqnvNeYbqKg3x9j
         Ix3PFZwNcvzTApBKT8nWoQhtH6g2knbL9zEoTUETpOxN5JVIqoEfokZVYuyBgRxxIh8l
         1urQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DcDJmgjq;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q21sor11520023lji.10.2019.07.16.07.35.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Jul 2019 07:35:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DcDJmgjq;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:date:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=zUyofHCcnv9SWgv1ygBVjBzYVGWvD7z+3V3WVJoCxMM=;
        b=DcDJmgjq+LhEJK0s+RFNF/DA/N5+EOqi9zRvN9BORc4Lw/esmcC+A3tHuOReBdoJRM
         N1LN4P1K44J0pnfppgXFwXgqToo3pE9R0C/KLoCYAn11OYplobx61DXEBoWvO2dfqnS9
         964BsYbe7H4gtZz/3zPwH4yFvU1nFs9K9IXnNghNH89u4ByFhwJWGXCLV2794PCB8LwX
         B8GWz3M1gpLKFe+l81fTQknxaEeB9YimEdYjrmT2EOm8GOP+107D29Tl4DKczylnU+k8
         t0PVNvOsvxNgaOfeGEhwm7QGrU9/NcvCcpQIcBranXmsSaflI6ySBhwy/2pCm4rk+Q70
         YRvQ==
X-Google-Smtp-Source: APXvYqyE6DdgDbg1HtrLsQikpQiZMqInxy0KtHwAvqdhLElL2LJwNaC9N5ROuzojCJrXOEew677ihw==
X-Received: by 2002:a2e:a0d6:: with SMTP id f22mr17300898ljm.182.1563287733222;
        Tue, 16 Jul 2019 07:35:33 -0700 (PDT)
Received: from pc636 ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id z12sm2887572lfg.67.2019.07.16.07.35.31
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 16 Jul 2019 07:35:32 -0700 (PDT)
From: Uladzislau Rezki <urezki@gmail.com>
X-Google-Original-From: Uladzislau Rezki <urezki@pc636>
Date: Tue, 16 Jul 2019 16:35:25 +0200
To: Pengfei Li <lpf.vector@gmail.com>
Cc: akpm@linux-foundation.org, willy@infradead.org, urezki@gmail.com,
	rpenyaev@suse.de, peterz@infradead.org, guro@fb.com,
	rick.p.edgecombe@intel.com, rppt@linux.ibm.com,
	aryabinin@virtuozzo.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v5 2/2] mm/vmalloc: modify struct vmap_area to reduce its
 size
Message-ID: <20190716143525.5vnnwh4m637dcb2f@pc636>
References: <20190716132604.28289-1-lpf.vector@gmail.com>
 <20190716132604.28289-3-lpf.vector@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190716132604.28289-3-lpf.vector@gmail.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 16, 2019 at 09:26:04PM +0800, Pengfei Li wrote:
> Objective
> ---------
> The current implementation of struct vmap_area wasted space.
> 
> After applying this commit, sizeof(struct vmap_area) has been
> reduced from 11 words to 8 words.
> 
> Description
> -----------
> 1) Pack "subtree_max_size", "vm" and "purge_list".
> This is no problem because
>     A) "subtree_max_size" is only used when vmap_area is in
>        "free" tree
>     B) "vm" is only used when vmap_area is in "busy" tree
>     C) "purge_list" is only used when vmap_area is in
>        vmap_purge_list
> 
> 2) Eliminate "flags".
> Since only one flag VM_VM_AREA is being used, and the same
> thing can be done by judging whether "vm" is NULL, then the
> "flags" can be eliminated.
> 
> Signed-off-by: Pengfei Li <lpf.vector@gmail.com>
> Suggested-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
> ---
>  include/linux/vmalloc.h | 20 +++++++++++++-------
>  mm/vmalloc.c            | 24 ++++++++++--------------
>  2 files changed, 23 insertions(+), 21 deletions(-)
> 
> diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
> index 9b21d0047710..a1334bd18ef1 100644
> --- a/include/linux/vmalloc.h
> +++ b/include/linux/vmalloc.h
> @@ -51,15 +51,21 @@ struct vmap_area {
>  	unsigned long va_start;
>  	unsigned long va_end;
>  
> -	/*
> -	 * Largest available free size in subtree.
> -	 */
> -	unsigned long subtree_max_size;
> -	unsigned long flags;
>  	struct rb_node rb_node;         /* address sorted rbtree */
>  	struct list_head list;          /* address sorted list */
> -	struct llist_node purge_list;    /* "lazy purge" list */
> -	struct vm_struct *vm;
> +
> +	/*
> +	 * The following three variables can be packed, because
> +	 * a vmap_area object is always one of the three states:
> +	 *    1) in "free" tree (root is vmap_area_root)
> +	 *    2) in "busy" tree (root is free_vmap_area_root)
> +	 *    3) in purge list  (head is vmap_purge_list)
> +	 */
> +	union {
> +		unsigned long subtree_max_size; /* in "free" tree */
> +		struct vm_struct *vm;           /* in "busy" tree */
> +		struct llist_node purge_list;   /* in purge list */
> +	};
>  };
>  
>  /*
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index 71d8040a8a0b..39bf9cf4175a 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -329,7 +329,6 @@ EXPORT_SYMBOL(vmalloc_to_pfn);
>  #define DEBUG_AUGMENT_PROPAGATE_CHECK 0
>  #define DEBUG_AUGMENT_LOWEST_MATCH_CHECK 0
>  
> -#define VM_VM_AREA	0x04
>  
>  static DEFINE_SPINLOCK(vmap_area_lock);
>  /* Export for kexec only */
> @@ -1115,7 +1114,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
>  
>  	va->va_start = addr;
>  	va->va_end = addr + size;
> -	va->flags = 0;
> +	va->vm = NULL;
>  	insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
>  
>  	spin_unlock(&vmap_area_lock);
> @@ -1922,7 +1921,6 @@ void __init vmalloc_init(void)
>  		if (WARN_ON_ONCE(!va))
>  			continue;
>  
> -		va->flags = VM_VM_AREA;
>  		va->va_start = (unsigned long)tmp->addr;
>  		va->va_end = va->va_start + tmp->size;
>  		va->vm = tmp;
> @@ -2020,7 +2018,6 @@ static void setup_vmalloc_vm(struct vm_struct *vm, struct vmap_area *va,
>  	vm->size = va->va_end - va->va_start;
>  	vm->caller = caller;
>  	va->vm = vm;
> -	va->flags |= VM_VM_AREA;
>  	spin_unlock(&vmap_area_lock);
>  }
>  
> @@ -2125,10 +2122,10 @@ struct vm_struct *find_vm_area(const void *addr)
>  	struct vmap_area *va;
>  
>  	va = find_vmap_area((unsigned long)addr);
> -	if (va && va->flags & VM_VM_AREA)
> -		return va->vm;
> +	if (!va)
> +		return NULL;
>  
> -	return NULL;
> +	return va->vm;
>  }
>  
>  /**
> @@ -2149,11 +2146,10 @@ struct vm_struct *remove_vm_area(const void *addr)
>  
>  	spin_lock(&vmap_area_lock);
>  	va = __find_vmap_area((unsigned long)addr);
> -	if (va && va->flags & VM_VM_AREA) {
> +	if (va && va->vm) {
>  		struct vm_struct *vm = va->vm;
>  
>  		va->vm = NULL;
> -		va->flags &= ~VM_VM_AREA;
>  		spin_unlock(&vmap_area_lock);
>  
>  		kasan_free_shadow(vm);
> @@ -2856,7 +2852,7 @@ long vread(char *buf, char *addr, unsigned long count)
>  		if (!count)
>  			break;
>  
> -		if (!(va->flags & VM_VM_AREA))
> +		if (!va->vm)
>  			continue;
>  
>  		vm = va->vm;
> @@ -2936,7 +2932,7 @@ long vwrite(char *buf, char *addr, unsigned long count)
>  		if (!count)
>  			break;
>  
> -		if (!(va->flags & VM_VM_AREA))
> +		if (!va->vm)
>  			continue;
>  
>  		vm = va->vm;
> @@ -3466,10 +3462,10 @@ static int s_show(struct seq_file *m, void *p)
>  	va = list_entry(p, struct vmap_area, list);
>  
>  	/*
> -	 * s_show can encounter race with remove_vm_area, !VM_VM_AREA on
> -	 * behalf of vmap area is being tear down or vm_map_ram allocation.
> +	 * If !va->vm then this vmap_area object is allocated
> +	 * by vm_map_ram.
>  	 */
This point is still valid. There is a race between remove_vm_area() vs
s_show() and va->vm = NULL. So, please keep that comment.

> -	if (!(va->flags & VM_VM_AREA)) {
> +	if (!va->vm) {
>  		seq_printf(m, "0x%pK-0x%pK %7ld vm_map_ram\n",
>  			(void *)va->va_start, (void *)va->va_end,
>  			va->va_end - va->va_start);
> -- 
> 2.21.0
> 

--
Vlad Rezki

