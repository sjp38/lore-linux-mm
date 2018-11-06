Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 000696B049E
	for <linux-mm@kvack.org>; Tue,  6 Nov 2018 17:49:54 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id s141-v6so12649368pgs.23
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 14:49:54 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 9si2387001pgm.112.2018.11.06.14.49.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 14:49:53 -0800 (PST)
Subject: Re: [kvm PATCH v7 2/2] kvm: x86: Dynamically allocate guest_fpu
References: <20181106222009.90833-1-marcorr@google.com>
 <20181106222009.90833-3-marcorr@google.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <ff90f374-caea-9530-0c90-b27d00efacc1@intel.com>
Date: Tue, 6 Nov 2018 14:49:52 -0800
MIME-Version: 1.0
In-Reply-To: <20181106222009.90833-3-marcorr@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc Orr <marcorr@google.com>, kvm@vger.kernel.org, jmattson@google.com, rientjes@google.com, konrad.wilk@oracle.com, linux-mm@kvack.org, akpm@linux-foundation.org, pbonzini@redhat.com, rkrcmar@redhat.com, willy@infradead.org, sean.j.christopherson@intel.com, dave.hansen@linux.intel.com, kernellwp@gmail.com

On 11/6/18 2:20 PM, Marc Orr wrote:
>  	r = -ENOMEM;
> +	x86_fpu_cache = kmem_cache_create_usercopy(
> +				"x86_fpu",
> +				fpu_kernel_xstate_size,
> +				__alignof__(struct fpu),
> +				SLAB_ACCOUNT,
> +				offsetof(struct fpu, state),
> +				fpu_kernel_xstate_size,
> +				NULL);

I thought we came to the conclusion with Paulo that this should not be
"usercopy" at all.

Did you send out an old version?
