Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 72C0F6B004D
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 19:48:46 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so5364784ied.14
        for <linux-mm@kvack.org>; Thu, 01 Nov 2012 16:48:45 -0700 (PDT)
Date: Thu, 1 Nov 2012 16:48:41 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: shmem_getpage_gfp VM_BUG_ON triggered. [3.7rc2]
In-Reply-To: <20121101232030.GA25519@redhat.com>
Message-ID: <alpine.LNX.2.00.1211011627120.19567@eggly.anvils>
References: <20121025023738.GA27001@redhat.com> <alpine.LNX.2.00.1210242121410.1697@eggly.anvils> <20121101191052.GA5884@redhat.com> <alpine.LNX.2.00.1211011546090.19377@eggly.anvils> <20121101232030.GA25519@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 1 Nov 2012, Dave Jones wrote:
> On Thu, Nov 01, 2012 at 04:03:40PM -0700, Hugh Dickins wrote:
>  > 
>  > Except... earlier in the thread you explained how you hacked
>  > #define VM_BUG_ON(cond) WARN_ON(cond)
>  > to get this to come out as a warning instead of a bug,
>  > and now it looks as if "a user" has here done the same.
>  > 
>  > Which is very much a user's right, of course; but does
>  > make me wonder whether that user might actually be davej ;)
> 
> indirectly. I made the same change in the Fedora kernel a while ago
> to test a hypothesis that we weren't getting any VM_BUG_ON reports.

Fedora turns on CONFIG_DEBUG_VM?

All mm developers should thank you for the wider testing exposure;
but I'm not so sure that Fedora users should thank you for turning
it on - really it's for mm developers to wrap around !assertions or
more expensive checks (e.g. checking calls) in their development.

Or did I read a few months ago that some change had been made to
such definitions, and VM_BUG_ON(contents) are evaluated even when
the config option is off?  I do hope I'm mistaken on that.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
