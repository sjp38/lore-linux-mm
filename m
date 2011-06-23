Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 707FE900194
	for <linux-mm@kvack.org>; Thu, 23 Jun 2011 09:40:07 -0400 (EDT)
Date: Thu, 23 Jun 2011 14:39:50 +0100
From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
Message-ID: <20110623133950.GB28333@srcf.ucam.org>
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1308741534-6846-1-git-send-email-sassmann@kpanic.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stefan Assmann <sassmann@kpanic.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, tony.luck@intel.com, andi@firstfloor.org, mingo@elte.hu, hpa@zytor.com, rick@vanrein.org, rdunlap@xenotime.net

On Wed, Jun 22, 2011 at 01:18:51PM +0200, Stefan Assmann wrote:
> Following the RFC for the BadRAM feature here's the updated version with
> spelling fixes, thanks go to Randy Dunlap. Also the code is now less verbose,
> as requested by Andi Kleen.
> v2 with even more spelling fixes suggested by Randy.
> Patches are against vanilla 2.6.39.
> Repost with LKML in Cc as suggested by Andrew Morton.

Would it be more reasonable to do this in the bootloader? You'd ideally 
want this to be done as early as possible in order to avoid awkward 
situations like your ramdisk ending up in the bad RAM area.

-- 
Matthew Garrett | mjg59@srcf.ucam.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
