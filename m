Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8213D8E005B
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 16:33:05 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id k69so7356132ywa.12
        for <linux-mm@kvack.org>; Sat, 29 Dec 2018 13:33:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o192sor6172633ywo.136.2018.12.29.13.33.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 29 Dec 2018 13:33:04 -0800 (PST)
MIME-Version: 1.0
References: <20181229013147.211079-1-shakeelb@google.com> <20181229130352.8a1075da5b7583d5e0e4aa9a@linux-foundation.org>
 <20181229212619.GB73871@dennisz-mbp>
In-Reply-To: <20181229212619.GB73871@dennisz-mbp>
From: Shakeel Butt <shakeelb@google.com>
Date: Sat, 29 Dec 2018 13:32:53 -0800
Message-ID: <CALvZod6SPOUA-kx8g6s+HXXGQ3gJ5FPc=hjpWs7ZBpJi472xbQ@mail.gmail.com>
Subject: Re: [PATCH] percpu: plumb gfp flag to pcpu_get_pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennis@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Dennis,

On Sat, Dec 29, 2018 at 1:26 PM Dennis Zhou <dennis@kernel.org> wrote:
>
> Hi Andrew,
>
> On Sat, Dec 29, 2018 at 01:03:52PM -0800, Andrew Morton wrote:
> > On Fri, 28 Dec 2018 17:31:47 -0800 Shakeel Butt <shakeelb@google.com> wrote:
> >
> > > __alloc_percpu_gfp() can be called from atomic context, so, make
> > > pcpu_get_pages use the gfp provided to the higher layer.
> >
> > Does this fix any user-visible issues?
>
> Sorry for not getting to this earlier. I'm currently traveling. I
> respoeded on the patch itself. Do you mind unqueuing? I explain in more
> detail on the patch, but __alloc_percpu_gfp() will never call
> pcpu_get_pages() when called as not GFP_KERNEL.
>

Thanks for the explanation. Andrew, please ignore/drop this patch.

thanks,
Shakeel
