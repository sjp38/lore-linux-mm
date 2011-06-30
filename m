Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4F1F46B0012
	for <linux-mm@kvack.org>; Thu, 30 Jun 2011 15:28:38 -0400 (EDT)
Date: Thu, 30 Jun 2011 12:23:22 -0700
From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH v2] staging: zcache: support multiple clients, prep for
 KVM and RAMster
Message-ID: <20110630192322.GA1753@suse.de>
References: <1d15f28a-56df-4cf4-9dd9-1032f211c0d0@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1d15f28a-56df-4cf4-9dd9-1032f211c0d0@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Marcus Klemm <marcus.klemm@googlemail.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, kvm@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Thu, Jun 30, 2011 at 12:01:08PM -0700, Dan Magenheimer wrote:
> Hi Greg --
> 
> I think this patch is now ready for staging-next and for merging when
> the 3.1 window opens.  Please let me know if you need any logistics
> done differently.

Ok, thanks, I'll queue it up later this week for 3.1

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
