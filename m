Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id D00096B0038
	for <linux-mm@kvack.org>; Wed, 13 May 2015 12:32:03 -0400 (EDT)
Received: by wgbhc8 with SMTP id hc8so15793263wgb.3
        for <linux-mm@kvack.org>; Wed, 13 May 2015 09:32:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qr7si9350813wic.24.2015.05.13.09.32.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 May 2015 09:32:02 -0700 (PDT)
Date: Wed, 13 May 2015 17:31:57 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: meminit: Finish initialisation of struct pages
 before basic setup
Message-ID: <20150513163157.GR2462@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
 <554030D1.8080509@hp.com>
 <5543F802.9090504@hp.com>
 <554415B1.2050702@hp.com>
 <20150504143046.9404c572486caf71bdef0676@linux-foundation.org>
 <20150505104514.GC2462@suse.de>
 <20150505130255.49ff76bbf0a3b32d884ab2ce@linux-foundation.org>
 <20150507072518.GL2462@suse.de>
 <20150507150932.79e038167f70dd467c25d6ee@linux-foundation.org>
 <5553737D.8080904@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <5553737D.8080904@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: nzimmer <nzimmer@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, May 13, 2015 at 10:53:33AM -0500, nzimmer wrote:
> I am just noticed a hang on my largest box.
> I can only reproduce with large core counts, if I turn down the
> number of cpus it doesn't have an issue.
> 

Odd. The number of core counts should make little a difference as only
one CPU per node should be in use. Does sysrq+t give any indication how
or where it is hanging?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
