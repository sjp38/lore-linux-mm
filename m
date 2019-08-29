Return-Path: <SRS0=qe68=WZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 905B2C3A59F
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 06:56:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DF0D215EA
	for <linux-mm@archiver.kernel.org>; Thu, 29 Aug 2019 06:56:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DF0D215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64A126B0005; Thu, 29 Aug 2019 02:56:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5FBC46B0006; Thu, 29 Aug 2019 02:56:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4EAB06B000C; Thu, 29 Aug 2019 02:56:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0210.hostedemail.com [216.40.44.210])
	by kanga.kvack.org (Postfix) with ESMTP id 26AC36B0005
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 02:56:55 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id BDF1D181AC9AE
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 06:56:54 +0000 (UTC)
X-FDA: 75874557948.07.slope51_767985e3e4c1a
X-HE-Tag: slope51_767985e3e4c1a
X-Filterd-Recvd-Size: 16849
Received: from mx0b-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com [148.163.158.5])
	by imf50.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 06:56:54 +0000 (UTC)
Received: from pps.filterd (m0127361.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x7T6qxKJ081842
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 02:56:53 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2umnmwtuw2-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 29 Aug 2019 02:56:52 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bharata@linux.ibm.com>;
	Thu, 29 Aug 2019 07:56:50 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 29 Aug 2019 07:56:48 +0100
Received: from d06av23.portsmouth.uk.ibm.com (d06av23.portsmouth.uk.ibm.com [9.149.105.59])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x7T6ukH142729478
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 29 Aug 2019 06:56:46 GMT
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 6D3ACA405D;
	Thu, 29 Aug 2019 06:56:46 +0000 (GMT)
Received: from d06av23.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AB747A404D;
	Thu, 29 Aug 2019 06:56:44 +0000 (GMT)
Received: from in.ibm.com (unknown [9.124.35.109])
	by d06av23.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 29 Aug 2019 06:56:44 +0000 (GMT)
Date: Thu, 29 Aug 2019 12:26:42 +0530
From: Bharata B Rao <bharata@linux.ibm.com>
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, kvm-ppc@vger.kernel.org, linux-mm@kvack.org,
        paulus@au1.ibm.com, aneesh.kumar@linux.vnet.ibm.com,
        jglisse@redhat.com, linuxram@us.ibm.com, cclaudio@linux.ibm.com,
        hch@lst.de
Subject: Re: [PATCH v7 1/7] kvmppc: Driver to manage pages of secure guest
Reply-To: bharata@linux.ibm.com
References: <20190822102620.21897-1-bharata@linux.ibm.com>
 <20190822102620.21897-2-bharata@linux.ibm.com>
 <20190829030219.GA17497@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190829030219.GA17497@us.ibm.com>
User-Agent: Mutt/1.12.1 (2019-06-15)
X-TM-AS-GCONF: 00
x-cbid: 19082906-4275-0000-0000-0000035E959B
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19082906-4276-0000-0000-00003870CBB1
Message-Id: <20190829065642.GA31913@in.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-29_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908290074
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 28, 2019 at 08:02:19PM -0700, Sukadev Bhattiprolu wrote:
> Some minor comments/questions below. Overall, the patches look
> fine to me.
> 
> > +#include <linux/pagemap.h>
> > +#include <linux/migrate.h>
> > +#include <linux/kvm_host.h>
> > +#include <asm/ultravisor.h>
> > +
> > +static struct dev_pagemap kvmppc_devm_pgmap;
> > +static unsigned long *kvmppc_devm_pfn_bitmap;
> > +static DEFINE_SPINLOCK(kvmppc_devm_pfn_lock);
> 
> Is this lock protecting just the pfn_bitmap?

Yes.

> 
> > +
> > +struct kvmppc_devm_page_pvt {
> > +	unsigned long *rmap;
> > +	unsigned int lpid;
> > +	unsigned long gpa;
> > +};
> > +
> > +/*
> > + * Get a free device PFN from the pool
> > + *
> > + * Called when a normal page is moved to secure memory (UV_PAGE_IN). Device
> > + * PFN will be used to keep track of the secure page on HV side.
> > + *
> > + * @rmap here is the slot in the rmap array that corresponds to @gpa.
> > + * Thus a non-zero rmap entry indicates that the corresponding guest
> > + * page has become secure, and is not mapped on the HV side.
> > + *
> > + * NOTE: In this and subsequent functions, we pass around and access
> > + * individual elements of kvm_memory_slot->arch.rmap[] without any
> > + * protection. Should we use lock_rmap() here?
> > + */
> > +static struct page *kvmppc_devm_get_page(unsigned long *rmap, unsigned long gpa,
> > +					 unsigned int lpid)
> > +{
> > +	struct page *dpage = NULL;
> > +	unsigned long bit, devm_pfn;
> > +	unsigned long flags;
> > +	struct kvmppc_devm_page_pvt *pvt;
> > +	unsigned long pfn_last, pfn_first;
> > +
> > +	if (kvmppc_rmap_is_devm_pfn(*rmap))
> > +		return NULL;
> > +
> > +	pfn_first = kvmppc_devm_pgmap.res.start >> PAGE_SHIFT;
> > +	pfn_last = pfn_first +
> > +		   (resource_size(&kvmppc_devm_pgmap.res) >> PAGE_SHIFT);
> > +	spin_lock_irqsave(&kvmppc_devm_pfn_lock, flags);
> 
> Blank lines around spin_lock() would help.

You mean blank line before lock and after unlock to clearly see
where the lock starts and ends?

> 
> > +	bit = find_first_zero_bit(kvmppc_devm_pfn_bitmap, pfn_last - pfn_first);
> > +	if (bit >= (pfn_last - pfn_first))
> > +		goto out;
> > +
> > +	bitmap_set(kvmppc_devm_pfn_bitmap, bit, 1);
> > +	devm_pfn = bit + pfn_first;
> 
> Can we drop the &kvmppc_devm_pfn_lock here or after the trylock_page()?
> Or does it also protect the ->zone_device_data' assignment below as well?
> If so, maybe drop the 'pfn_' from the name of the lock?
> 
> Besides, we don't seem to hold this lock when accessing ->zone_device_data
> in kvmppc_share_page(). Maybe &kvmppc_devm_pfn_lock just protects the bitmap?

Will move the unlock to appropriately.

> 
> 
> > +	dpage = pfn_to_page(devm_pfn);
> 
> Does this code and hence CONFIG_PPC_UV depend on a specific model like
> CONFIG_SPARSEMEM_VMEMMAP?

I don't think so. Irrespective of that pfn_to_page() should just work
for us.

> > +
> > +	if (!trylock_page(dpage))
> > +		goto out_clear;
> > +
> > +	*rmap = devm_pfn | KVMPPC_RMAP_DEVM_PFN;
> > +	pvt = kzalloc(sizeof(*pvt), GFP_ATOMIC);
> > +	if (!pvt)
> > +		goto out_unlock;
> > +	pvt->rmap = rmap;
> > +	pvt->gpa = gpa;
> > +	pvt->lpid = lpid;
> > +	dpage->zone_device_data = pvt;
> 
> ->zone_device_data is set after locking the dpage here, but in
> kvmppc_share_page() and kvmppc_devm_fault_migrate_alloc_and_copy()
> it is accessed without locking the page?
> 
> > +	spin_unlock_irqrestore(&kvmppc_devm_pfn_lock, flags);
> > +
> > +	get_page(dpage);
> > +	return dpage;
> > +
> > +out_unlock:
> > +	unlock_page(dpage);
> > +out_clear:
> > +	bitmap_clear(kvmppc_devm_pfn_bitmap, devm_pfn - pfn_first, 1);
> > +out:
> > +	spin_unlock_irqrestore(&kvmppc_devm_pfn_lock, flags);
> > +	return NULL;
> > +}
> > +
> > +/*
> > + * Alloc a PFN from private device memory pool and copy page from normal
> > + * memory to secure memory.
> > + */
> > +static int
> > +kvmppc_devm_migrate_alloc_and_copy(struct migrate_vma *mig,
> > +				   unsigned long *rmap, unsigned long gpa,
> > +				   unsigned int lpid, unsigned long page_shift)
> > +{
> > +	struct page *spage = migrate_pfn_to_page(*mig->src);
> > +	unsigned long pfn = *mig->src >> MIGRATE_PFN_SHIFT;
> > +	struct page *dpage;
> > +
> > +	*mig->dst = 0;
> > +	if (!spage || !(*mig->src & MIGRATE_PFN_MIGRATE))
> > +		return 0;
> > +
> > +	dpage = kvmppc_devm_get_page(rmap, gpa, lpid);
> > +	if (!dpage)
> > +		return -EINVAL;
> > +
> > +	if (spage)
> > +		uv_page_in(lpid, pfn << page_shift, gpa, 0, page_shift);
> > +
> > +	*mig->dst = migrate_pfn(page_to_pfn(dpage)) | MIGRATE_PFN_LOCKED;
> > +	return 0;
> > +}
> > +
> > +/*
> > + * Move page from normal memory to secure memory.
> > + */
> > +unsigned long
> > +kvmppc_h_svm_page_in(struct kvm *kvm, unsigned long gpa,
> > +		     unsigned long flags, unsigned long page_shift)
> > +{
> > +	unsigned long addr, end;
> > +	unsigned long src_pfn, dst_pfn;
> 
> These are the host frame numbers correct? Trying to distinguish them
> from 'gfn' and 'gpa' used in the function.

Yes host pfns.

> 
> > +	struct migrate_vma mig;
> > +	struct vm_area_struct *vma;
> > +	int srcu_idx;
> > +	unsigned long gfn = gpa >> page_shift;
> > +	struct kvm_memory_slot *slot;
> > +	unsigned long *rmap;
> > +	int ret;
> > +
> > +	if (page_shift != PAGE_SHIFT)
> > +		return H_P3;
> > +
> > +	if (flags)
> > +		return H_P2;
> > +
> > +	ret = H_PARAMETER;
> > +	down_read(&kvm->mm->mmap_sem);
> > +	srcu_idx = srcu_read_lock(&kvm->srcu);
> > +	slot = gfn_to_memslot(kvm, gfn);
> 
> Can slot be NULL? could be a bug in UV...

Will add a check to test this failure.

> 
> > +	rmap = &slot->arch.rmap[gfn - slot->base_gfn];
> > +	addr = gfn_to_hva(kvm, gpa >> page_shift);
> 
> Use 'gfn' as the second parameter? 

Yes.

> 
> Nit. for consistency with gpa and gfn, maybe rename 'addr' to
> 'hva' or to match 'end' maybe to 'start'.

Guess using hva improves readability, sure.

> 
> Also, can we check 'kvmppc_rmap_is_devm_pfn(*rmap)' here and bail out
> if its already shared? We currently do it further down the call chain
> in kvmppc_devm_get_page() after doing more work.

If the page is already shared, we just give the same back to UV if
UV indeed asks for it to be re-shared.

That said, I think we can have kvmppc_rmap_is_devm_pfn early in
regular page-in (non-shared case) path so that we don't even setup
anything required for migrate_vma_pages.

> 
> 
> > +	if (kvm_is_error_hva(addr))
> > +		goto out;
> > +
> > +	end = addr + (1UL << page_shift);
> > +	vma = find_vma_intersection(kvm->mm, addr, end);
> > +	if (!vma || vma->vm_start > addr || vma->vm_end < end)
> > +		goto out;
> > +
> > +	memset(&mig, 0, sizeof(mig));
> > +	mig.vma = vma;
> > +	mig.start = addr;
> > +	mig.end = end;
> > +	mig.src = &src_pfn;
> > +	mig.dst = &dst_pfn;
> > +
> > +	if (migrate_vma_setup(&mig))
> > +		goto out;
> > +
> > +	if (kvmppc_devm_migrate_alloc_and_copy(&mig, rmap, gpa,
> > +					       kvm->arch.lpid, page_shift))
> > +		goto out_finalize;
> > +
> > +	migrate_vma_pages(&mig);
> > +	ret = H_SUCCESS;
> > +out_finalize:
> > +	migrate_vma_finalize(&mig);
> > +out:
> > +	srcu_read_unlock(&kvm->srcu, srcu_idx);
> > +	up_read(&kvm->mm->mmap_sem);
> > +	return ret;
> > +}
> > +
> > +/*
> > + * Provision a new page on HV side and copy over the contents
> > + * from secure memory.
> > + */
> > +static int
> > +kvmppc_devm_fault_migrate_alloc_and_copy(struct migrate_vma *mig,
> > +					 unsigned long page_shift)
> > +{
> > +	struct page *dpage, *spage;
> > +	struct kvmppc_devm_page_pvt *pvt;
> > +	unsigned long pfn;
> > +	int ret;
> > +
> > +	spage = migrate_pfn_to_page(*mig->src);
> > +	if (!spage || !(*mig->src & MIGRATE_PFN_MIGRATE))
> > +		return 0;
> > +	if (!is_zone_device_page(spage))
> > +		return 0;
> 
> What does it mean if its not a zone_device page at this point? Caller
> would then proceed to migrage_vma_pages() if we return 0 right?

kvmppc_devm_fault_migrate_alloc_and_copy() can be called from two paths:

1. Fault path when HV touches the secure page. In this case the page
has to be a device page.

2. When page-out is issued for a page that is already paged-in. In this
case also it has be a device page.

For both the above cases, that check is redundant.

There is a 3rd case which is possible. If UV ever issues a page-out
for a shared page, this check will result in page-out hcall silently
succeeding w/o doing any migration (as we don't populate the dst_pfn)

> 
> > +
> > +	dpage = alloc_page_vma(GFP_HIGHUSER, mig->vma, mig->start);
> > +	if (!dpage)
> > +		return -EINVAL;
> > +	lock_page(dpage);
> > +	pvt = spage->zone_device_data;
> > +
> > +	pfn = page_to_pfn(dpage);
> > +	ret = uv_page_out(pvt->lpid, pfn << page_shift, pvt->gpa, 0,
> > +			  page_shift);
> > +	if (ret == U_SUCCESS)
> > +		*mig->dst = migrate_pfn(pfn) | MIGRATE_PFN_LOCKED;
> > +	else {
> > +		unlock_page(dpage);
> > +		__free_page(dpage);
> > +	}
> > +	return ret;
> > +}
> > +
> > +/*
> > + * Fault handler callback when HV touches any page that has been
> > + * moved to secure memory, we ask UV to give back the page by
> > + * issuing a UV_PAGE_OUT uvcall.
> > + *
> > + * This eventually results in dropping of device PFN and the newly
> > + * provisioned page/PFN gets populated in QEMU page tables.
> > + */
> > +static vm_fault_t kvmppc_devm_migrate_to_ram(struct vm_fault *vmf)
> > +{
> > +	unsigned long src_pfn, dst_pfn = 0;
> > +	struct migrate_vma mig;
> > +	int ret = 0;
> > +
> > +	memset(&mig, 0, sizeof(mig));
> > +	mig.vma = vmf->vma;
> > +	mig.start = vmf->address;
> > +	mig.end = vmf->address + PAGE_SIZE;
> > +	mig.src = &src_pfn;
> > +	mig.dst = &dst_pfn;
> > +
> > +	if (migrate_vma_setup(&mig)) {
> > +		ret = VM_FAULT_SIGBUS;
> > +		goto out;
> > +	}
> > +
> > +	if (kvmppc_devm_fault_migrate_alloc_and_copy(&mig, PAGE_SHIFT)) {
> > +		ret = VM_FAULT_SIGBUS;
> > +		goto out_finalize;
> > +	}
> > +
> > +	migrate_vma_pages(&mig);
> > +out_finalize:
> > +	migrate_vma_finalize(&mig);
> > +out:
> > +	return ret;
> > +}
> > +
> > +/*
> > + * Release the device PFN back to the pool
> > + *
> > + * Gets called when secure page becomes a normal page during UV_PAGE_OUT.
> 
> Nit: Should that be H_SVM_PAGE_OUT?

Yes, will reword.

> 
> > + */
> > +static void kvmppc_devm_page_free(struct page *page)
> > +{
> > +	unsigned long pfn = page_to_pfn(page);
> > +	unsigned long flags;
> > +	struct kvmppc_devm_page_pvt *pvt;
> > +
> > +	spin_lock_irqsave(&kvmppc_devm_pfn_lock, flags);
> > +	pvt = page->zone_device_data;
> > +	page->zone_device_data = NULL;
> 
> If the pfn_lock only protects the bitmap, would be better to move
> it here?

Yes.

> 
> > +
> > +	bitmap_clear(kvmppc_devm_pfn_bitmap,
> > +		     pfn - (kvmppc_devm_pgmap.res.start >> PAGE_SHIFT), 1);
> > +	*pvt->rmap = 0;
> > +	spin_unlock_irqrestore(&kvmppc_devm_pfn_lock, flags);
> > +	kfree(pvt);
> > +}
> > +
> > +static const struct dev_pagemap_ops kvmppc_devm_ops = {
> > +	.page_free = kvmppc_devm_page_free,
> > +	.migrate_to_ram	= kvmppc_devm_migrate_to_ram,
> > +};
> > +
> > +/*
> > + * Move page from secure memory to normal memory.
> > + */
> > +unsigned long
> > +kvmppc_h_svm_page_out(struct kvm *kvm, unsigned long gpa,
> > +		      unsigned long flags, unsigned long page_shift)
> > +{
> > +	struct migrate_vma mig;
> > +	unsigned long addr, end;
> > +	struct vm_area_struct *vma;
> > +	unsigned long src_pfn, dst_pfn = 0;
> > +	int srcu_idx;
> > +	int ret;
> 
> Nit: Not sure its a coding style requirement, but many functions seem
> to "sort" these local variables in descending order of line length for
> appearance :-)  (eg: migrate_vma* functions).

It has ended up like this over multiple versions when variables got added,
moved and re-added.

> 
> > +
> > +	if (page_shift != PAGE_SHIFT)
> > +		return H_P3;
> > +
> > +	if (flags)
> > +		return H_P2;
> > +
> > +	ret = H_PARAMETER;
> > +	down_read(&kvm->mm->mmap_sem);
> > +	srcu_idx = srcu_read_lock(&kvm->srcu);
> > +	addr = gfn_to_hva(kvm, gpa >> page_shift);
> > +	if (kvm_is_error_hva(addr))
> > +		goto out;
> > +
> > +	end = addr + (1UL << page_shift);
> > +	vma = find_vma_intersection(kvm->mm, addr, end);
> > +	if (!vma || vma->vm_start > addr || vma->vm_end < end)
> > +		goto out;
> > +
> > +	memset(&mig, 0, sizeof(mig));
> > +	mig.vma = vma;
> > +	mig.start = addr;
> > +	mig.end = end;
> > +	mig.src = &src_pfn;
> > +	mig.dst = &dst_pfn;
> > +	if (migrate_vma_setup(&mig))
> > +		goto out;
> > +
> > +	ret = kvmppc_devm_fault_migrate_alloc_and_copy(&mig, page_shift);
> > +	if (ret)
> > +		goto out_finalize;
> > +
> > +	migrate_vma_pages(&mig);
> > +	ret = H_SUCCESS;
> 
> Nit: Blank line here?

With a blank like above the label line (which is blank for the most part),
it looks a bit too much of blank to me :)

However I do have blank line at a few other places. I have been removing
them whenever I touch the surrounding lines.

Thanks for your review.

Christoph - You did review this patch in the last iteration. Do you have
any additional comments?

Regards,
Bharata.


