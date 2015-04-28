Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id B5C0B6B006E
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 18:41:02 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so8846568pab.2
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 15:41:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ir4si36518068pbc.118.2015.04.28.15.41.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Apr 2015 15:41:01 -0700 (PDT)
Date: Tue, 28 Apr 2015 15:41:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 02/13] mm: meminit: Move page initialization into a
 separate function.
Message-Id: <20150428154100.0f6bd333620b2e744ee66221@linux-foundation.org>
In-Reply-To: <20150428082831.GI2449@suse.de>
References: <1429785196-7668-1-git-send-email-mgorman@suse.de>
	<1429785196-7668-3-git-send-email-mgorman@suse.de>
	<20150427154633.2134d804987dad88e008c2ff@linux-foundation.org>
	<20150428082831.GI2449@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, 28 Apr 2015 09:28:31 +0100 Mel Gorman <mgorman@suse.de> wrote:

> On Mon, Apr 27, 2015 at 03:46:33PM -0700, Andrew Morton wrote:
> > On Thu, 23 Apr 2015 11:33:05 +0100 Mel Gorman <mgorman@suse.de> wrote:
> > 
> > > From: Robin Holt <holt@sgi.com>
> > 
> > : <holt@sgi.com>: host cuda-allmx.sgi.com[192.48.157.12] said: 550 cuda_nsu 5.1.1
> > :    <holt@sgi.com>: Recipient address rejected: User unknown in virtual alias
> > :    table (in reply to RCPT TO command)
> > 
> > Has Robin moved, or is SGI mail busted?
> 
> Robin has moved and I do not have an updated address for him. The
> address used in the patches was the one he posted the patches with.
> 

As Nathan mentioned, 

z:/usr/src/git26> git log | grep "Robin Holt"            
    Cc: Robin Holt <holt@sgi.com>
    Acked-by: Robin Holt <robinmholt@gmail.com>
    Cc: Robin Holt <robinmholt@gmail.com>
    Cc: Robin Holt <robinmholt@gmail.com>
    Cc: Robin Holt <robinmholt@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
