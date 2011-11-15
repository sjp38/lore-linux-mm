Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 11B226B006C
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 13:17:02 -0500 (EST)
Date: Tue, 15 Nov 2011 19:17:00 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [patch v2 2/4]thp: remove unnecessary tlb flush for mprotect
Message-ID: <20111115181700.GI4414@redhat.com>
References: <1321340653.22361.295.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1321340653.22361.295.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

On Tue, Nov 15, 2011 at 03:04:13PM +0800, Shaohua Li wrote:
> change_protection() will do TLB flush later, don't need duplicate tlb flush.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
> ---

confirm the above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
