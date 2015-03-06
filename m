Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id B1D126B006E
	for <linux-mm@kvack.org>; Fri,  6 Mar 2015 17:02:32 -0500 (EST)
Received: by qgfi50 with SMTP id i50so16111015qgf.10
        for <linux-mm@kvack.org>; Fri, 06 Mar 2015 14:02:32 -0800 (PST)
Received: from mail-qg0-x22b.google.com (mail-qg0-x22b.google.com. [2607:f8b0:400d:c04::22b])
        by mx.google.com with ESMTPS id w135si9020629qkw.2.2015.03.06.14.02.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Mar 2015 14:02:31 -0800 (PST)
Received: by qgfh3 with SMTP id h3so16108071qgf.13
        for <linux-mm@kvack.org>; Fri, 06 Mar 2015 14:02:31 -0800 (PST)
Date: Fri, 6 Mar 2015 17:02:28 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] percpu: Fix trivial typos in comments
Message-ID: <20150306220228.GC15052@htj.duckdns.org>
References: <1425678748-11848-1-git-send-email-yguerrini@tomshardware.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1425678748-11848-1-git-send-email-yguerrini@tomshardware.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yannick Guerrini <yguerrini@tomshardware.fr>
Cc: cl@linux-foundation.org, trivial@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 06, 2015 at 10:52:28PM +0100, Yannick Guerrini wrote:
> Change 'iff' to 'if'

iff is intentional.

 http://en.wikipedia.org/wiki/If_and_only_if

> Change 'tranlated' to 'translated'
> Change 'mutliples' to 'multiples'

Can you refresh the patch with just the above two?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
