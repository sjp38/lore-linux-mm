Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1E4B06B0036
	for <linux-mm@kvack.org>; Tue, 20 May 2014 16:56:33 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id rd3so683865pab.1
        for <linux-mm@kvack.org>; Tue, 20 May 2014 13:56:32 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id oq10si26243149pac.48.2014.05.20.13.56.31
        for <linux-mm@kvack.org>;
        Tue, 20 May 2014 13:56:32 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH 1/2] memory-failure: Send right signal code to correct
 thread
Date: Tue, 20 May 2014 20:56:30 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F3280FF23@ORSMSX114.amr.corp.intel.com>
References: <cover.1400607328.git.tony.luck@intel.com>
 <eb791998a8ada97b204dddf2719a359149e9ae31.1400607328.git.tony.luck@intel.com>
 <1400608486-alyqz521@n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1400608486-alyqz521@n-horiguchi@ah.jp.nec.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, "bp@suse.de" <bp@suse.de>, "gong.chen@linux.jf.intel.com" <gong.chen@linux.jf.intel.com>

> Looks good to me, thank you.
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Thanks for your time reviewing this

> and I think this is worth going into stable trees.

Good point. I should dig in the git history and make one of those
fancy "Fixes: sha1 title" tags too.

-Tony
=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
