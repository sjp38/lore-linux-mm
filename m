Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id B796C900194
	for <linux-mm@kvack.org>; Wed, 22 Jun 2011 15:16:00 -0400 (EDT)
Date: Wed, 22 Jun 2011 21:15:58 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v2 0/3] support for broken memory modules (BadRAM)
Message-ID: <20110622191558.GI3263@one.firstfloor.org>
References: <1308741534-6846-1-git-send-email-sassmann@kpanic.de> <20110622110034.89ee399c.akpm@linux-foundation.org> <20110622182445.GG3263@one.firstfloor.org> <20110622113851.471f116f.akpm@linux-foundation.org> <20110622185645.GH3263@one.firstfloor.org> <4E023CE3.70100@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E023CE3.70100@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Stefan Assmann <sassmann@kpanic.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, tony.luck@intel.com, mingo@elte.hu, rick@vanrein.org, rdunlap@xenotime.net, Nancy Yuen <yuenn@google.com>, Michael Ditto <mditto@google.com>

On Wed, Jun 22, 2011 at 12:05:07PM -0700, H. Peter Anvin wrote:
> On 06/22/2011 11:56 AM, Andi Kleen wrote:
> > 
> > You'll always have multiple ways. Whatever magic you come up for
> > the google BIOS or for EFI won't help the majority of users with
> > old crufty legacy BIOS.
> > 
> 
> I don't think this has anything to do with this.

Please elaborate.

How would you pass the bad page information instead in a fully backwards
compatible way?

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
