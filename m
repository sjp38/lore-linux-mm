Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C8EAC6B002D
	for <linux-mm@kvack.org>; Tue, 25 Oct 2011 07:44:09 -0400 (EDT)
Date: Tue, 25 Oct 2011 13:44:06 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch 1/5]thp: improve the error code path
Message-ID: <20111025114406.GC10182@redhat.com>
References: <1319511521.22361.135.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1319511521.22361.135.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

Hello,

On Tue, Oct 25, 2011 at 10:58:41AM +0800, Shaohua Li wrote:
> +#ifdef CONFIG_SYSFS
> +	sysfs_remove_group(hugepage_kobj, &khugepaged_attr_group);
> +remove_hp_group:
> +	sysfs_remove_group(hugepage_kobj, &hugepage_attr_group);
> +delete_obj:
> +	kobject_put(hugepage_kobj);
>  out:
> +#endif

Adding an ifdef is making the code worse, the whole point of having
these functions become noops at build time is to avoid having to add
ifdefs in the callers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
