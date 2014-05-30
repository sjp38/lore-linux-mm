Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f53.google.com (mail-la0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 842BB6B0035
	for <linux-mm@kvack.org>; Fri, 30 May 2014 14:25:23 -0400 (EDT)
Received: by mail-la0-f53.google.com with SMTP id ty20so1249163lab.12
        for <linux-mm@kvack.org>; Fri, 30 May 2014 11:25:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id rd10si13248531lbb.23.2014.05.30.11.25.20
        for <linux-mm@kvack.org>;
        Fri, 30 May 2014 11:25:21 -0700 (PDT)
Message-ID: <5388cd11.2a8c700a.19a9.ffffe413SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 0/3] HWPOISON: improve memory error handling for multithread process
Date: Fri, 30 May 2014 14:24:52 -0400
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F32823225@ORSMSX114.amr.corp.intel.com>
References: <53877e9c.8b2cdc0a.1604.ffffea43SMTPIN_ADDED_BROKEN@mx.google.com> <1401432670-24664-1-git-send-email-n-horiguchi@ah.jp.nec.com> <3908561D78D1C84285E8C5FCA982C28F32823225@ORSMSX114.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Kamil Iskra <iskra@mcs.anl.gov>, Borislav Petkov <bp@suse.de>, Chen Gong <gong.chen@linux.jf.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, May 30, 2014 at 05:25:39PM +0000, Luck, Tony wrote:
> > This patchset is the summary of recent discussion about memory error handling
> > on multithread application. Patch 1 and 2 is for action required errors, and
> > patch 3 is for action optional errors.
> 
> Naoya,
> 
> You suggested early in the discussion (when there were just two patches) that
> they deserved a "Cc: stable@vger.kernel.org".  I agreed, and still think the same
> way.

Correct. AR error handling was added in v3.2-rc5, so adding
"Cc: stable@vger.kernel.org # v3.2+" is fine.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
