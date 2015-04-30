Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 29F416B0038
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 17:55:34 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so73349877pdb.0
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 14:55:33 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b15si5298253pbu.18.2015.04.30.14.55.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Apr 2015 14:55:33 -0700 (PDT)
Date: Thu, 30 Apr 2015 14:55:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 06/13] mm: meminit: Inline some helper functions
Message-Id: <20150430145532.a54a66edac962992b5bb890d@linux-foundation.org>
In-Reply-To: <20150430145346.1069dd3292997611954e5ac0@linux-foundation.org>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
	<1430231830-7702-7-git-send-email-mgorman@suse.de>
	<20150430145346.1069dd3292997611954e5ac0@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 30 Apr 2015 14:53:46 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:

> allmodconfig.  It's odd that nobody else hit this...

err, it's allnoconfig.  Not odd.

It would be tiresome to mention Documentation/SubmitChecklist.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
