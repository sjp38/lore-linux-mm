Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7406B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 16:23:36 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so292467pdj.0
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 13:23:35 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gi10si2263490pbd.131.2014.08.13.13.23.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Aug 2014 13:23:35 -0700 (PDT)
Date: Wed, 13 Aug 2014 13:23:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Actually clear pmd_numa before invalidating
Message-Id: <20140813132333.92f2ade49867acbfb9ed696b@linux-foundation.org>
In-Reply-To: <100D68C7BA14664A8938383216E40DE0407D0CE2@FMSMSX114.amr.corp.intel.com>
References: <1407943707-5547-1-git-send-email-matthew.r.wilcox@intel.com>
	<20140813125951.7619f8e908eefb99c40827c4@linux-foundation.org>
	<100D68C7BA14664A8938383216E40DE0407D0CA2@FMSMSX114.amr.corp.intel.com>
	<20140813131241.3ced5ccaeec24fcd378a1ef6@linux-foundation.org>
	<100D68C7BA14664A8938383216E40DE0407D0CE2@FMSMSX114.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, "stable@vger.kernel.org" <stable@vger.kernel.org>

On Wed, 13 Aug 2014 20:16:31 +0000 "Wilcox, Matthew R" <matthew.r.wilcox@intel.com> wrote:

> I am quite shockingly ignorant of the MM code.  While looking at this
> function to figure out how/whether to use it, I noticed the bug, and
> sent a patch.  I assumed the gibberish in the changelog meant something
> important to people who actually understand this part of the kernel :-)

Fair enough ;)  Mel?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
