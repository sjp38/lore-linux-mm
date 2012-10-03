Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id A68486B005D
	for <linux-mm@kvack.org>; Wed,  3 Oct 2012 01:12:46 -0400 (EDT)
Received: by dadi14 with SMTP id i14so2760055dad.14
        for <linux-mm@kvack.org>; Tue, 02 Oct 2012 22:12:45 -0700 (PDT)
Date: Tue, 2 Oct 2012 22:12:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: use %pK for /proc/vmallocinfo
In-Reply-To: <20121002234934.GA9194@www.outflux.net>
Message-ID: <alpine.DEB.2.00.1210022209070.9523@chino.kir.corp.google.com>
References: <20121002234934.GA9194@www.outflux.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Joe Perches <joe@perches.com>, Kautuk Consul <consul.kautuk@gmail.com>, linux-mm@kvack.org, Brad Spengler <spender@grsecurity.net>

On Tue, 2 Oct 2012, Kees Cook wrote:

> In the paranoid case of sysctl kernel.kptr_restrict=2, mask the kernel
> virtual addresses in /proc/vmallocinfo too.
> 
> Reported-by: Brad Spengler <spender@grsecurity.net>
> Signed-off-by: Kees Cook <keescook@chromium.org>

/proc/vmallocinfo is S_IRUSR, not S_IRUGO, so exactly what are you trying 
to protect?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
