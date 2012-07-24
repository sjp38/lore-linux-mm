Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 0D6D06B004D
	for <linux-mm@kvack.org>; Tue, 24 Jul 2012 01:58:54 -0400 (EDT)
Message-ID: <1343109531.7412.47.camel@marge.simpson.net>
Subject: Re: [PATCH 00/34] Memory management performance backports for
 -stable V2
From: Mike Galbraith <efault@gmx.de>
Date: Tue, 24 Jul 2012 07:58:51 +0200
In-Reply-To: <1343050727-3045-1-git-send-email-mgorman@suse.de>
References: <1343050727-3045-1-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Stable <stable@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 2012-07-23 at 14:38 +0100, Mel Gorman wrote: 
> Changelog since V1
>   o Expand some of the notes					(jrnieder)
>   o Correct upstream commit SHA1				(hugh)
> 
> This series is related to the new addition to stable_kernel_rules.txt
> 
>  - Serious issues as reported by a user of a distribution kernel may also
>    be considered if they fix a notable performance or interactivity issue.
>    As these fixes are not as obvious and have a higher risk of a subtle
>    regression they should only be submitted by a distribution kernel
>    maintainer and include an addendum linking to a bugzilla entry if it
>    exists and additional information on the user-visible impact.
> 
> All of these patches have been backported to a distribution kernel and
> address some sort of performance issue in the VM. As they are not all
> obvious, I've added a "Stable note" to the top of each patch giving
> additional information on why the patch was backported. Lets see where
> the boundaries lie on how this new rule is interpreted in practice :).

FWIW, I'm all for performance backports.  They do have a downside though
(other than the risk of bugs slipping in, or triggering latent bugs).

When the next enterprise kernel is built, marketeers ask for numbers to
make potential customers drool over, and you _can't produce any_ because
you wedged all the spiffy performance stuff into the crusty old kernel.

-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
