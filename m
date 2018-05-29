Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 59D5E6B0007
	for <linux-mm@kvack.org>; Tue, 29 May 2018 10:51:56 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id z16-v6so4007088pge.21
        for <linux-mm@kvack.org>; Tue, 29 May 2018 07:51:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id t17-v6si32751327pfj.10.2018.05.29.07.51.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 May 2018 07:51:55 -0700 (PDT)
Date: Tue, 29 May 2018 07:50:55 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Change return type to vm_fault_t
Message-ID: <20180529145055.GA15148@bombadil.infradead.org>
References: <20180529143126.GA19698@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180529143126.GA19698@jordon-HP-15-Notebook-PC>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: viro@zeniv.linux.org.uk, hughd@google.com, akpm@linux-foundation.org, mhocko@suse.com, ross.zwisler@linux.intel.com, zi.yan@cs.rutgers.edu, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, gregkh@linuxfoundation.org, mark.rutland@arm.com, riel@redhat.com, pasha.tatashin@oracle.com, jschoenh@amazon.de, kstewart@linuxfoundation.org, rientjes@google.com, tglx@linutronix.de, peterz@infradead.org, mgorman@suse.de, yang.s@alibaba-inc.com, minchan@kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, May 29, 2018 at 08:01:26PM +0530, Souptick Joarder wrote:
> Use new return type vm_fault_t for fault handler. For
> now, this is just documenting that the function returns
> a VM_FAULT value rather than an errno. Once all instances
> are converted, vm_fault_t will become a distinct type.

I don't believe you've checked this with sparse.

> @@ -802,7 +802,8 @@ int fixup_user_fault(struct task_struct *tsk, struct mm_struct *mm,
>  		     bool *unlocked)
>  {
>  	struct vm_area_struct *vma;
> -	int ret, major = 0;
> +	int major = 0;
> +	vm_fault_t ret;
>  
>  	if (unlocked)
>  		fault_flags |= FAULT_FLAG_ALLOW_RETRY;

...
        major |= ret & VM_FAULT_MAJOR;

That should be throwing a warning.
