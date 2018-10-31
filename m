Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 37FE16B026B
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 10:15:50 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 33-v6so8182795pld.19
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 07:15:50 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id m3-v6si26634367pgr.32.2018.10.31.07.15.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 07:15:49 -0700 (PDT)
Date: Wed, 31 Oct 2018 07:15:48 -0700
From: Sean Christopherson <sean.j.christopherson@intel.com>
Subject: Re: [kvm PATCH v5 3/4] kvm: vmx: refactor vmx_msrs struct for vmalloc
Message-ID: <20181031141547.GA13907@linux.intel.com>
References: <20181031132634.50440-1-marcorr@google.com>
 <20181031132634.50440-4-marcorr@google.com>
 <ea8abaf5-8c8b-1484-c6d7-e5d110e45f48@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ea8abaf5-8c8b-1484-c6d7-e5d110e45f48@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Marc Orr <marcorr@google.com>, kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, dave.hansen@linux.intel.com, kernellwp@gmail.com

On Wed, Oct 31, 2018 at 07:12:16AM -0700, Dave Hansen wrote:
> On 10/31/18 6:26 AM, Marc Orr wrote:
> > +/*
> > + * To prevent vmx_msr_entry array from crossing a page boundary, require:
> > + * sizeof(*vmx_msrs.vmx_msr_entry.val) to be a power of two. This is guaranteed
> > + * through compile-time asserts that:
> > + *   - NR_AUTOLOAD_MSRS * sizeof(struct vmx_msr_entry) is a power of two
> > + *   - NR_AUTOLOAD_MSRS * sizeof(struct vmx_msr_entry) <= PAGE_SIZE
> > + *   - The allocation of vmx_msrs.vmx_msr_entry.val is aligned to its size.
> > + */
> 
> Why do we need to prevent them from crossing a page boundary?

The VMCS takes the physical address of the load/store lists.  I
requested that this information be added to the changelog.  Marc
deferred addressing my comments since there's a decent chance
patches 3/4 and 4/4 will be dropped in the end.
