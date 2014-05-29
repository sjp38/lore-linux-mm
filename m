Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f181.google.com (mail-vc0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 678366B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 13:03:19 -0400 (EDT)
Received: by mail-vc0-f181.google.com with SMTP id hy4so706428vcb.26
        for <linux-mm@kvack.org>; Thu, 29 May 2014 10:03:18 -0700 (PDT)
Received: from mail-ve0-x233.google.com (mail-ve0-x233.google.com [2607:f8b0:400c:c01::233])
        by mx.google.com with ESMTPS id e4si953591vci.96.2014.05.29.10.03.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 29 May 2014 10:03:17 -0700 (PDT)
Received: by mail-ve0-f179.google.com with SMTP id oy12so716541veb.24
        for <linux-mm@kvack.org>; Thu, 29 May 2014 10:03:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5386915f.4772e50a.0657.ffffcda4SMTPIN_ADDED_BROKEN@mx.google.com>
References: <eb791998a8ada97b204dddf2719a359149e9ae31.1400607328.git.tony.luck@intel.com>
	<20140523033438.GC16945@gchen.bj.intel.com>
	<CA+8MBb+Una+Z5Q-Pn0OoMYaaSx9sPJ3fdriMRMgN=CE1Jdp7Cg@mail.gmail.com>
	<20140527161613.GC4108@mcs.anl.gov>
	<5384d07e.4504e00a.2680.ffff8c31SMTPIN_ADDED_BROKEN@mx.google.com>
	<CA+8MBbKuBo4c2v-Y0TOk-LUJuyJsGG=twqQyAPG5WOa8Aj4GyA@mail.gmail.com>
	<53852abb.867ce00a.3cef.3c7eSMTPIN_ADDED_BROKEN@mx.google.com>
	<FDBACF11-D9F6-4DE5-A0D4-800903A243B7@gmail.com>
	<53862f6c.91148c0a.5fb0.2d0cSMTPIN_ADDED_BROKEN@mx.google.com>
	<CA+8MBbKdKy+sbov-f+1xNnj=syEM5FWR1BV85AgRJ9S+qPbWEg@mail.gmail.com>
	<5386915f.4772e50a.0657.ffffcda4SMTPIN_ADDED_BROKEN@mx.google.com>
Date: Thu, 29 May 2014 10:03:17 -0700
Message-ID: <CA+8MBbLxvZWVuUsNdPG-CTEtrAZzxrPGVFp0u74iMgYaxzwf0Q@mail.gmail.com>
Subject: Re: [PATCH] mm/memory-failure.c: support dedicated thread to handle
 SIGBUS(BUS_MCEERR_AO) thread
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Kamil Iskra <iskra@mcs.anl.gov>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Borislav Petkov <bp@suse.de>, Chen Gong <gong.chen@linux.jf.intel.com>

> OK, I'll take this.

If you didn't already apply it, then add a "Reviewed-by: Tony Luck
<tony.luck@intel,com>"

I see that this patch is on top of my earlier ones (includes the
"force_early" argument).
That means you have both of those queued too?

Thanks

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
