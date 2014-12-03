Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 75D0A6B0038
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 20:10:28 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so14599342pab.12
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 17:10:28 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id z13si35963738pbv.45.2014.12.02.17.10.25
        for <linux-mm@kvack.org>;
        Tue, 02 Dec 2014 17:10:26 -0800 (PST)
Date: Wed, 3 Dec 2014 10:13:53 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [mm] BUG: unable to handle kernel paging request at c2446ffc
Message-ID: <20141203011353.GA10084@js1304-P5Q-DELUXE>
References: <20141202043638.GB6268@js1304-P5Q-DELUXE>
 <20141202050417.GA10296@wfg-t540p.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141202050417.GA10296@wfg-t540p.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: LKP <lkp@01.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Dec 01, 2014 at 09:04:17PM -0800, Fengguang Wu wrote:
> > Hello, Fengguang.
> > 
> > First of all, thanks for reporting!
> > It always helps me a lot.
> > 
> > But, in this time, I can't reproduce this failure with your attached
> 
> Judging from the bisect log, it showed up once per 26 boots, so may
> not be easy to reproduce. The other bisect below looks easier to
> reproduce.
> 
> > configuration. Instead of this failure, sometimes, OOM happens in my
> > testing with your configuration. I don't know why it happens. :)
> 
> Yes, it's not really obvious how the change will be related to this BUG. 
> 
> > Could you have another configuration to trigger this bug?
> 
> Sure. Below is another bisect result.

Hello, Fengguang.

Great! I can reproduce the problem with you another bisect result.
Thanks a lot!
Will send the fix to Andrew.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
