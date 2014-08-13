Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 82A9A6B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 16:16:38 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id ey11so283587pad.38
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 13:16:38 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id bn9si2255535pdb.150.2014.08.13.13.16.37
        for <linux-mm@kvack.org>;
        Wed, 13 Aug 2014 13:16:37 -0700 (PDT)
From: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>
Subject: RE: [PATCH] mm: Actually clear pmd_numa before invalidating
Date: Wed, 13 Aug 2014 20:16:31 +0000
Message-ID: <100D68C7BA14664A8938383216E40DE0407D0CE2@FMSMSX114.amr.corp.intel.com>
References: <1407943707-5547-1-git-send-email-matthew.r.wilcox@intel.com>
	<20140813125951.7619f8e908eefb99c40827c4@linux-foundation.org>
	<100D68C7BA14664A8938383216E40DE0407D0CA2@FMSMSX114.amr.corp.intel.com>
 <20140813131241.3ced5ccaeec24fcd378a1ef6@linux-foundation.org>
In-Reply-To: <20140813131241.3ced5ccaeec24fcd378a1ef6@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>

I am quite shockingly ignorant of the MM code.  While looking at this funct=
ion to figure out how/whether to use it, I noticed the bug, and sent a patc=
h.  I assumed the gibberish in the changelog meant something important to p=
eople who actually understand this part of the kernel :-)

-----Original Message-----
From: Andrew Morton [mailto:akpm@linux-foundation.org]=20
Sent: Wednesday, August 13, 2014 1:13 PM
To: Wilcox, Matthew R
Cc: linux-mm@kvack.org; Mel Gorman; Rik van Riel; stable@vger.kernel.org
Subject: Re: [PATCH] mm: Actually clear pmd_numa before invalidating

On Wed, 13 Aug 2014 20:04:02 +0000 "Wilcox, Matthew R" <matthew.r.wilcox@in=
tel.com> wrote:

> The commit log for 67f87463d3 explains what the runtime effects should ha=
ve been.

No it doesn't.  In fact the sentence "The existing caller of
pmdp_invalidate should handle it but it's an inconsistent state for a
PMD." makes me suspect there are no end-user visible effects.

I don't know why we chose to backport that one into -stable and I don't
know why we should backport this one either.

Greg (and others) will look at this changelog and wonder "why".  It
should tell them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
