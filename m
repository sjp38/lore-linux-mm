Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 089696B0038
	for <linux-mm@kvack.org>; Tue, 28 Apr 2015 04:28:41 -0400 (EDT)
Received: by widdi4 with SMTP id di4so130100199wid.0
        for <linux-mm@kvack.org>; Tue, 28 Apr 2015 01:28:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id om1si8566293wjc.104.2015.04.28.01.28.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Apr 2015 01:28:39 -0700 (PDT)
Date: Tue, 28 Apr 2015 09:28:31 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 02/13] mm: meminit: Move page initialization into a
 separate function.
Message-ID: <20150428082831.GI2449@suse.de>
References: <1429785196-7668-1-git-send-email-mgorman@suse.de>
 <1429785196-7668-3-git-send-email-mgorman@suse.de>
 <20150427154633.2134d804987dad88e008c2ff@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150427154633.2134d804987dad88e008c2ff@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, LKML <linux-kernel@vger.kernel.org>

On Mon, Apr 27, 2015 at 03:46:33PM -0700, Andrew Morton wrote:
> On Thu, 23 Apr 2015 11:33:05 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > From: Robin Holt <holt@sgi.com>
> 
> : <holt@sgi.com>: host cuda-allmx.sgi.com[192.48.157.12] said: 550 cuda_nsu 5.1.1
> :    <holt@sgi.com>: Recipient address rejected: User unknown in virtual alias
> :    table (in reply to RCPT TO command)
> 
> Has Robin moved, or is SGI mail busted?

Robin has moved and I do not have an updated address for him. The
address used in the patches was the one he posted the patches with.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
