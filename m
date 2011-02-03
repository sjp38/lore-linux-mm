Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9C6E78D0039
	for <linux-mm@kvack.org>; Thu,  3 Feb 2011 17:20:48 -0500 (EST)
Date: Thu, 3 Feb 2011 14:13:46 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 4/6] TTY: use appropriate printk priority level
Message-ID: <20110203221346.GA477@kroah.com>
References: <20110125235700.GR8008@google.com>
 <1296084570-31453-5-git-send-email-msb@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1296084570-31453-5-git-send-email-msb@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mandeep Singh Baines <msb@chromium.org>
Cc: gregkh@suse.de, rjw@sisk.pl, mingo@redhat.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-pm@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jan 26, 2011 at 03:29:28PM -0800, Mandeep Singh Baines wrote:
> printk()s without a priority level default to KERN_WARNING. To reduce
> noise at KERN_WARNING, this patch set the priority level appriopriately
> for unleveled printks()s. This should be useful to folks that look at
> dmesg warnings closely.
> 
> Signed-off-by: Mandeep Singh Baines <msb@chromium.org>

This doesn't apply to the latest linux-next tree, care to resend it
after refreshing it?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
