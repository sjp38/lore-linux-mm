Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id C6AB76B0044
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 15:32:24 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id fa1so11045469pad.7
        for <linux-mm@kvack.org>; Mon, 07 Jan 2013 12:32:24 -0800 (PST)
Date: Mon, 7 Jan 2013 12:32:19 -0800
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCHv2 5/9] debugfs: add get/set for atomic types
Message-ID: <20130107203219.GA19596@kroah.com>
References: <1357590280-31535-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1357590280-31535-6-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357590280-31535-6-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, devel@driverdev.osuosl.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Robert Jennings <rcj@linux.vnet.ibm.com>, Johannes Weiner <jweiner@redhat.com>, Nitin Gupta <ngupta@vflare.org>, Jenifer Hopper <jhopper@us.ibm.com>

On Mon, Jan 07, 2013 at 02:24:36PM -0600, Seth Jennings wrote:
> debugfs currently lack the ability to create attributes
> that set/get atomic_t values.

I hate to ask, but why would you ever want to do such a thing?

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
