Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id AF6726B0039
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 19:56:56 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id f73so11961549yha.7
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 16:56:56 -0800 (PST)
Received: from mail-yh0-x22f.google.com (mail-yh0-x22f.google.com [2607:f8b0:4002:c01::22f])
        by mx.google.com with ESMTPS id y62si56283669yhc.169.2013.12.04.16.56.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Dec 2013 16:56:55 -0800 (PST)
Received: by mail-yh0-f47.google.com with SMTP id 29so11964569yhl.6
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 16:56:55 -0800 (PST)
Date: Wed, 4 Dec 2013 16:56:52 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Fix race between oom kill and task exit
In-Reply-To: <20131202141203.GA31402@redhat.com>
Message-ID: <alpine.DEB.2.02.1312041655370.13608@chino.kir.corp.google.com>
References: <3917C05D9F83184EAA45CE249FF1B1DD0253093A@SHSMSX103.ccr.corp.intel.com> <20131128063505.GN3556@cmpxchg.org> <CAJ75kXZXxCMgf8=pghUWf=W9EKf3Z4nzKKy=CAn+7keVF_DCRA@mail.gmail.com> <20131128120018.GL2761@dhcp22.suse.cz> <20131128183830.GD20740@redhat.com>
 <20131202141203.GA31402@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>, William Dauchy <wdauchy@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Ma, Xindong" <xindong.ma@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>, "Tu, Xiaobing" <xiaobing.tu@intel.com>, azurIt <azurit@pobox.sk>, Sameer Nanda <snanda@chromium.org>

On Mon, 2 Dec 2013, Oleg Nesterov wrote:

> OK, I am going to send the initial fixes today. This means (I hope)
> that we do not need this or Sameer's "[PATCH] mm, oom: Fix race when
> selecting process to kill".
> 

Your v2 series looks good and I suspect anybody trying them doesn't have 
additional reports of the infinite loop?  Should they be marked for 
stable?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
