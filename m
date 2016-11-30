Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 28D276B0038
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 09:15:18 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 83so306443827pfx.1
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 06:15:18 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f17si45036443pge.120.2016.11.30.05.59.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Nov 2016 05:59:49 -0800 (PST)
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
References: <20161122160629.uzt2u6m75ash4ved@merlins.org>
 <48061a22-0203-de54-5a44-89773bff1e63@suse.cz>
 <CA+55aFweND3KoV=00onz0Y5W9ViFedd-nvfCuB+phorc=75tpQ@mail.gmail.com>
 <20161123063410.GB2864@dhcp22.suse.cz>
 <20161128072315.GC14788@dhcp22.suse.cz>
 <20161129155537.f6qgnfmnoljwnx6j@merlins.org>
 <20161129160751.GC9796@dhcp22.suse.cz>
 <20161129163406.treuewaqgt4fy4kh@merlins.org>
 <CA+55aFzNe=3e=cDig+vEzZS5jm2c6apPV4s5NKG4eYL4_jxQjQ@mail.gmail.com>
 <20161129174019.fywddwo5h4pyix7r@merlins.org>
 <20161129230135.GM7179@merlins.org>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <66f5d234-d221-fa3c-7abe-71fc4f5259ec@I-love.SAKURA.ne.jp>
Date: Wed, 30 Nov 2016 22:58:19 +0900
MIME-Version: 1.0
In-Reply-To: <20161129230135.GM7179@merlins.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marc MERLIN <marc@merlins.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 2016/11/30 8:01, Marc MERLIN wrote:
> And, after 5H of copying, not a single hang, or USB disconnect, or anything.
> Obviously this seems to point to other problems in the code, and I have no
> idea which layer is a culprit here, but reducing the buffers absolutely
> helped a lot.

Maybe you can try commit 63f53dea0c9866e9 ("mm: warn about allocations which stall for too long")
or http://lkml.kernel.org/r/1478416501-10104-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
for finding the culprit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
