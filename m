Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 47CE36B0031
	for <linux-mm@kvack.org>; Wed,  9 Oct 2013 09:29:02 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id md4so897322pbc.2
        for <linux-mm@kvack.org>; Wed, 09 Oct 2013 06:29:01 -0700 (PDT)
Date: Wed, 9 Oct 2013 14:28:17 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] slub: proper kmemleak tracking if CONFIG_SLUB_DEBUG
 disabled
Message-ID: <20131009132816.GA32201@arm.com>
References: <1381273137-14680-1-git-send-email-tim.bird@sonymobile.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1381273137-14680-1-git-send-email-tim.bird@sonymobile.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Bird <tim.bird@sonymobile.com>
Cc: "cl@linux.com" <cl@linux.com>, "frowand.list@gmail.com" <frowand.list@gmail.com>, "bjorn.andersson@sonymobile.com" <bjorn.andersson@sonymobile.com>, "tbird20d@gmail.com" <tbird20d@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Roman Bobniev <Roman.Bobniev@sonymobile.com>

On Tue, Oct 08, 2013 at 11:58:57PM +0100, Tim Bird wrote:
> From: Roman Bobniev <Roman.Bobniev@sonymobile.com>
> 
> Move all kmemleak calls into hook functions, and make it so
> that all hooks (both inside and outside of #ifdef CONFIG_SLUB_DEBUG)
> call the appropriate kmemleak routines.  This allows for kmemleak
> to be configured independently of slub debug features.
> 
> It also fixes a bug where kmemleak was only partially enabled in some
> configurations.
> 
> Signed-off-by: Roman Bobniev <Roman.Bobniev@sonymobile.com>
> Signed-off-by: Tim Bird <tim.bird@sonymobile.com>

Looks ok to me.

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
