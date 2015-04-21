Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1F758900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 19:32:50 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so255914908pdb.1
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 16:32:49 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id us15si4934830pab.170.2015.04.21.16.32.48
        for <linux-mm@kvack.org>;
        Tue, 21 Apr 2015 16:32:49 -0700 (PDT)
Date: Tue, 21 Apr 2015 16:32:48 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] mm, hwpoison: Add comment describing when to add new
 cases
Message-ID: <20150421233248.GD13605@tassilo.jf.intel.com>
References: <1429639890-14116-1-git-send-email-andi@firstfloor.org>
 <20150421141320.3ecb24f7679c2e874f9c056c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150421141320.3ecb24f7679c2e874f9c056c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org

> > + *
> > + * It can be very tempting to add handling for obscure cases here.
> > + * In general any code for handling new cases should only be added if:
> > + * - You know how to test it.
> > + * - You have a test that can be added to mce-test
> 
> Some additional details on mce-test might be useful.  The goog leads me
> to https://github.com/andikleen/mce-test but that hasn't been touched
> in 3 years?

The latest version is here https://git.kernel.org/cgit/utils/cpu/mce/mce-test.git/

Will send a new patch.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
