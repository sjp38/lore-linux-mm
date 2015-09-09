Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7F6DE6B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 12:28:55 -0400 (EDT)
Received: by qkfq186 with SMTP id q186so6797386qkf.1
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 09:28:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f76si8825465qgd.106.2015.09.09.09.28.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 09:28:54 -0700 (PDT)
Date: Wed, 9 Sep 2015 18:26:05 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm/mmap.c: Remove useless statement "vma = NULL" in
	find_vma()
Message-ID: <20150909162605.GA4373@redhat.com>
References: <COL130-W64A6555222F8CEDA513171B9560@phx.gbl> <COL130-W6916929C85FB1943CC1B11B9530@phx.gbl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <COL130-W6916929C85FB1943CC1B11B9530@phx.gbl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <xili_gchen_5257@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "riel@redhat.com" <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "pfeiner@google.com" <pfeiner@google.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "vishnu.ps@samsung.com" <vishnu.ps@samsung.com>, Linux Memory <linux-mm@kvack.org>, kernel mailing list <linux-kernel@vger.kernel.org>

On 09/08, Chen Gang wrote:
>
> I also want to consult: the comments of find_vma() says:

Sorry, I don't understand the question ;)

> "Look up the first VMA which satisfies addr < vm_end, ..."
>
> Is it OK?

Why not?

> (why not "vm_start <= addr < vm_end"),

Because this some callers actually want to find the 1st vma which
satisfies addr < vm_end? For example, shift_arg_pages().

OTOH, I think that another helper,

	find_vma_xxx(mm, addr)
	{
		vma = find_vma(...)
		if (vma && vma->vm_start > addr)
			vma = NULL;
		return vma;
	}

makes sense. It can have a lot of users.

> need we let "vma = tmp"
> in "if (tmp->vm_start <= addr)"? -- it looks the comments is not match
> the implementation, precisely (maybe not 1st VMA).

This contradicts with above... I mean, it is not clear what exactly do
you blame, semantics or implementation.

The implementation looks correct. Why do you think it can be not 1st vma?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
