Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 02C116B00BC
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 09:44:12 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id ECCEC82CB3F
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 09:44:33 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Ed3fDGPVsm67 for <linux-mm@kvack.org>;
	Fri, 28 Aug 2009 09:44:28 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6CC7682CB43
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 09:44:07 -0400 (EDT)
Date: Fri, 28 Aug 2009 09:42:40 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH v2] SLUB: fix ARCH_KMALLOC_MINALIGN cases 64 and 256
In-Reply-To: <1251458934-25838-1-git-send-email-aaro.koskinen@nokia.com>
Message-ID: <alpine.DEB.1.10.0908280942230.32301@gentwo.org>
References: <> <1251458934-25838-1-git-send-email-aaro.koskinen@nokia.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Aaro Koskinen <aaro.koskinen@nokia.com>
Cc: mpm@selenic.com, penberg@cs.helsinki.fi, linux-mm@kvack.org, Artem.Bityutskiy@nokia.com
List-ID: <linux-mm.kvack.org>



Acked-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
