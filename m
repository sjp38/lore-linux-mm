Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
	by kanga.kvack.org (Postfix) with ESMTP id C86D16B0037
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 18:35:35 -0500 (EST)
Received: by mail-qa0-f48.google.com with SMTP id w5so68762qac.14
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 15:35:35 -0800 (PST)
Received: from mail-yh0-x22c.google.com (mail-yh0-x22c.google.com [2607:f8b0:4002:c01::22c])
        by mx.google.com with ESMTPS id t1si502905qai.12.2013.12.05.15.35.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Dec 2013 15:35:34 -0800 (PST)
Received: by mail-yh0-f44.google.com with SMTP id f64so13339609yha.31
        for <linux-mm@kvack.org>; Thu, 05 Dec 2013 15:35:34 -0800 (PST)
Date: Thu, 5 Dec 2013 15:35:30 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] Fix race between oom kill and task exit
In-Reply-To: <20131205172931.GA26018@redhat.com>
Message-ID: <alpine.DEB.2.02.1312051531330.7717@chino.kir.corp.google.com>
References: <3917C05D9F83184EAA45CE249FF1B1DD0253093A@SHSMSX103.ccr.corp.intel.com> <20131128063505.GN3556@cmpxchg.org> <CAJ75kXZXxCMgf8=pghUWf=W9EKf3Z4nzKKy=CAn+7keVF_DCRA@mail.gmail.com> <20131128120018.GL2761@dhcp22.suse.cz> <20131128183830.GD20740@redhat.com>
 <20131202141203.GA31402@redhat.com> <alpine.DEB.2.02.1312041655370.13608@chino.kir.corp.google.com> <20131205172931.GA26018@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, William Dauchy <wdauchy@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Ma, Xindong" <xindong.ma@intel.com>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, gregkh@linuxfoundation.org, "Tu, Xiaobing" <xiaobing.tu@intel.com>, azurIt <azurit@pobox.sk>, Sameer Nanda <snanda@chromium.org>

On Thu, 5 Dec 2013, Oleg Nesterov wrote:

> > > OK, I am going to send the initial fixes today. This means (I hope)
> > > that we do not need this or Sameer's "[PATCH] mm, oom: Fix race when
> > > selecting process to kill".
> >
> > Your v2 series looks good and I suspect anybody trying them doesn't have
> > additional reports of the infinite loop?  Should they be marked for
> > stable?
> 
> Unlikely...
> 
> I think the patch from Sameer makes more sense for stable as a temporary
> (and obviously incomplete) fix.
> 

There's a problem because none of this is currently even in linux-next.  I 
think we could make a case for getting Sameer's patch at 
http://marc.info/?l=linux-kernel&m=138436313021133 to be merged for 
stable, but then we'd have to revert it in linux-next before merging your 
series at http://marc.info/?l=linux-kernel&m=138616217925981.  All of the 
issues you present in that series seem to be stable material, so why not 
just go ahead with your series and mark it for stable for 3.13?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
