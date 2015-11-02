Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id B751482F64
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 14:11:51 -0500 (EST)
Received: by ykdr3 with SMTP id r3so149420603ykd.1
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 11:11:51 -0800 (PST)
Received: from mail-yk0-x22e.google.com (mail-yk0-x22e.google.com. [2607:f8b0:4002:c07::22e])
        by mx.google.com with ESMTPS id p186si6235446ywp.284.2015.11.02.11.11.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Nov 2015 11:11:51 -0800 (PST)
Received: by ykdr3 with SMTP id r3so149420368ykd.1
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 11:11:50 -0800 (PST)
Date: Mon, 2 Nov 2015 14:11:48 -0500
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [patch 3/3] vmstat: Create our own workqueue
Message-ID: <20151102191148.GB9553@mtj.duckdns.org>
References: <20151029022447.GB27115@mtj.duckdns.org>
 <20151029030822.GD27115@mtj.duckdns.org>
 <alpine.DEB.2.20.1510292000340.30861@east.gentwo.org>
 <201510311143.BIH87000.tOSVFHOFJMLFOQ@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.20.1511021011460.27740@east.gentwo.org>
 <201511030152.JGF95845.SHVLOMtOJFFOFQ@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.20.1511021209150.28799@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1511021209150.28799@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de

On Mon, Nov 02, 2015 at 12:10:04PM -0600, Christoph Lameter wrote:
> Well true that is dependend on the correct workqueue operation. I though
> that was fixed by Tejun?

At least for now, we're going with Tetsuo's short sleep patch.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
