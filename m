Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f42.google.com (mail-bk0-f42.google.com [209.85.214.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1BDEC6B0035
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 12:57:49 -0500 (EST)
Received: by mail-bk0-f42.google.com with SMTP id w11so3966500bkz.15
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 09:57:48 -0800 (PST)
Received: from mail-la0-x233.google.com (mail-la0-x233.google.com [2a00:1450:4010:c03::233])
        by mx.google.com with ESMTPS id qy10si14017987bkb.68.2013.11.28.09.57.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 28 Nov 2013 09:57:47 -0800 (PST)
Received: by mail-la0-f51.google.com with SMTP id ec20so6115185lab.24
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 09:57:46 -0800 (PST)
Date: Thu, 28 Nov 2013 18:57:11 +0100
From: Vladimir Murzin <murzin.v@gmail.com>
Subject: Re: [PATCH] Fix race between oom kill and task exit
Message-ID: <20131128175708.GA1875@hp530>
References: <3917C05D9F83184EAA45CE249FF1B1DD0253093A@SHSMSX103.ccr.corp.intel.com>
 <20131128063505.GN3556@cmpxchg.org>
 <CAJ75kXZXxCMgf8=pghUWf=W9EKf3Z4nzKKy=CAn+7keVF_DCRA@mail.gmail.com>
 <20131128120018.GL2761@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline
In-Reply-To: <20131128120018.GL2761@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: William Dauchy <wdauchy@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Ma, Xindong" <xindong.ma@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rientjes@google.com" <rientjes@google.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "Tu, Xiaobing" <xiaobing.tu@intel.com>, azurIt <azurit@pobox.sk>, Sameer Nanda <snanda@chromium.org>, Oleg Nesterov <oleg@redhat.com>, dserrg@gmail.com

On Thu, Nov 28, 2013 at 01:00:18PM +0100, Michal Hocko wrote:
> [CCing Oleg - the thread started here:
> https://lkml.org/lkml/2013/11/28/2]
> 
> On Thu 28-11-13 09:41:40, William Dauchy wrote:
> [...]
> > However, I'm now wondering if this present patch is a replacement of
> > Sameer Nanda's patch or if this a complementary patch.
> 
> They are both trying to solve the same issue. Neither of them is
> optimal unfortunately. Oleg said he would look into this and I have seen
> some patches but didn't geto check them.

CCing Sergey - he reported and proposed the patch for the similar issue.

Vladimir

> 
> -- 
> Michal Hocko
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
