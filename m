Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 938E76B0012
	for <linux-mm@kvack.org>; Sun,  3 Jul 2011 15:53:14 -0400 (EDT)
Received: by bwd14 with SMTP id 14so5414444bwd.14
        for <linux-mm@kvack.org>; Sun, 03 Jul 2011 12:53:11 -0700 (PDT)
Date: Sun, 3 Jul 2011 23:53:06 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [kernel-hardening] Re: [RFC v1] implement SL*B and stack
 usercopy runtime checks
Message-ID: <20110703195306.GA9714@albatros>
References: <20110703111028.GA2862@albatros>
 <CA+55aFzXEoTyK0Sm-y=6xGmLMWzQiSQ7ELJ2-WL_PrP3r44MSg@mail.gmail.com>
 <20110703185709.GA7414@albatros>
 <CA+55aFwuvk7xifqCX=E3DtV=JCJEzyODcF4o6xLL0U1N_P-Rbg@mail.gmail.com>
 <20110703192442.GA9504@albatros>
 <1309721875.18925.30.camel@Joe-Laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1309721875.18925.30.camel@Joe-Laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: kernel-hardening@lists.openwall.com, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

On Sun, Jul 03, 2011 at 12:37 -0700, Joe Perches wrote:
> On Sun, 2011-07-03 at 23:24 +0400, Vasiliy Kulikov wrote:
> > Btw, if the perfomance will be acceptable, what do you think about
> > logging/reacting on the spotted overflows?
> 
> If you do, it might be useful to track the found location(s)

Sure.


> and only emit the overflow log entry once as found.

Hmm, if consider it as a purely debugging feature, then yes.  But if
consider it as a try to block some exploitation attempt, then no.
I'd appresiate the latter.


> Maybe use __builtin_return_address(depth) for tracking.

PaX/Grsecurity uses dump_stack() and do_group_exit(SIGKILL);  If setup,
it kills all user's processes and locks the user for some time.  I don't
really propose the latter, but some reaction (to at least slowdown a
blind bruteforce) might be useful.


Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
