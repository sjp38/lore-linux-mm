Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id EC86C6B00B8
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 21:12:29 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id w62so6050169wes.16
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 18:12:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id co10si25057576wib.42.2014.06.02.18.12.27
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 18:12:28 -0700 (PDT)
Message-ID: <538d20fc.ca5cb40a.130c.5848SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/3] memory-failure: Send right signal code to correct thread
Date: Mon,  2 Jun 2014 21:12:08 -0400
In-Reply-To: <20140602154431.2d77c066546354b9bd81e60b@linux-foundation.org>
References: <53877e9c.8b2cdc0a.1604.ffffea43SMTPIN_ADDED_BROKEN@mx.google.com> <1401432670-24664-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1401432670-24664-2-git-send-email-n-horiguchi@ah.jp.nec.com> <20140602154431.2d77c066546354b9bd81e60b@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Andi Kleen <andi@firstfloor.org>, Kamil Iskra <iskra@mcs.anl.gov>, Borislav Petkov <bp@suse.de>, Chen Gong <gong.chen@linux.jf.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 02, 2014 at 03:44:31PM -0700, Andrew Morton wrote:
> On Fri, 30 May 2014 02:51:08 -0400 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:
> 
> > From: Tony Luck <tony.luck@intel.com>
> > 
> > When a thread in a multi-threaded application hits a machine
> > check because of an uncorrectable error in memory - we want to
> > send the SIGBUS with si.si_code = BUS_MCEERR_AR to that thread.
> > Currently we fail to do that if the active thread is not the
> > primary thread in the process. collect_procs() just finds primary
> > threads and this test:
> > 	if ((flags & MF_ACTION_REQUIRED) && t == current) {
> > will see that the thread we found isn't the current thread
> > and so send a si.si_code = BUS_MCEERR_AO to the primary
> > (and nothing to the active thread at this time).
> > 
> > We can fix this by checking whether "current" shares the same
> > mm with the process that collect_procs() said owned the page.
> > If so, we send the SIGBUS to current (with code BUS_MCEERR_AR).
> > 
> > Reported-by: Otto Bruggeman <otto.g.bruggeman@intel.com>
> > Signed-off-by: Tony Luck <tony.luck@intel.com>
> > Cc: Andi Kleen <andi@firstfloor.org>
> > Cc: Borislav Petkov <bp@suse.de>
> > Cc: Chen Gong <gong.chen@linux.jf.intel.com>
> > Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> You were on the patch delivery path, so it should have included your
> signed-off-by.  Documentation/SubmittingPatches section 12 has the
> details.

Sorry, I didn't know that.

> I have made that change to my copies of patches 1 and 2.

Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
