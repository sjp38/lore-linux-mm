Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 62D7B6B0012
	for <linux-mm@kvack.org>; Sun,  3 Jul 2011 15:37:59 -0400 (EDT)
Subject: Re: [kernel-hardening] Re: [RFC v1] implement SL*B and stack
 usercopy runtime checks
From: Joe Perches <joe@perches.com>
In-Reply-To: <20110703192442.GA9504@albatros>
References: <20110703111028.GA2862@albatros>
	 <CA+55aFzXEoTyK0Sm-y=6xGmLMWzQiSQ7ELJ2-WL_PrP3r44MSg@mail.gmail.com>
	 <20110703185709.GA7414@albatros>
	 <CA+55aFwuvk7xifqCX=E3DtV=JCJEzyODcF4o6xLL0U1N_P-Rbg@mail.gmail.com>
	 <20110703192442.GA9504@albatros>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 03 Jul 2011 12:37:55 -0700
Message-ID: <1309721875.18925.30.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: kernel-hardening@lists.openwall.com, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Sun, 2011-07-03 at 23:24 +0400, Vasiliy Kulikov wrote:
> Btw, if the perfomance will be acceptable, what do you think about
> logging/reacting on the spotted overflows?

If you do, it might be useful to track the found location(s)
and only emit the overflow log entry once as found.

Maybe use __builtin_return_address(depth) for tracking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
