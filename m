Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 890FB6B004A
	for <linux-mm@kvack.org>; Fri,  1 Jul 2011 04:39:36 -0400 (EDT)
Received: by pvc12 with SMTP id 12so3139327pvc.14
        for <linux-mm@kvack.org>; Fri, 01 Jul 2011 01:39:34 -0700 (PDT)
Date: Fri, 1 Jul 2011 11:38:50 +0300
From: Dan Carpenter <error27@gmail.com>
Subject: Re: [PATCH v2] staging: zcache: support multiple clients, prep for
 KVM and RAMster
Message-ID: <20110701083850.GE2544@shale.localdomain>
References: <1d15f28a-56df-4cf4-9dd9-1032f211c0d0@default20110630224019.GC2544@shale.localdomain>
 <3b67511f-bad9-4c41-915b-1f6e196f4d43@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3b67511f-bad9-4c41-915b-1f6e196f4d43@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, Marcus Klemm <marcus.klemm@googlemail.com>, kvm@vger.kernel.org, Konrad Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, devel@linuxdriverproject.org

On Thu, Jun 30, 2011 at 04:28:14PM -0700, Dan Magenheimer wrote:
> Hi Dan --
> 
> Thanks for the careful review.  You're right... some
> of this was leftover from debugging an off-by-one error,
> though the code as is still works.
> 
> OTOH, there's a good chance that much of this sysfs
> code will disappear before zcache would get promoted
> out of staging, since it is to help those experimenting
> with zcache to get more insight into what the underlying
> compression/accept-reject algorithms are doing.
> 
> So I hope you (and GregKH) are OK that another version is
> not necessary at this time to fix these.

Off by one errors are kind of insidious.  People cut and paste them
and they spread.  If someone adds a new list of chunks then there
are now two examples that are correct and two which have an extra
element, so it's 50/50 that he'll copy the right one.

Btw, looking at it again, this seems like maybe a similar issue in
zbud_evict_zbpg():

   515          /* now try freeing unbuddied pages, starting with least space avail */
   516          for (i = 0; i < MAX_CHUNK; i++) {
   517  retry_unbud_list_i:


MAX_CHUNKS is NCHUNKS - 1.  Shouldn't that be i < NCHUNKS so that we
reach the last element in the list?

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
