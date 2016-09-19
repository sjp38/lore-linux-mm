Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id C31F36B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 15:58:12 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id h186so292248844oia.1
        for <linux-mm@kvack.org>; Mon, 19 Sep 2016 12:58:12 -0700 (PDT)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [69.252.207.33])
        by mx.google.com with ESMTPS id w125si24670394ith.36.2016.09.19.12.58.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Sep 2016 12:58:12 -0700 (PDT)
Date: Mon, 19 Sep 2016 14:57:08 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: More OOM problems
In-Reply-To: <78e34617-0c63-9f1f-f7c7-93dd64556307@suse.cz>
Message-ID: <alpine.DEB.2.20.1609191456220.28320@east.gentwo.org>
References: <CA+55aFwu30Yz52yW+MRHt_JgpqZkq4DHdWR-pX4+gO_OK7agCQ@mail.gmail.com> <214a6307-3bcf-38e1-7984-48cc9f838a48@suse.cz> <87twdc4rzs.fsf@tassilo.jf.intel.com> <alpine.DEB.2.20.1609190836540.12121@east.gentwo.org> <20160919143106.GX5871@two.firstfloor.org>
 <78e34617-0c63-9f1f-f7c7-93dd64556307@suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andi Kleen <andi@firstfloor.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Arkadiusz Miskiewicz <a.miskiewicz@gmail.com>, Ralf-Peter Rohbeck <Ralf-Peter.Rohbeck@quantum.com>, Jiri Slaby <jslaby@suse.com>, Olaf Hering <olaf@aepfle.de>, Joonsoo Kim <js1304@gmail.com>, linux-mm <linux-mm@kvack.org>

On Mon, 19 Sep 2016, Vlastimil Babka wrote:

> There's no __GFP_NOWARN | __GFP_NORETRY, so it clearly wasn't the
> opportunistic "initial higher-order allocation". The logical conclusion is
> that it was a genuine order-3 allocation. 1kB allocation using order-3 would
> silently fail without OOM or warning, and then fallback to order-0.

Sorry if you really want an object that is greater than page size then the
slab allocators wont be able to satisfy that with an order 0 allocation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
