Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5A4AB6B0031
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 15:07:59 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so1369533pbb.28
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 12:07:59 -0700 (PDT)
Date: Wed, 9 Oct 2013 19:07:52 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: proper kmemleak tracking if CONFIG_SLUB_DEBUG
 disabled
In-Reply-To: <1381273137-14680-1-git-send-email-tim.bird@sonymobile.com>
Message-ID: <000001419e9e3e33-67807dca-e435-43ee-88bc-3ead54a83762-000000@email.amazonses.com>
References: <1381273137-14680-1-git-send-email-tim.bird@sonymobile.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Bird <tim.bird@sonymobile.com>
Cc: catalin.marinas@arm.com, frowand.list@gmail.com, bjorn.andersson@sonymobile.com, tbird20d@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Roman Bobniev <Roman.Bobniev@sonymobile.com>, Pekka Enberg <penberg@kernel.org>

On Tue, 8 Oct 2013, Tim Bird wrote:

> It also fixes a bug where kmemleak was only partially enabled in some
> configurations.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
