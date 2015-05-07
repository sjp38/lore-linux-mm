Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id C90776B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 19:02:37 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so52361219pab.3
        for <linux-mm@kvack.org>; Thu, 07 May 2015 16:02:37 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id qw7si4524992pbc.195.2015.05.07.16.02.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 16:02:36 -0700 (PDT)
Date: Thu, 7 May 2015 16:02:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: meminit: Finish initialisation of struct pages
 before basic setup
Message-Id: <20150507160234.9828aa1a2bff9366339dea90@linux-foundation.org>
In-Reply-To: <20150507225226.GM2462@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
	<554030D1.8080509@hp.com>
	<5543F802.9090504@hp.com>
	<554415B1.2050702@hp.com>
	<20150504143046.9404c572486caf71bdef0676@linux-foundation.org>
	<20150505104514.GC2462@suse.de>
	<20150505130255.49ff76bbf0a3b32d884ab2ce@linux-foundation.org>
	<20150507072518.GL2462@suse.de>
	<20150507150932.79e038167f70dd467c25d6ee@linux-foundation.org>
	<20150507225226.GM2462@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Waiman Long <waiman.long@hp.com>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 7 May 2015 23:52:26 +0100 Mel Gorman <mgorman@suse.de> wrote:

>  As for the patch sequencing, I'm ok
> with adding the patch on top if you are because that preserves the testing
> history. If you're unhappy, I can shuffle it into a better place and resend
> the full series that includes all the fixes so far.

We'll survive.  Let's only do the reorganization if the patches need rework
for other reasons.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
