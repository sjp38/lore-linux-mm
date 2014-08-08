Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id AB20A6B0035
	for <linux-mm@kvack.org>; Fri,  8 Aug 2014 10:45:00 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id v10so5598494qac.5
        for <linux-mm@kvack.org>; Fri, 08 Aug 2014 07:45:00 -0700 (PDT)
Received: from qmta08.emeryville.ca.mail.comcast.net (qmta08.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:80])
        by mx.google.com with ESMTP id 81si10489483qgx.26.2014.08.08.07.44.59
        for <linux-mm@kvack.org>;
        Fri, 08 Aug 2014 07:45:00 -0700 (PDT)
Date: Fri, 8 Aug 2014 09:44:57 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH for v3.17-rc1] Revert "slab: remove BAD_ALIEN_MAGIC"
In-Reply-To: <1407481239-7572-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.11.1408080943280.16459@gentwo.org>
References: <1407481239-7572-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Vladimir Davydov <vdavydov@parallels.com>

On Fri, 8 Aug 2014, Joonsoo Kim wrote:

> This reverts commit a640616822b2 ("slab: remove BAD_ALIEN_MAGIC").

Lets hold off on this one. I am bit confused as to why a non NUMA system
would have multiple NUMA nodes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
