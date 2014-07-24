Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 8F7466B0083
	for <linux-mm@kvack.org>; Thu, 24 Jul 2014 15:54:43 -0400 (EDT)
Received: by mail-qa0-f54.google.com with SMTP id k15so3476853qaq.41
        for <linux-mm@kvack.org>; Thu, 24 Jul 2014 12:54:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c9si12756582qaw.71.2014.07.24.12.54.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Jul 2014 12:54:42 -0700 (PDT)
Date: Thu, 24 Jul 2014 21:53:02 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 3/5] mm, shmem: Add shmem_vma() helper
Message-ID: <20140724195302.GA28972@redhat.com>
References: <1406036632-26552-1-git-send-email-jmarchan@redhat.com> <1406036632-26552-4-git-send-email-jmarchan@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1406036632-26552-4-git-send-email-jmarchan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Marchand <jmarchan@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, linux-doc@vger.kernel.org, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Ingo Molnar <mingo@redhat.com>, Paul Mackerras <paulus@samba.org>, Peter Zijlstra <a.p.zijls@redhat.com>

On 07/22, Jerome Marchand wrote:
>
> +bool shmem_vma(struct vm_area_struct *vma)
> +{
> +	return (vma->vm_file &&
> +		vma->vm_file->f_dentry->d_inode->i_mapping->backing_dev_info
> +		== &shmem_backing_dev_info);
> +
> +}

Cosmetic nit, it seems that this helper could simply do

	return vma->vm_file && shmem_mapping(file_inode(vma->vm_file));

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
