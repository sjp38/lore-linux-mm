Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id E065C6B0038
	for <linux-mm@kvack.org>; Tue, 30 Dec 2014 01:45:45 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id kx10so19041866pab.2
        for <linux-mm@kvack.org>; Mon, 29 Dec 2014 22:45:45 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id aw10si56451099pbd.53.2014.12.29.22.45.43
        for <linux-mm@kvack.org>;
        Mon, 29 Dec 2014 22:45:44 -0800 (PST)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC PATCH 0/4] kstrdup optimization
References: <1419864510-24834-1-git-send-email-a.hajda@samsung.com>
Date: Mon, 29 Dec 2014 22:45:42 -0800
In-Reply-To: <1419864510-24834-1-git-send-email-a.hajda@samsung.com> (Andrzej
	Hajda's message of "Mon, 29 Dec 2014 15:48:26 +0100")
Message-ID: <87egrhws89.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrzej Hajda <a.hajda@samsung.com>
Cc: linux-mm@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org

Andrzej Hajda <a.hajda@samsung.com> writes:

> kstrdup if often used to duplicate strings where neither source neither
> destination will be ever modified. In such case we can just reuse the source
> instead of duplicating it. The problem is that we must be sure that
> the source is non-modifiable and its life-time is long enough.

What happens if someone is to kfree() these strings?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
