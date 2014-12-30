Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 1035D6B0038
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 16:29:18 -0500 (EST)
Received: by mail-we0-f175.google.com with SMTP id k11so1593127wes.34
        for <linux-mm@kvack.org>; Tue, 30 Dec 2014 13:29:17 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id m5si3981003wja.36.2014.12.30.13.29.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 30 Dec 2014 13:29:17 -0800 (PST)
Date: Tue, 30 Dec 2014 22:29:16 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC PATCH 0/4] kstrdup optimization
Message-ID: <20141230212915.GN2915@two.firstfloor.org>
References: <54A25135.5030103@samsung.com>
 <20141230083230.GA17639@rhlx01.hs-esslingen.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141230083230.GA17639@rhlx01.hs-esslingen.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Mohr <andi@lisas.de>
Cc: Andrzej Hajda <a.hajda@samsung.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org

> This symmetry issue probably could be cleanly avoided only
> by having kfree() itself contain such an identifying check, as you suggest
> (thereby slowing down kfree() performance).

It actually shouldn't slow it down. kfree already complains if you free
a non slab page, this could be just in front of the error check.

The bigger concern is that it may hide some programing errors elsewhere
though. So it's probably better to keep it a separate function.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
