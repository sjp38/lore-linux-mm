Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id B06E16B003A
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 12:29:01 -0500 (EST)
Received: by mail-ee0-f43.google.com with SMTP id c13so3488249eek.30
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 09:29:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id a9si9892399eew.75.2013.12.05.09.29.00
        for <linux-mm@kvack.org>;
        Thu, 05 Dec 2013 09:29:00 -0800 (PST)
Date: Thu, 5 Dec 2013 18:29:31 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] Fix race between oom kill and task exit
Message-ID: <20131205172931.GA26018@redhat.com>
References: <3917C05D9F83184EAA45CE249FF1B1DD0253093A@SHSMSX103.ccr.corp.intel.com> <20131128063505.GN3556@cmpxchg.org> <CAJ75kXZXxCMgf8=pghUWf=W9EKf3Z4nzKKy=CAn+7keVF_DCRA@mail.gmail.com> <20131128120018.GL2761@dhcp22.suse.cz> <20131128183830.GD20740@redhat.com> <20131202141203.GA31402@redhat.com> <alpine.DEB.2.02.1312041655370.13608@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1312041655370.13608@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, William Dauchy <wdauchy@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Ma, Xindong" <xindong.ma@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "Tu, Xiaobing" <xiaobing.tu@intel.com>, azurIt <azurit@pobox.sk>, Sameer Nanda <snanda@chromium.org>

On 12/04, David Rientjes wrote:
>
> On Mon, 2 Dec 2013, Oleg Nesterov wrote:
>
> > OK, I am going to send the initial fixes today. This means (I hope)
> > that we do not need this or Sameer's "[PATCH] mm, oom: Fix race when
> > selecting process to kill".
>
> Your v2 series looks good and I suspect anybody trying them doesn't have
> additional reports of the infinite loop?  Should they be marked for
> stable?

Unlikely...

I think the patch from Sameer makes more sense for stable as a temporary
(and obviously incomplete) fix.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
