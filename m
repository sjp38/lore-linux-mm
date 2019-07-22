Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 88DCCC76194
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 22:06:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33688219BE
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 22:06:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="yjFwYyL/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33688219BE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE3B76B0003; Mon, 22 Jul 2019 18:06:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A94C66B0005; Mon, 22 Jul 2019 18:06:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 934698E0001; Mon, 22 Jul 2019 18:06:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 57F116B0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 18:06:43 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x19so24540380pgx.1
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 15:06:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eBWpO5JL209DsW6FsRi0hCq7puZqZU3/GKSiuaypbDI=;
        b=tThATQs9qBtjwy2v4pEz8/gdFY2w9yi9YQ/r146cOI7lnhvTkuq+heURnHKcSu5UAn
         tTk8b8HUWwFaBLuUw+GjuqbH+bIgbVqAoUTR8iCpK0uyeB/nGYSXgy5bL5dB4a7qGVop
         ZiqXSHtbLBk2+f8aRkp79KLNgVCV0TTefZVX2EMlB7WdktQuy09dmumf2QBkGTgn+GeX
         J8zgbK5b6hypOP/uXJuA0IrJjxJ//2H/jfKPgAugvX5xfQmA9MaI5gaIQN+Fc7Sg9l7Y
         9kBrM3Vu0xyZAoFmRJ69FGuO0WdcXwwKDz9BHbPm9XS1Ll+FWuxfl3gvT6cfg93w4Fgd
         CVvA==
X-Gm-Message-State: APjAAAV1jKsMvPvi0mdusytYw9rDk7QW/8s1uoHnQ7dAITy31q4jmqfZ
	8/5jNopiZkT0RaYPJx21OT5tHCleIoTDsCEPvFDyl8A81QON4uLbWT8ySmQ3/xe0+T9bxe1UGfO
	7HplqifUMzoqkv2P7YGPxuPkjStZ+/6V+1WXmQkvnDNO8CSv4yxrrNhCiAnGqlSC8Xw==
X-Received: by 2002:a17:902:29a7:: with SMTP id h36mr79364877plb.158.1563833202856;
        Mon, 22 Jul 2019 15:06:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMixKAfBRBsB5SCBeigkYnrUSLEHjxXoQR4FPFT5YLPBHLRVN8SUQER8LBUBn50R6NZlv1
X-Received: by 2002:a17:902:29a7:: with SMTP id h36mr79364782plb.158.1563833201341;
        Mon, 22 Jul 2019 15:06:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563833201; cv=none;
        d=google.com; s=arc-20160816;
        b=tbmD2GENgNWad8Bp88UCapRuIZy2arkiy4WB15vIKrORFKBlsw9LfY3yspC+MWI4Sk
         jJHv6enx+itb597gBuKTHlI0k+s6Q43Ey94StqagJoK5VkN6mQwuGj++QVsoW2lXOGrm
         ZTXqv9wW9k2OqPwLk6kprgp3BDRGxk2T0eJsZ0up6zMmejnkRK687v/dQCkz5cjtrJZh
         M+dm1aALwJGbpyUBdN6ApierfgImTyX8oGC++H47weqGCKy7nnul7MIWLtQWq5PfNykr
         GqRAd4nBVNknPnlHT7YfgzUrPXvs0hpJUyWEm+DL2MmX+zvLfYKxeaaafjduDwb0hjfh
         hoAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=eBWpO5JL209DsW6FsRi0hCq7puZqZU3/GKSiuaypbDI=;
        b=BlSenwmJ4nkYKpnm6Z78YzfBqNhY9M8qQLUFudeOmJMsGM1Gv7nWrJzfgCWn3sGmSb
         2OmUAK5DxRLn/kopzMqHBzrvSANoL4EluvNwPcFhltC+HSXd6Vb9PsB6D/8NJjkbcmxm
         pq4k/C1R5E95JGDwV+X67b1OzmzPXD7sjfGX/5If55FzTwxMAtTYwtED+lce7zcDFHMK
         qi+jaHpTiW3hfvNCNYndCL0fxm3eqC3avoxX/Zhnp9/UbrdmincT2oBu2e38oQbmOLbz
         WeW5gk5r9U8D0EGZhpsIZSc1Ji0n3qmfp8/eqhGfE7EnhZa501yLvJJykxVWUZYisN6j
         3XDg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="yjFwYyL/";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id w1si11115590pll.257.2019.07.22.15.06.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jul 2019 15:06:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="yjFwYyL/";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-231-172-41.hsd1.ca.comcast.net [73.231.172.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DB32621951;
	Mon, 22 Jul 2019 22:06:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563833201;
	bh=5nheXJfXZh9EGYJuVoeoWKzlKFQQiAFCcmnXbSdqDj4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=yjFwYyL/Ej+x5/qE+N0sSypFnxT4FSjAd5oLBXthEuf5i0r6YVoXroFynVCgaf8SO
	 pNM5YtoMaWuf5zjfL/f4zS6MWzDpAGqZwbT1H7HiBib16vXplUS5i7hIkEDqFyLHw+
	 3U5KyMZ0rFPwYPPo9mSwzftMxKZc+zo9KuXE0ieA=
Date: Mon, 22 Jul 2019 15:06:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: "Joel Fernandes (Google)" <joel@joelfernandes.org>
Cc: linux-kernel@vger.kernel.org, vdavydov.dev@gmail.com, Brendan Gregg
 <bgregg@netflix.com>, kernel-team@android.com, Alexey Dobriyan
 <adobriyan@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>,
 carmenjackson@google.com, Christian Hansen <chansen3@cisco.com>, Colin Ian
 King <colin.king@canonical.com>, dancol@google.com, David Howells
 <dhowells@redhat.com>, fmayer@google.com, joaodias@google.com,
 joelaf@google.com, Jonathan Corbet <corbet@lwn.net>, Kees Cook
 <keescook@chromium.org>, Kirill Tkhai <ktkhai@virtuozzo.com>, Konstantin
 Khlebnikov <khlebnikov@yandex-team.ru>, linux-doc@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko
 <mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>, minchan@google.com,
 minchan@kernel.org, namhyung@google.com, sspatil@google.com,
 surenb@google.com, Thomas Gleixner <tglx@linutronix.de>,
 timmurray@google.com, tkjos@google.com, Vlastimil Babka <vbabka@suse.cz>,
 wvw@google.com
Subject: Re: [PATCH v1 1/2] mm/page_idle: Add support for per-pid page_idle
 using virtual indexing
Message-Id: <20190722150639.27641c63b003dd04e187fd96@linux-foundation.org>
In-Reply-To: <20190722213205.140845-1-joel@joelfernandes.org>
References: <20190722213205.140845-1-joel@joelfernandes.org>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Jul 2019 17:32:04 -0400 "Joel Fernandes (Google)" <joel@joelfernandes.org> wrote:

> The page_idle tracking feature currently requires looking up the pagemap
> for a process followed by interacting with /sys/kernel/mm/page_idle.
> This is quite cumbersome and can be error-prone too. If between
> accessing the per-PID pagemap and the global page_idle bitmap, if
> something changes with the page then the information is not accurate.

Well, it's never going to be "accurate" - something could change one
nanosecond after userspace has read the data...

Presumably with this approach the data will be "more" accurate.  How
big a problem has this inaccuracy proven to be in real-world usage?

> More over looking up PFN from pagemap in Android devices is not
> supported by unprivileged process and requires SYS_ADMIN and gives 0 for
> the PFN.
> 
> This patch adds support to directly interact with page_idle tracking at
> the PID level by introducing a /proc/<pid>/page_idle file. This
> eliminates the need for userspace to calculate the mapping of the page.
> It follows the exact same semantics as the global
> /sys/kernel/mm/page_idle, however it is easier to use for some usecases
> where looking up PFN is not needed and also does not require SYS_ADMIN.
> It ended up simplifying userspace code, solving the security issue
> mentioned and works quite well. SELinux does not need to be turned off
> since no pagemap look up is needed.
> 
> In Android, we are using this for the heap profiler (heapprofd) which
> profiles and pin points code paths which allocates and leaves memory
> idle for long periods of time.
> 
> Documentation material:
> The idle page tracking API for virtual address indexing using virtual page
> frame numbers (VFN) is located at /proc/<pid>/page_idle. It is a bitmap
> that follows the same semantics as /sys/kernel/mm/page_idle/bitmap
> except that it uses virtual instead of physical frame numbers.
> 
> This idle page tracking API can be simpler to use than physical address
> indexing, since the pagemap for a process does not need to be looked up
> to mark or read a page's idle bit. It is also more accurate than
> physical address indexing since in physical address indexing, address
> space changes can occur between reading the pagemap and reading the
> bitmap. In virtual address indexing, the process's mmap_sem is held for
> the duration of the access.
> 
> ...
>
> --- a/mm/page_idle.c
> +++ b/mm/page_idle.c
> @@ -11,6 +11,7 @@
>  #include <linux/mmu_notifier.h>
>  #include <linux/page_ext.h>
>  #include <linux/page_idle.h>
> +#include <linux/sched/mm.h>
>  
>  #define BITMAP_CHUNK_SIZE	sizeof(u64)
>  #define BITMAP_CHUNK_BITS	(BITMAP_CHUNK_SIZE * BITS_PER_BYTE)
> @@ -28,15 +29,12 @@
>   *
>   * This function tries to get a user memory page by pfn as described above.
>   */

Above comment needs updating or moving?

> -static struct page *page_idle_get_page(unsigned long pfn)
> +static struct page *page_idle_get_page(struct page *page_in)
>  {
>  	struct page *page;
>  	pg_data_t *pgdat;
>  
> -	if (!pfn_valid(pfn))
> -		return NULL;
> -
> -	page = pfn_to_page(pfn);
> +	page = page_in;
>  	if (!page || !PageLRU(page) ||
>  	    !get_page_unless_zero(page))
>  		return NULL;
>
> ...
>
> +static int page_idle_get_frames(loff_t pos, size_t count, struct mm_struct *mm,
> +				unsigned long *start, unsigned long *end)
> +{
> +	unsigned long max_frame;
> +
> +	/* If an mm is not given, assume we want physical frames */
> +	max_frame = mm ? (mm->task_size >> PAGE_SHIFT) : max_pfn;
> +
> +	if (pos % BITMAP_CHUNK_SIZE || count % BITMAP_CHUNK_SIZE)
> +		return -EINVAL;
> +
> +	*start = pos * BITS_PER_BYTE;
> +	if (*start >= max_frame)
> +		return -ENXIO;

Is said to mean "The system tried to use the device represented by a
file you specified, and it couldnt find the device.  This can mean that
the device file was installed incorrectly, or that the physical device
is missing or not correctly attached to the computer."

This doesn't seem appropriate in this usage and is hence possibly
misleading.  Someone whose application fails with ENXIO will be
scratching their heads.

> +	*end = *start + count * BITS_PER_BYTE;
> +	if (*end > max_frame)
> +		*end = max_frame;
> +	return 0;
> +}
> +
>
> ...
>
> +static void add_page_idle_list(struct page *page,
> +			       unsigned long addr, struct mm_walk *walk)
> +{
> +	struct page *page_get;
> +	struct page_node *pn;
> +	int bit;
> +	unsigned long frames;
> +	struct page_idle_proc_priv *priv = walk->private;
> +	u64 *chunk = (u64 *)priv->buffer;
> +
> +	if (priv->write) {
> +		/* Find whether this page was asked to be marked */
> +		frames = (addr - priv->start_addr) >> PAGE_SHIFT;
> +		bit = frames % BITMAP_CHUNK_BITS;
> +		chunk = &chunk[frames / BITMAP_CHUNK_BITS];
> +		if (((*chunk >> bit) & 1) == 0)
> +			return;
> +	}
> +
> +	page_get = page_idle_get_page(page);
> +	if (!page_get)
> +		return;
> +
> +	pn = kmalloc(sizeof(*pn), GFP_ATOMIC);

I'm not liking this GFP_ATOMIC.  If I'm reading the code correctly,
userspace can ask for an arbitrarily large number of GFP_ATOMIC
allocations by doing a large read.  This can potentially exhaust page
reserves which things like networking Rx interrupts need and can make
this whole feature less reliable.

> +	if (!pn)
> +		return;
> +
> +	pn->page = page_get;
> +	pn->addr = addr;
> +	list_add(&pn->list, &idle_page_list);
> +}
> +
> +static int pte_page_idle_proc_range(pmd_t *pmd, unsigned long addr,
> +				    unsigned long end,
> +				    struct mm_walk *walk)
> +{
> +	struct vm_area_struct *vma = walk->vma;
> +	pte_t *pte;
> +	spinlock_t *ptl;
> +	struct page *page;
> +
> +	ptl = pmd_trans_huge_lock(pmd, vma);
> +	if (ptl) {
> +		if (pmd_present(*pmd)) {
> +			page = follow_trans_huge_pmd(vma, addr, pmd,
> +						     FOLL_DUMP|FOLL_WRITE);
> +			if (!IS_ERR_OR_NULL(page))
> +				add_page_idle_list(page, addr, walk);
> +		}
> +		spin_unlock(ptl);
> +		return 0;
> +	}
> +
> +	if (pmd_trans_unstable(pmd))
> +		return 0;
> +
> +	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
> +	for (; addr != end; pte++, addr += PAGE_SIZE) {
> +		if (!pte_present(*pte))
> +			continue;
> +
> +		page = vm_normal_page(vma, addr, *pte);
> +		if (page)
> +			add_page_idle_list(page, addr, walk);
> +	}
> +
> +	pte_unmap_unlock(pte - 1, ptl);
> +	return 0;
> +}
> +
> +ssize_t page_idle_proc_generic(struct file *file, char __user *ubuff,
> +			       size_t count, loff_t *pos,
> +			       struct task_struct *tsk, int write)
> +{
> +	int ret;
> +	char *buffer;
> +	u64 *out;
> +	unsigned long start_addr, end_addr, start_frame, end_frame;
> +	struct mm_struct *mm = file->private_data;
> +	struct mm_walk walk = { .pmd_entry = pte_page_idle_proc_range, };
> +	struct page_node *cur, *next;
> +	struct page_idle_proc_priv priv;
> +	bool walk_error = false;
> +
> +	if (!mm || !mmget_not_zero(mm))
> +		return -EINVAL;
> +
> +	if (count > PAGE_SIZE)
> +		count = PAGE_SIZE;
> +
> +	buffer = kzalloc(PAGE_SIZE, GFP_KERNEL);
> +	if (!buffer) {
> +		ret = -ENOMEM;
> +		goto out_mmput;
> +	}
> +	out = (u64 *)buffer;
> +
> +	if (write && copy_from_user(buffer, ubuff, count)) {
> +		ret = -EFAULT;
> +		goto out;
> +	}
> +
> +	ret = page_idle_get_frames(*pos, count, mm, &start_frame, &end_frame);
> +	if (ret)
> +		goto out;
> +
> +	start_addr = (start_frame << PAGE_SHIFT);
> +	end_addr = (end_frame << PAGE_SHIFT);
> +	priv.buffer = buffer;
> +	priv.start_addr = start_addr;
> +	priv.write = write;
> +	walk.private = &priv;
> +	walk.mm = mm;
> +
> +	down_read(&mm->mmap_sem);
> +
> +	/*
> +	 * Protects the idle_page_list which is needed because
> +	 * walk_page_vma() holds ptlock which deadlocks with
> +	 * page_idle_clear_pte_refs(). So we have to collect all
> +	 * pages first, and then call page_idle_clear_pte_refs().
> +	 */
> +	spin_lock(&idle_page_list_lock);
> +	ret = walk_page_range(start_addr, end_addr, &walk);
> +	if (ret)
> +		walk_error = true;
> +
> +	list_for_each_entry_safe(cur, next, &idle_page_list, list) {
> +		int bit, index;
> +		unsigned long off;
> +		struct page *page = cur->page;
> +
> +		if (unlikely(walk_error))
> +			goto remove_page;
> +
> +		if (write) {
> +			page_idle_clear_pte_refs(page);
> +			set_page_idle(page);
> +		} else {
> +			if (page_really_idle(page)) {
> +				off = ((cur->addr) >> PAGE_SHIFT) - start_frame;
> +				bit = off % BITMAP_CHUNK_BITS;
> +				index = off / BITMAP_CHUNK_BITS;
> +				out[index] |= 1ULL << bit;
> +			}
> +		}
> +remove_page:
> +		put_page(page);
> +		list_del(&cur->list);
> +		kfree(cur);
> +	}
> +	spin_unlock(&idle_page_list_lock);
> +
> +	if (!write && !walk_error)
> +		ret = copy_to_user(ubuff, buffer, count);
> +
> +	up_read(&mm->mmap_sem);
> +out:
> +	kfree(buffer);
> +out_mmput:
> +	mmput(mm);
> +	if (!ret)
> +		ret = count;
> +	return ret;
> +
> +}
> +
> +ssize_t page_idle_proc_read(struct file *file, char __user *ubuff,
> +			    size_t count, loff_t *pos, struct task_struct *tsk)
> +{
> +	return page_idle_proc_generic(file, ubuff, count, pos, tsk, 0);
> +}
> +
> +ssize_t page_idle_proc_write(struct file *file, char __user *ubuff,
> +			     size_t count, loff_t *pos, struct task_struct *tsk)
> +{
> +	return page_idle_proc_generic(file, ubuff, count, pos, tsk, 1);
> +}
> +
>  static int __init page_idle_init(void)
>  {
>  	int err;
>  
> +	INIT_LIST_HEAD(&idle_page_list);
> +
>  	err = sysfs_create_group(mm_kobj, &page_idle_attr_group);
>  	if (err) {
>  		pr_err("page_idle: register sysfs failed\n");
> -- 
>
> ...
>

