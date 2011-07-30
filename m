Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A6B1C6B00EE
	for <linux-mm@kvack.org>; Sat, 30 Jul 2011 14:28:44 -0400 (EDT)
Received: from mail-wy0-f169.google.com (mail-wy0-f169.google.com [74.125.82.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p6UIS7rm002763
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Sat, 30 Jul 2011 11:28:09 -0700
Received: by wyg36 with SMTP id 36so1085454wyg.14
        for <linux-mm@kvack.org>; Sat, 30 Jul 2011 11:28:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1107290145080.3279@tiger>
References: <alpine.DEB.2.00.1107290145080.3279@tiger>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sat, 30 Jul 2011 08:27:47 -1000
Message-ID: <CA+55aFzut1tF6CLAPJUUh2H_7M4wcDpp2+Zb85Lqvofe+3v_jQ@mail.gmail.com>
Subject: Re: [GIT PULL] Lockless SLUB slowpaths for v3.1-rc1
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: cl@linux-foundation.org, akpm@linux-foundation.org, rientjes@google.com, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jul 28, 2011 at 12:47 PM, Pekka Enberg <penberg@kernel.org> wrote:
>
> This pull request has patches to make SLUB slowpaths lockless like we
> already did for the fastpaths. They have been sitting in linux-next for a
> while now and should be fine. David Rientjes reports improved performance:

So I'm not excited about the growth of the data structure, but I'll
pull this. The performance numbers seem to be solid, and dang it, it
is wonderful to finally hear about netperf performance *improvements*
due to slab changes, rather than things getting slower.

And 'struct page' is largely random-access, so the fact that the
growth makes it basically one cacheline in size sounds like a good
thing.

Do we allocate the page map array sufficiently aligned that we
actually don't ever have the case of straddling a cacheline? I didn't
check.

                                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
