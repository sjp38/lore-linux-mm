Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id 37DA56B0035
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 13:37:54 -0500 (EST)
Received: by mail-qa0-f44.google.com with SMTP id i13so1036815qae.3
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 10:37:54 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id q2si3821383qas.165.2013.11.28.10.37.52
        for <linux-mm@kvack.org>;
        Thu, 28 Nov 2013 10:37:53 -0800 (PST)
Date: Thu, 28 Nov 2013 19:38:30 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] Fix race between oom kill and task exit
Message-ID: <20131128183830.GD20740@redhat.com>
References: <3917C05D9F83184EAA45CE249FF1B1DD0253093A@SHSMSX103.ccr.corp.intel.com> <20131128063505.GN3556@cmpxchg.org> <CAJ75kXZXxCMgf8=pghUWf=W9EKf3Z4nzKKy=CAn+7keVF_DCRA@mail.gmail.com> <20131128120018.GL2761@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131128120018.GL2761@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: William Dauchy <wdauchy@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Ma, Xindong" <xindong.ma@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rientjes@google.com" <rientjes@google.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "Tu, Xiaobing" <xiaobing.tu@intel.com>, azurIt <azurit@pobox.sk>, Sameer Nanda <snanda@chromium.org>

On 11/28, Michal Hocko wrote:
>
> They are both trying to solve the same issue. Neither of them is
> optimal unfortunately.

yes, but this one doesn't look right.

> Oleg said he would look into this and I have seen
> some patches but didn't geto check them.

Only preparations so far.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
