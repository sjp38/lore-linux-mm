Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 71C186B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 14:18:28 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id t83so111810897oie.0
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 11:18:28 -0700 (PDT)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id 10si21025391oth.65.2016.09.19.11.18.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 11:18:27 -0700 (PDT)
Received: by mail-oi0-x22f.google.com with SMTP id t83so78724904oie.3
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 11:18:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <78e34617-0c63-9f1f-f7c7-93dd64556307@suse.cz>
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com>
 <214a6307-3bcf-38e1-7984-48cc9f838a48@suse.cz> <87twdc4rzs.fsf@tassilo.jf.intel.com>
 <alpine.DEB.2.20.1609190836540.12121@east.gentwo.org> <20160919143106.GX5871@two.firstfloor.org>
 <78e34617-0c63-9f1f-f7c7-93dd64556307@suse.cz>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 19 Sep 2016 11:18:26 -0700
Message-ID: <CA+55aFxgzE34D=a5ouRRgW-aca_GSsoVWX5TSOt_2rmJFQShQw@mail.gmail.com>
Subject: Re: More OOM problems
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On Mon, Sep 19, 2016 at 7:41 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
>
> There's no __GFP_NOWARN | __GFP_NORETRY, so it clearly wasn't the
> opportunistic "initial higher-order allocation". The logical conclusion is
> that it was a genuine order-3 allocation. 1kB allocation using order-3 would
> silently fail without OOM or warning, and then fallback to order-0.

Yes, I think you're right. The kcalloc() probably *was* a 32kB
allocation. In which case it's really more of a i915 driver issue.
I'll talk to the drm people and see if they can perhaps fix their
allocation patterns.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
