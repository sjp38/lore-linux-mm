Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9549A8D0039
	for <linux-mm@kvack.org>; Thu, 17 Mar 2011 02:23:42 -0400 (EDT)
Received: by yxt33 with SMTP id 33so1296607yxt.14
        for <linux-mm@kvack.org>; Wed, 16 Mar 2011 23:23:39 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110316223631.20091.qmail@science.horizon.com>
References: <alpine.DEB.2.00.1103161352150.11002@chino.kir.corp.google.com>
	<20110316223631.20091.qmail@science.horizon.com>
Date: Thu, 17 Mar 2011 08:23:39 +0200
Message-ID: <AANLkTikDAEuTcrgo0YcUO40A9x5jaL-d+ZPviCXANe3r@mail.gmail.com>
Subject: Re: [PATCH 5/8] mm/slub: Factor out some common code.
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: rientjes@google.com, herbert@gondor.hengli.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, penberg@cs.helsinki.fi

Hi George!

On Thu, Mar 17, 2011 at 12:36 AM, George Spelvin <linux@horizon.com> wrote:
> Um, can you name a (64-bit) architecture on which 32-bit is more
> expensive than 64-bit?

I certainly don't but I'd still like to ask you to change it to
'unsigned long'. That's a Linux kernel idiom and we're not going to
change the whole kernel.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
