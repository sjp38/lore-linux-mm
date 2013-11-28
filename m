Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id F3F6C6B0035
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 07:00:21 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id a1so6213625wgh.17
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 04:00:21 -0800 (PST)
Received: from mail-ea0-x22b.google.com (mail-ea0-x22b.google.com [2a00:1450:4013:c01::22b])
        by mx.google.com with ESMTPS id x19si12393597wie.11.2013.11.28.04.00.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 28 Nov 2013 04:00:21 -0800 (PST)
Received: by mail-ea0-f171.google.com with SMTP id h10so5736691eak.16
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 04:00:21 -0800 (PST)
Date: Thu, 28 Nov 2013 13:00:18 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] Fix race between oom kill and task exit
Message-ID: <20131128120018.GL2761@dhcp22.suse.cz>
References: <3917C05D9F83184EAA45CE249FF1B1DD0253093A@SHSMSX103.ccr.corp.intel.com>
 <20131128063505.GN3556@cmpxchg.org>
 <CAJ75kXZXxCMgf8=pghUWf=W9EKf3Z4nzKKy=CAn+7keVF_DCRA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJ75kXZXxCMgf8=pghUWf=W9EKf3Z4nzKKy=CAn+7keVF_DCRA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Dauchy <wdauchy@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "Ma, Xindong" <xindong.ma@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rientjes@google.com" <rientjes@google.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "Tu, Xiaobing" <xiaobing.tu@intel.com>, azurIt <azurit@pobox.sk>, Sameer Nanda <snanda@chromium.org>, Oleg Nesterov <oleg@redhat.com>

[CCing Oleg - the thread started here:
https://lkml.org/lkml/2013/11/28/2]

On Thu 28-11-13 09:41:40, William Dauchy wrote:
[...]
> However, I'm now wondering if this present patch is a replacement of
> Sameer Nanda's patch or if this a complementary patch.

They are both trying to solve the same issue. Neither of them is
optimal unfortunately. Oleg said he would look into this and I have seen
some patches but didn't geto check them.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
