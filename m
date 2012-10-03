Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 197E86B006E
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 01:37:48 -0400 (EDT)
Received: by padfa10 with SMTP id fa10so6960830pad.14
        for <linux-mm@kvack.org>; Tue, 02 Oct 2012 22:37:47 -0700 (PDT)
Date: Tue, 2 Oct 2012 22:37:45 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: use %pK for /proc/vmallocinfo
In-Reply-To: <CAGXu5j+ZU_wrqeEYE7GCE6ArFo8z4AO=OW7mOSn0-fp1E9B6+Q@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1210022236370.10573@chino.kir.corp.google.com>
References: <20121002234934.GA9194@www.outflux.net> <alpine.DEB.2.00.1210022209070.9523@chino.kir.corp.google.com> <CAGXu5j+ZU_wrqeEYE7GCE6ArFo8z4AO=OW7mOSn0-fp1E9B6+Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Joe Perches <joe@perches.com>, Kautuk Consul <consul.kautuk@gmail.com>, linux-mm@kvack.org, Brad Spengler <spender@grsecurity.net>

On Tue, 2 Oct 2012, Kees Cook wrote:

> >> In the paranoid case of sysctl kernel.kptr_restrict=2, mask the kernel
> >> virtual addresses in /proc/vmallocinfo too.
> >>
> >> Reported-by: Brad Spengler <spender@grsecurity.net>
> >> Signed-off-by: Kees Cook <keescook@chromium.org>
> >
> > /proc/vmallocinfo is S_IRUSR, not S_IRUGO, so exactly what are you trying
> > to protect?
> 
> Trying to block the root user from seeing virtual memory addresses
> (mode 2 of kptr_restrict).
> 
> Documentation/sysctl/kernel.txt:
> "This toggle indicates whether restrictions are placed on
> exposing kernel addresses via /proc and other interfaces.  When
> kptr_restrict is set to (0), there are no restrictions.  When
> kptr_restrict is set to (1), the default, kernel pointers
> printed using the %pK format specifier will be replaced with 0's
> unless the user has CAP_SYSLOG.  When kptr_restrict is set to
> (2), kernel pointers printed using %pK will be replaced with 0's
> regardless of privileges."
> 
> Even though it's S_IRUSR, it still needs %pK for the paranoid case.
> 

So root does echo 0 > /proc/sys/kernel/kptr_restrict first.  Again: what 
are you trying to protect?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
