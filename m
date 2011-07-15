Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 52F796B0092
	for <linux-mm@kvack.org>; Fri, 15 Jul 2011 18:37:53 -0400 (EDT)
Date: Fri, 15 Jul 2011 15:37:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND] Cross Memory Attach v3
Message-Id: <20110715153743.a0b3efc7.akpm@linux-foundation.org>
In-Reply-To: <20110708180607.3f11d324@lilo>
References: <20110708180607.3f11d324@lilo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Yeoh <cyeoh@au1.ibm.com>
Cc: linux-mm@kvack.org

On Fri, 8 Jul 2011 18:06:07 +0930
Christopher Yeoh <cyeoh@au1.ibm.com> wrote:

> +static ssize_t process_vm_rw(pid_t pid, const struct iovec *lvec,
> +			     unsigned long liovcnt,
> +			     const struct iovec *rvec,
> +			     unsigned long riovcnt,
> +			     unsigned long flags, int vm_write)
> +{
>
> ...
>
> +	if (!mm || (task->flags & PF_KTHREAD)) {

Can a PF_KTHREAD thread have a non-zero ->mm?
> +		task_unlock(task);
> +		rc = -EINVAL;
> +		goto put_task_struct;
> +	}

anyway, grumble.

Please resend, cc'ing linux-kernel.

Please also cc linux-man@vger.kernel.org and describe (within the
changelog context) the plan for getting the manpages written.

Please also cc linux-arch@vger.kernel.org and provide (within the
changelog context) arch developers with the documentation and test code
which will enable them to implement this and to verify it with minimal
effort.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
