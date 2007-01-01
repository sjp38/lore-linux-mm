Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id l016x2od026987
	for <linux-mm@kvack.org>; Mon, 1 Jan 2007 06:59:02 GMT
Received: from nf-out-0910.google.com (nfec2.prod.google.com [10.48.155.2])
	by spaceape10.eur.corp.google.com with ESMTP id l016wx5f007819
	for <linux-mm@kvack.org>; Mon, 1 Jan 2007 06:58:59 GMT
Received: by nf-out-0910.google.com with SMTP id c2so6450614nfe
        for <linux-mm@kvack.org>; Sun, 31 Dec 2006 22:58:59 -0800 (PST)
Message-ID: <65dd6fd50612312258i3bea1928m3d06c04fdbb5a7c@mail.gmail.com>
Date: Sun, 31 Dec 2006 22:58:59 -0800
From: "Ollie Wild" <aaw@google.com>
Subject: Re: [patch] remove MAX_ARG_PAGES
In-Reply-To: <20061229200357.GA5940@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <65dd6fd50610101705t3db93a72sc0847cd120aa05d3@mail.gmail.com>
	 <1160572460.2006.79.camel@taijtu>
	 <65dd6fd50610111448q7ff210e1nb5f14917c311c8d4@mail.gmail.com>
	 <65dd6fd50610241048h24af39d9ob49c3816dfe1ca64@mail.gmail.com>
	 <20061229200357.GA5940@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, Linus Torvalds <torvalds@osdl.org>, Arjan van de Ven <arjan@infradead.org>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Andi Kleen <ak@muc.de>, linux-arch@vger.kernel.org, David Howells <dhowells@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

On 12/29/06, Ingo Molnar <mingo@elte.hu> wrote:
>
> what is keeping this fix from going upstream?
>

There are still a couple outstanding issues which need to be resolved
before this is ready for inclusion in the mainline kernel.

The main one is support for CONFIG_STACK_GROWSUP, which I think is
just parisc.  I've been meaning to look into this for a while, but I
was out of commision for most of November so it got punted to the back
burner.  I'll try to revisit it soonish.  If someone from the
parisc-linux list wants to take a look, though, that's fine by me.

The other is support for the various executable formats.  I've tested
elf and script pretty thoroughly, but I'm not sure how to go about
testing most of the others -- does anyone use aout anymore?  Maybe the
solution is just to check it in and wait to see if someone complains.

Ollie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
