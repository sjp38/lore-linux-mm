Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 715046B008A
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 18:43:04 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id fb1so1621420pad.35
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 15:43:04 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id cw3si17497146pbc.117.2014.06.02.15.43.03
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 15:43:03 -0700 (PDT)
Date: Mon, 2 Jun 2014 15:43:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] HWPOISON: improve memory error handling for
 multithread process
Message-Id: <20140602154302.595a54190afdffd4b50f22c2@linux-foundation.org>
In-Reply-To: <5388cd0e.463edd0a.755d.6f61SMTPIN_ADDED_BROKEN@mx.google.com>
References: <53877e9c.8b2cdc0a.1604.ffffea43SMTPIN_ADDED_BROKEN@mx.google.com>
	<1401432670-24664-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<3908561D78D1C84285E8C5FCA982C28F32823225@ORSMSX114.amr.corp.intel.com>
	<5388cd0e.463edd0a.755d.6f61SMTPIN_ADDED_BROKEN@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Tony Luck <tony.luck@intel.com>, Andi Kleen <andi@firstfloor.org>, Kamil Iskra <iskra@mcs.anl.gov>, Borislav Petkov <bp@suse.de>, Chen Gong <gong.chen@linux.jf.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 30 May 2014 14:24:52 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> On Fri, May 30, 2014 at 05:25:39PM +0000, Luck, Tony wrote:
> > > This patchset is the summary of recent discussion about memory error handling
> > > on multithread application. Patch 1 and 2 is for action required errors, and
> > > patch 3 is for action optional errors.
> > 
> > Naoya,
> > 
> > You suggested early in the discussion (when there were just two patches) that
> > they deserved a "Cc: stable@vger.kernel.org".  I agreed, and still think the same
> > way.
> 
> Correct. AR error handling was added in v3.2-rc5, so adding
> "Cc: stable@vger.kernel.org # v3.2+" is fine.

I'm not sure that "[PATCH 3/3] mm/memory-failure.c: support dedicated
thread to handle SIGBUS(BUS_MCEERR_AO)" is a -stable thing?  That's a
feature addition more than a bugfix?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
