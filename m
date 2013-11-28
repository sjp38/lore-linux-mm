Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f170.google.com (mail-vc0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2B31C6B0035
	for <linux-mm@kvack.org>; Thu, 28 Nov 2013 03:42:03 -0500 (EST)
Received: by mail-vc0-f170.google.com with SMTP id ht10so5692883vcb.15
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 00:42:02 -0800 (PST)
Received: from mail-ve0-x22f.google.com (mail-ve0-x22f.google.com [2607:f8b0:400c:c01::22f])
        by mx.google.com with ESMTPS id dp3si22515554vcb.96.2013.11.28.00.42.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 28 Nov 2013 00:42:01 -0800 (PST)
Received: by mail-ve0-f175.google.com with SMTP id jx11so5806276veb.6
        for <linux-mm@kvack.org>; Thu, 28 Nov 2013 00:42:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131128063505.GN3556@cmpxchg.org>
References: <3917C05D9F83184EAA45CE249FF1B1DD0253093A@SHSMSX103.ccr.corp.intel.com>
 <20131128063505.GN3556@cmpxchg.org>
From: William Dauchy <wdauchy@gmail.com>
Date: Thu, 28 Nov 2013 09:41:40 +0100
Message-ID: <CAJ75kXZXxCMgf8=pghUWf=W9EKf3Z4nzKKy=CAn+7keVF_DCRA@mail.gmail.com>
Subject: Re: [PATCH] Fix race between oom kill and task exit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "Ma, Xindong" <xindong.ma@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "rientjes@google.com" <rientjes@google.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "Tu, Xiaobing" <xiaobing.tu@intel.com>, azurIt <azurit@pobox.sk>, Sameer Nanda <snanda@chromium.org>

Hi Johannes,

On Thu, Nov 28, 2013 at 7:35 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> Cc William and azur who might have encountered this problem.

Thank you for letting me know.
Note that before this patch I saw the one from Sameer Nanda
mm, oom: Fix race when selecting process to kill
https://lkml.org/lkml/2013/11/13/336

After applying this later one, I still have the issue I sent you (oom
killing a task outside cgroup i.e Task in / killed as a result of
limit of /lxc/foo) *but* I don't have a crash any more. So I was in
the process of reapplying your debug patch to send you a new report.

However, I'm now wondering if this present patch is a replacement of
Sameer Nanda's patch or if this a complementary patch.

Thanks,
-- 
William

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
