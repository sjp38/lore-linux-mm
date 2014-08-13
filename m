Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3C49D6B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 16:04:09 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id et14so269271pad.37
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 13:04:08 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id fo3si2240572pbb.76.2014.08.13.13.04.07
        for <linux-mm@kvack.org>;
        Wed, 13 Aug 2014 13:04:08 -0700 (PDT)
From: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>
Subject: RE: [PATCH] mm: Actually clear pmd_numa before invalidating
Date: Wed, 13 Aug 2014 20:04:02 +0000
Message-ID: <100D68C7BA14664A8938383216E40DE0407D0CA2@FMSMSX114.amr.corp.intel.com>
References: <1407943707-5547-1-git-send-email-matthew.r.wilcox@intel.com>
 <20140813125951.7619f8e908eefb99c40827c4@linux-foundation.org>
In-Reply-To: <20140813125951.7619f8e908eefb99c40827c4@linux-foundation.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>

The commit log for 67f87463d3 explains what the runtime effects should have=
 been.  This simply fixes a typo in that patch that caused that patch to be=
 a no-op.

-----Original Message-----
From: Andrew Morton [mailto:akpm@linux-foundation.org]=20
Sent: Wednesday, August 13, 2014 1:00 PM
To: Wilcox, Matthew R
Cc: linux-mm@kvack.org; Mel Gorman; Rik van Riel; stable@vger.kernel.org
Subject: Re: [PATCH] mm: Actually clear pmd_numa before invalidating

On Wed, 13 Aug 2014 11:28:27 -0400 Matthew Wilcox <matthew.r.wilcox@intel.c=
om> wrote:

> Commit 67f87463d3 cleared the NUMA bit in a copy of the PMD entry, but
> then wrote back the original
>=20
> Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: <stable@vger.kernel.org>

What are the runtime effects of this patch?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
