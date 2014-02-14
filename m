Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5312F6B0031
	for <linux-mm@kvack.org>; Fri, 14 Feb 2014 13:48:31 -0500 (EST)
Received: by mail-qa0-f42.google.com with SMTP id k4so18902543qaq.15
        for <linux-mm@kvack.org>; Fri, 14 Feb 2014 10:48:31 -0800 (PST)
Received: from qmta10.emeryville.ca.mail.comcast.net (qmta10.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:17])
        by mx.google.com with ESMTP id e60si4460853qgf.182.2014.02.14.10.48.30
        for <linux-mm@kvack.org>;
        Fri, 14 Feb 2014 10:48:30 -0800 (PST)
Date: Fri, 14 Feb 2014 12:48:28 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 8/9] slab: destroy a slab without holding any alien cache
 lock
In-Reply-To: <1392361043-22420-9-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1402141247590.12887@nuc>
References: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com> <1392361043-22420-9-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Fri, 14 Feb 2014, Joonsoo Kim wrote:

> I haven't heard that this alien cache lock is contended, but to reduce
> chance of contention would be better generally. And with this change,
> we can simplify complex lockdep annotation in slab code.
> In the following patch, it will be implemented.

Ok. Same move as before with the regular freeing.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
