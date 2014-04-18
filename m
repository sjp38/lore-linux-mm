Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 665836B0031
	for <linux-mm@kvack.org>; Fri, 18 Apr 2014 12:41:48 -0400 (EDT)
Received: by mail-qa0-f52.google.com with SMTP id s7so1725477qap.39
        for <linux-mm@kvack.org>; Fri, 18 Apr 2014 09:41:48 -0700 (PDT)
Received: from qmta12.emeryville.ca.mail.comcast.net (qmta12.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:227])
        by mx.google.com with ESMTP id s32si10835024qgd.93.2014.04.18.09.41.47
        for <linux-mm@kvack.org>;
        Fri, 18 Apr 2014 09:41:47 -0700 (PDT)
Date: Fri, 18 Apr 2014 11:41:44 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: fix the type of the index on freelist index
 accessor
In-Reply-To: <1397805849-4913-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <alpine.DEB.2.10.1404181141200.9431@gentwo.org>
References: <1397805849-4913-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Steven King <sfking@fdwdc.com>, Geert Uytterhoeven <geert@linux-m68k.org>


> Reported-by: Steven King <sfking@fdwdc.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
