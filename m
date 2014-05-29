Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f182.google.com (mail-ve0-f182.google.com [209.85.128.182])
	by kanga.kvack.org (Postfix) with ESMTP id 3DBF86B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 14:38:21 -0400 (EDT)
Received: by mail-ve0-f182.google.com with SMTP id sa20so896887veb.27
        for <linux-mm@kvack.org>; Thu, 29 May 2014 11:38:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id a11si1218781vcf.3.2014.05.29.11.38.20
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 11:38:20 -0700 (PDT)
Message-ID: <53877e9c.8b2cdc0a.1604.ffffea43SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/memory-failure.c: support dedicated thread to handle SIGBUS(BUS_MCEERR_AO) thread
Date: Thu, 29 May 2014 14:38:00 -0400
In-Reply-To: <CA+8MBbLxvZWVuUsNdPG-CTEtrAZzxrPGVFp0u74iMgYaxzwf0Q@mail.gmail.com>
References: <CA+8MBb+Una+Z5Q-Pn0OoMYaaSx9sPJ3fdriMRMgN=CE1Jdp7Cg@mail.gmail.com> <20140527161613.GC4108@mcs.anl.gov> <5384d07e.4504e00a.2680.ffff8c31SMTPIN_ADDED_BROKEN@mx.google.com> <CA+8MBbKuBo4c2v-Y0TOk-LUJuyJsGG=twqQyAPG5WOa8Aj4GyA@mail.gmail.com> <53852abb.867ce00a.3cef.3c7eSMTPIN_ADDED_BROKEN@mx.google.com> <FDBACF11-D9F6-4DE5-A0D4-800903A243B7@gmail.com> <53862f6c.91148c0a.5fb0.2d0cSMTPIN_ADDED_BROKEN@mx.google.com> <CA+8MBbKdKy+sbov-f+1xNnj=syEM5FWR1BV85AgRJ9S+qPbWEg@mail.gmail.com> <5386915f.4772e50a.0657.ffffcda4SMTPIN_ADDED_BROKEN@mx.google.com> <CA+8MBbLxvZWVuUsNdPG-CTEtrAZzxrPGVFp0u74iMgYaxzwf0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tony.luck@gmail.com
Cc: iskra@mcs.anl.gov, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Borislav Petkov <bp@suse.de>, gong.chen@linux.jf.intel.com

On Thu, May 29, 2014 at 10:03:17AM -0700, Tony Luck wrote:
> > OK, I'll take this.
> 
> If you didn't already apply it, then add a "Reviewed-by: Tony Luck
> <tony.luck@intel,com>"

Thank you.

> I see that this patch is on top of my earlier ones (includes the
> "force_early" argument).

Right.

> That means you have both of those queued too?

Yes, so I'll publish my tree and ask Andrew to pull it later.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
