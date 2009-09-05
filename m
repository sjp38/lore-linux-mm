Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id D82A26B0083
	for <linux-mm@kvack.org>; Sat,  5 Sep 2009 04:49:00 -0400 (EDT)
Message-ID: <4AA225FC.7080601@cs.helsinki.fi>
Date: Sat, 05 Sep 2009 11:49:00 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH v3 4/5] kmemleak: fix sparse warning over overshadowed
 flags
References: <1252111494-7593-1-git-send-email-lrodriguez@atheros.com> <1252111494-7593-5-git-send-email-lrodriguez@atheros.com>
In-Reply-To: <1252111494-7593-5-git-send-email-lrodriguez@atheros.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Cc: catalin.marinas@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mcgrof@gmail.com
List-ID: <linux-mm.kvack.org>

Luis R. Rodriguez wrote:
> A secondary irq_save is not required as a locking before it was
> already disabling irqs.
> 
> This fixes this sparse warning:
> mm/kmemleak.c:512:31: warning: symbol 'flags' shadows an earlier one
> mm/kmemleak.c:448:23: originally declared here
> 
> Signed-off-by: Luis R. Rodriguez <lrodriguez@atheros.com>

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
