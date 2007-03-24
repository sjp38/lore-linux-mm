Date: Sat, 24 Mar 2007 07:41:29 +0000
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch 2/2] hugetlb: add /dev/hugetlb char device
Message-ID: <20070324074129.GB18408@infradead.org>
References: <b040c32a0703231545h79d45d0eof1edd225ef3d8ee9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b040c32a0703231545h79d45d0eof1edd225ef3d8ee9@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Adam Litke <agl@us.ibm.com>, William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> +int hugetlb_zero_setup(struct file *file, struct vm_area_struct *vma)
> +{
> +	file = hugetlb_file_setup(vma->vm_end - vma->vm_start, 0);
> +	if (IS_ERR(file))
> +		return PTR_ERR(file);
> +
> +	if (vma->vm_file)
> +		fput(vma->vm_file);
> +	vma->vm_file = file;
> +	return hugetlbfs_file_mmap(file, vma);
> +}

Setting vma->vm_file to something that is not the file we called mmap
on and even refers to a different inode seems rather dangerous.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
