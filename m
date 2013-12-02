Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f174.google.com (mail-ea0-f174.google.com [209.85.215.174])
	by kanga.kvack.org (Postfix) with ESMTP id 276166B003B
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 09:12:01 -0500 (EST)
Received: by mail-ea0-f174.google.com with SMTP id b10so8924911eae.5
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 06:12:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id r3si26382994eep.265.2013.12.02.06.11.59
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 06:12:00 -0800 (PST)
Date: Mon, 2 Dec 2013 15:12:03 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] Fix race between oom kill and task exit
Message-ID: <20131202141203.GA31402@redhat.com>
References: <3917C05D9F83184EAA45CE249FF1B1DD0253093A@SHSMSX103.ccr.corp.intel.com> <20131128063505.GN3556@cmpxchg.org> <CAJ75kXZXxCMgf8=pghUWf=W9EKf3Z4nzKKy=CAn+7keVF_DCRA@mail.gmail.com> <20131128120018.GL2761@dhcp22.suse.cz> <20131128183830.GD20740@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131128183830.GD20740@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: William Dauchy <wdauchy@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Ma, Xindong" <xindong.ma@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rientjes@google.com" <rientjes@google.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "Tu, Xiaobing" <xiaobing.tu@intel.com>, azurIt <azurit@pobox.sk>, Sameer Nanda <snanda@chromium.org>

On 11/28, Oleg Nesterov wrote:
>
> On 11/28, Michal Hocko wrote:
> >
> > They are both trying to solve the same issue. Neither of them is
> > optimal unfortunately.
>
> yes, but this one doesn't look right.
>
> > Oleg said he would look into this and I have seen
> > some patches but didn't geto check them.
>
> Only preparations so far.

OK, I am going to send the initial fixes today. This means (I hope)
that we do not need this or Sameer's "[PATCH] mm, oom: Fix race when
selecting process to kill".

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
