Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id A00036B00E1
	for <linux-mm@kvack.org>; Tue,  7 May 2013 17:24:48 -0400 (EDT)
Date: Tue, 7 May 2013 14:24:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 00/11] mm: fixup changers of per cpu pageset's ->high
 and ->batch
Message-Id: <20130507142446.52214bb184bed45635febeb3@linux-foundation.org>
In-Reply-To: <5181AB06.5080805@linux.vnet.ibm.com>
References: <1365618219-17154-1-git-send-email-cody@linux.vnet.ibm.com>
	<20130410142354.6044338fd68ff2ad165b1bc8@linux-foundation.org>
	<5165D8DE.5090801@linux.vnet.ibm.com>
	<5181AB06.5080805@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Gilad Ben-Yossef <gilad@benyossef.com>, Simon Jeons <simon.jeons@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 01 May 2013 16:53:42 -0700 Cody P Schafer <cody@linux.vnet.ibm.com> wrote:

> >> There hasn't been a ton of review activity for this patchset :(
> >>
> >> I'm inclined to duck it until after 3.9.  Do the patches fix any
> >> noticeably bad userspace behavior?
> >
> > No, all the bugs are theoretical. Waiting should be fine.
> >
> 
> Andrew, do you want me to resend this patch set in the hope of obtaining 
> more review?

Yes please.  Resending is basically always the thing to do - if the
patches aren't resent, nobody has anything to look at or think about.

> If so, when?

After -rc1?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
