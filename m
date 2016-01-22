Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 6CFA86B0005
	for <linux-mm@kvack.org>; Fri, 22 Jan 2016 09:39:04 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id 65so43205301pff.2
        for <linux-mm@kvack.org>; Fri, 22 Jan 2016 06:39:04 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id z12si9922850pas.77.2016.01.22.06.39.02
        for <linux-mm@kvack.org>;
        Fri, 22 Jan 2016 06:39:03 -0800 (PST)
Date: Fri, 22 Jan 2016 09:39:00 -0500
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v12 10/20] dax: Replace XIP documentation with DAX
 documentation
Message-ID: <20160122143900.GE2948@linux.intel.com>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
 <1414185652-28663-11-git-send-email-matthew.r.wilcox@intel.com>
 <CA+ZsKJ7LgOjuZ091d-ikhuoA+ZrCny4xBGVupv0oai8yB5OqFQ@mail.gmail.com>
 <100D68C7BA14664A8938383216E40DE0421657C5@fmsmsx111.amr.corp.intel.com>
 <HK2PR06MB05610F968A8B0E5E0E6BCDC98AC40@HK2PR06MB0561.apcprd06.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <HK2PR06MB05610F968A8B0E5E0E6BCDC98AC40@HK2PR06MB0561.apcprd06.prod.outlook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Brandt <Chris.Brandt@renesas.com>
Cc: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Jared Hulbert <jaredeh@gmail.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Carsten Otte <cotte@de.ibm.com>

On Fri, Jan 22, 2016 at 01:48:08PM +0000, Chris Brandt wrote:
> I believe the motivation for the new DAX code was being able to
> read/write data directly to specific physical memory. However, with
> the AXFS file system, XIP file mapping was mostly beneficial for direct
> access to executable code pages, not data. Code pages were XIP-ed, and
> data pages were copied to RAM as normal. This results in a significant
> reduction in system RAM, especially when used with an XIP_KERNEL. In
> some systems, most of your RAM is eaten up by lots of code pages from
> big bloated shared libraries, not R/W data. (of course I'm talking about
> smaller embedded system here)

OK, I can't construct a failure case for read-only usages.  If you want
to put together a patch-set that re-enables DAX in a read-only way on
those architectures, I'm fine with that.

I think your time would be better spent fixing the read-write problems;
once we see persistent memory on the embedded platforms, we'll need that
code anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
