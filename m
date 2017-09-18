Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3E38E6B0033
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 09:45:43 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id c195so1395048itb.5
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 06:45:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v199si4407677oie.26.2017.09.18.06.45.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Sep 2017 06:45:42 -0700 (PDT)
Subject: Re: [patch] mremap.2: Add description of old_size == 0 functionality
References: <20170915213745.6821-1-mike.kravetz@oracle.com>
 <a6e59a7f-fd15-9e49-356e-ed439f17e9df@oracle.com>
From: Florian Weimer <fweimer@redhat.com>
Message-ID: <fb013ae6-6f47-248b-db8b-a0abae530377@redhat.com>
Date: Mon, 18 Sep 2017 15:45:37 +0200
MIME-Version: 1.0
In-Reply-To: <a6e59a7f-fd15-9e49-356e-ed439f17e9df@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, mtk.manpages@gmail.com
Cc: linux-man@vger.kernel.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org

On 09/15/2017 11:53 PM, Mike Kravetz wrote:
> +If the value of \fIold_size\fP is zero, and \fIold_address\fP refers to
> +a private anonymous mapping, then
> +.BR mremap ()
> +will create a new mapping of the same pages. \fInew_size\fP
> +will be the size of the new mapping and the location of the new mapping
> +may be specified with \fInew_address\fP, see the description of
> +.B MREMAP_FIXED
> +below.  If a new mapping is requested via this method, then the
> +.B MREMAP_MAYMOVE
> +flag must also be specified.  This functionality is deprecated, and no
> +new code should be written to use this feature.  A better method of
> +obtaining multiple mappings of the same private anonymous memory is via the
> +.BR memfd_create()
> +system call.

Is there any particular reason to deprecate this?

In glibc, we cannot use memfd_create and keep the file descriptor around 
because the application can close descriptors beneath us.

(We might want to use alias mappings to avoid run-time code generation 
for PLT-less LD_AUDIT interceptors.)

Thanks,
Florian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
