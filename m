Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6DB1D6B06DD
	for <linux-mm@kvack.org>; Sat, 12 May 2018 02:20:34 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id e22-v6so4216602ita.0
        for <linux-mm@kvack.org>; Fri, 11 May 2018 23:20:34 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0237.hostedemail.com. [216.40.44.237])
        by mx.google.com with ESMTPS id j73-v6si4145931ioi.238.2018.05.11.23.20.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 May 2018 23:20:33 -0700 (PDT)
Message-ID: <e194731158f7f89145ed0ae28f46aac5726fc32d.camel@perches.com>
Subject: Re: [PATCH v3] mm: Change return type to vm_fault_t
From: Joe Perches <joe@perches.com>
Date: Fri, 11 May 2018 23:20:29 -0700
In-Reply-To: <20180512061712.GA26660@jordon-HP-15-Notebook-PC>
References: <20180512061712.GA26660@jordon-HP-15-Notebook-PC>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>, akpm@linux-foundation.org, mhocko@suse.com, hughd@google.com, dan.j.williams@intel.com, rientjes@google.com, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@infradead.org

On Sat, 2018-05-12 at 11:47 +0530, Souptick Joarder wrote:
> Use new return type vm_fault_t for fault handler
> in struct vm_operations_struct. For now, this is
> just documenting that the function returns a
> VM_FAULT value rather than an errno.  Once all
> instances are converted, vm_fault_t will become
> a distinct type.

trivia:

> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
[]
> @@ -627,7 +627,7 @@ struct vm_special_mapping {
>  	 * If non-NULL, then this is called to resolve page faults
>  	 * on the special mapping.  If used, .pages is not checked.
>  	 */
> -	int (*fault)(const struct vm_special_mapping *sm,
> +	vm_fault_t (*fault)(const struct vm_special_mapping *sm,
>  		     struct vm_area_struct *vma,
>  		     struct vm_fault *vmf);


It'd be nicer to realign the 2nd and 3rd arguments
on the subsequent lines.

	vm_fault_t (*fault)(const struct vm_special_mapping *sm,
			    struct vm_area_struct *vma,
			    struct vm_fault *vmf);
