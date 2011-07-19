Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6E94D6B0083
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 03:40:51 -0400 (EDT)
Received: by ewy9 with SMTP id 9so2809354ewy.14
        for <linux-mm@kvack.org>; Tue, 19 Jul 2011 00:40:48 -0700 (PDT)
Date: Tue, 19 Jul 2011 11:40:43 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [kernel-hardening] Re: [RFC v2] implement SL*B and stack
 usercopy runtime checks
Message-ID: <20110719074043.GA3942@albatros>
References: <20110703111028.GA2862@albatros>
 <CA+55aFzXEoTyK0Sm-y=6xGmLMWzQiSQ7ELJ2-WL_PrP3r44MSg@mail.gmail.com>
 <20110718183951.GA3748@albatros>
 <20110718115237.14d96c03.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110718115237.14d96c03.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Mon, Jul 18, 2011 at 11:52 -0700, Andrew Morton wrote:
> > +noinline bool __kernel_access_ok(const void *ptr, unsigned long len)
> 
> noinline seems unneeded

Ah, understood what you mean.  It is .c, and users are in other .c, so
it is indeed redundant.

Thanks!

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
