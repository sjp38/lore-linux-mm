Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id DA8A26B0006
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 19:17:45 -0400 (EDT)
Received: by mail-oa0-f49.google.com with SMTP id j6so1682177oag.8
        for <linux-mm@kvack.org>; Wed, 13 Mar 2013 16:17:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130313231413.GA3265@jtriplet-mobl1>
References: <20130313231413.GA3265@jtriplet-mobl1>
Date: Wed, 13 Mar 2013 16:17:44 -0700
Message-ID: <CAGXu5jJe-XG7jLcx4GCysXQujH2sUdgF-NuLVVeB5TWGUikhxg@mail.gmail.com>
Subject: Re: [PATCH] fs: Don't compile in drop_caches.c when CONFIG_SYSCTL=n
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Ingo Molnar <mingo@kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed, Mar 13, 2013 at 4:14 PM, Josh Triplett <josh@joshtriplett.org> wrote:
> drop_caches.c provides code only invokable via sysctl, so don't compile
> it in when CONFIG_SYSCTL=n.
>
> Signed-off-by: Josh Triplett <josh@joshtriplett.org>

Seems reasonable to me.

Acked-by: Kees Cook <keescook@chromium.org>

-- 
Kees Cook
Chrome OS Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
