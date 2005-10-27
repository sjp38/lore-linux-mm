Message-Id: <200510270016.j9R0Gdg26347@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: RFC: Cleanup / small fixes to hugetlb fault handling
Date: Wed, 26 Oct 2005 17:16:39 -0700
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20051027000504.GC14742@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'David Gibson' <david@gibson.dropbear.id.au>
Cc: Adam Litke <agl@us.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hugh@veritas.com, William Irwin <wli@holomorphy.com>
List-ID: <linux-mm.kvack.org>

David Gibson wrote on Wednesday, October 26, 2005 5:05 PM
> On Wed, Oct 26, 2005 at 11:44:52AM -0700, Chen, Kenneth W wrote:
> > David Gibson wrote on Tuesday, October 25, 2005 7:49 PM
> > > +int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> > > +		  unsigned long address, int write_access)
> > > +{
> > > +	pte_t *ptep;
> > > +	pte_t entry;
> > > +
> > > +	ptep = huge_pte_alloc(mm, address);
> > > +	if (! ptep)
> > > +		/* OOM */
> > > +		return VM_FAULT_SIGBUS;
> > > +
> > > +	entry = *ptep;
> > > +
> > > +	if (pte_none(entry))
> > > +		return hugetlb_no_page(mm, vma, address, ptep);
> > > +
> > > +	/* we could get here if another thread instantiated the pte
> > > +	 * before the test above */
> > > +
> > > +	return VM_FAULT_SIGBUS;
> > >  }
> > 
> > Are you sure about the last return?  Looks like a typo to me, if *ptep
> > is present, it should return VM_FAULT_MINOR.
> 
> Oops, yes, thinko.  Corrected patch shortly.

While you at it, I think it would be preferable that the first return be
VM_FAULT_OOM, your thoughts?

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
