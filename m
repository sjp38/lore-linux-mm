Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 777D26B0274
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 19:48:31 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id d123so1670234pfd.0
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 16:48:31 -0800 (PST)
Received: from mail-pg0-x236.google.com (mail-pg0-x236.google.com. [2607:f8b0:400e:c05::236])
        by mx.google.com with ESMTPS id t2si15861219pgb.296.2017.02.01.16.48.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 16:48:30 -0800 (PST)
Received: by mail-pg0-x236.google.com with SMTP id 194so377308pgd.2
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 16:48:30 -0800 (PST)
Date: Wed, 1 Feb 2017 16:48:28 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/4] mm: Fix checkpatch warnings, whitespace
In-Reply-To: <1485992240-10986-3-git-send-email-me@tobin.cc>
Message-ID: <alpine.DEB.2.10.1702011648160.58909@chino.kir.corp.google.com>
References: <1485992240-10986-1-git-send-email-me@tobin.cc> <1485992240-10986-3-git-send-email-me@tobin.cc>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Tobin C. Harding" <me@tobin.cc>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Michal Hocko <mhocko@suse.com>

On Thu, 2 Feb 2017, Tobin C. Harding wrote:

> @@ -3696,8 +3695,8 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
>                   * VM_FAULT_OOM), there is no need to kill anything.
>                   * Just clean up the OOM state peacefully.
>                   */
> -                if (task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))
> -                        mem_cgroup_oom_synchronize(false);
> +		if (task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))
> +			mem_cgroup_oom_synchronize(false);
>  	}
>  
>  	/*

The comment suffers from the same problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
