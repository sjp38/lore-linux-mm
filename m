Date: Tue, 15 Nov 2005 23:10:51 -0800
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 2/2] Fold numa_maps into mempolicy.c
Message-Id: <20051115231051.5437e25b.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.62.0511081524570.32262@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0511081520540.32262@schroedinger.engr.sgi.com>
	<Pine.LNX.4.62.0511081524570.32262@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: ak@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph wrote:
> + * Must hold mmap_sem until memory pointer is no longer in use
> + * or be called from the current task.
> + */
> +struct mempolicy *get_vma_policy(struct task_struct *task,

Twenty (well, four) questions time.

Hmmm ... is that true - that get_vma_policy() can be called for the
current task w/o holding mmap_sem?

Is there any call to get_vma_policy() made that isn't holding mmap_sem?

Except for /proc output, is there any call to get_vma_policy made on any
task other than current?

What does "until memory pointer is no longer in use" mean?

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
