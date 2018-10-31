Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id ED7E76B0010
	for <linux-mm@kvack.org>; Wed, 31 Oct 2018 10:12:18 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j2-v6so13656569pfi.18
        for <linux-mm@kvack.org>; Wed, 31 Oct 2018 07:12:18 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id s36-v6si16847894pld.387.2018.10.31.07.12.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Oct 2018 07:12:17 -0700 (PDT)
Subject: Re: [kvm PATCH v5 3/4] kvm: vmx: refactor vmx_msrs struct for vmalloc
References: <20181031132634.50440-1-marcorr@google.com>
 <20181031132634.50440-4-marcorr@google.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <ea8abaf5-8c8b-1484-c6d7-e5d110e45f48@intel.com>
Date: Wed, 31 Oct 2018 07:12:16 -0700
MIME-Version: 1.0
In-Reply-To: <20181031132634.50440-4-marcorr@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Orr <marcorr@google.com>, kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, kernellwp@gmail.com

On 10/31/18 6:26 AM, Marc Orr wrote:
> +/*
> + * To prevent vmx_msr_entry array from crossing a page boundary, require:
> + * sizeof(*vmx_msrs.vmx_msr_entry.val) to be a power of two. This is guaranteed
> + * through compile-time asserts that:
> + *   - NR_AUTOLOAD_MSRS * sizeof(struct vmx_msr_entry) is a power of two
> + *   - NR_AUTOLOAD_MSRS * sizeof(struct vmx_msr_entry) <= PAGE_SIZE
> + *   - The allocation of vmx_msrs.vmx_msr_entry.val is aligned to its size.
> + */

Why do we need to prevent them from crossing a page boundary?
