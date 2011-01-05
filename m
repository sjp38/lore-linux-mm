Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D1DE26B008A
	for <linux-mm@kvack.org>; Wed,  5 Jan 2011 12:24:24 -0500 (EST)
Date: Wed, 5 Jan 2011 09:24:15 -0800
From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] Fix handling of parse errors in sysctl
Message-ID: <20110105172415.GA9689@kroah.com>
References: <1294247329-11682-1-git-send-email-emunson@mgebm.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1294247329-11682-1-git-send-email-emunson@mgebm.net>
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: akpm@linux-foundation.org, caiqian@redhat.com, mel@csn.ul.ie, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 05, 2011 at 10:08:49AM -0700, Eric B Munson wrote:
> This patch is a candidate for stable.

That's nice, but not how you get patches into the stable tree, sorry.
Please read Documentation/stable_kernel_rules.txt for how to do this.

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
