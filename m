Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F04BF6B0169
	for <linux-mm@kvack.org>; Thu, 28 Jul 2011 06:04:35 -0400 (EDT)
Received: by vxg38 with SMTP id 38so2584189vxg.14
        for <linux-mm@kvack.org>; Thu, 28 Jul 2011 03:04:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1107221108190.2996@tiger>
References: <alpine.DEB.2.00.1107221108190.2996@tiger>
Date: Thu, 28 Jul 2011 13:04:32 +0300
Message-ID: <CAOJsxLHniS9Hx+ep_i2qbE_Oo6PnkNCK5dNARW5egg9Bso4Ovg@mail.gmail.com>
Subject: Re: [GIT PULL] SLAB changes for v3.1-rc0
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Fri, Jul 22, 2011 at 11:08 AM, Pekka Enberg <penberg@kernel.org> wrote:
> Please note that the SLUB lockless slowpath patches will be sent in a
> separate pull request.

Christoph, your debugging fix has been in linux-next for few days now
and no problem have been reported. I'm considering sending the series
to Linus. What do you think?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
