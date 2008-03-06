Message-ID: <47CF8B31.6040001@qumranet.com>
Date: Thu, 06 Mar 2008 08:12:01 +0200
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [kvm-devel] Notifier for Externally Mapped Memory (EMM) V1
References: <Pine.LNX.4.64.0803051600470.7481@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0803051600470.7481@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <andrea@qumranet.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
>  
>  /*
> + * Notifier for devices establishing their own references to Linux
> + * kernel pages in addition to the regular mapping via page
> + * table and rmap. The notifier allows the device to drop the mapping
> + * when the VM removes references to pages.
> + */
> +enum emm_operation {
> +	emm_release,		/* Process existing, */
> +	emm_invalidate_start,	/* Before the VM unmaps pages */
> +	emm_invalidate_end,	/* After the VM unmapped pages */
> +	emm_referenced		/* Check if a range was referenced */
> +};
>   

Check and clear


btw, a similar test and clear dirty would be useful as well, no?

> +
> +struct emm_notifier {
> +	int (*callback)(struct emm_notifier *e, struct mm_struct *mm,
> +		enum emm_operation op,
> +		unsigned long start, unsigned long end);
> +	struct emm_notifier *next;
> +};
> +
>   

It is cleaner for the user to specify individual callbacks instead of 
having a switch.


-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
