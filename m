Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6007B6B0055
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 20:39:01 -0400 (EDT)
Date: Mon, 15 Jun 2009 17:35:57 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 21/22] HWPOISON: send uevent to report memory corruption
Message-ID: <20090616003557.GA22690@kroah.com>
References: <20090615024520.786814520@intel.com> <20090615031255.278184860@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090615031255.278184860@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 15, 2009 at 10:45:41AM +0800, Wu Fengguang wrote:
> +static void hwpoison_release(struct kobject *kobj)
> +{
> +}
> +
> +static struct kobj_type hwpoison_ktype = {
> +	.release = hwpoison_release,
> +};

{sigh}

Why did you include an empty release function?  Was it because the
kernel complained when you had no release function?  So, why would you
think that the acceptable solution to that warning would be an empty
release function instead?

Hint, this is totally wrong, provide a release function that ACTUALLY
DOES SOMETHING!!!  Read the kobject documentation for details as to what
you need to do here.

ugh, I'm so tired of repeating this year after year after year, I feel
like a broken record...

This is broken, please fix it.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
