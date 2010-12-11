Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E25C96B0088
	for <linux-mm@kvack.org>; Sat, 11 Dec 2010 14:50:24 -0500 (EST)
Message-ID: <4D03D5F8.4010206@newton.leun.net>
Date: Sat, 11 Dec 2010 20:50:16 +0100
From: Michael Leun <vb-contact@newton.leun.net>
MIME-Version: 1.0
Subject: Re: kernel BUG at mm/truncate.c:475!
References: <20101130194945.58962c44@xenia.leun.net>	<alpine.LSU.2.00.1011301453090.12516@tigran.mtv.corp.google.com>	<E1PNjsI-0005Bk-NB@pomaz-ex.szeredi.hu>	<20101201124528.6809c539@xenia.leun.net>	<E1PNqO1-0005px-9h@pomaz-ex.szeredi.hu>	<20101202084159.6bff7355@xenia.leun.net>	<20101202091552.4a63f717@xenia.leun.net>	<E1PO5gh-00079U-Ma@pomaz-ex.szeredi.hu>	<20101202115722.1c00afd5@xenia.leun.net>	<20101203085350.55f94057@xenia.leun.net>	<E1PPaIw-0004pW-Mk@pomaz-ex.szeredi.hu> <20101206204303.1de6277b@xenia.leun.net> <E1PRQDn-0007jZ-5S@pomaz-ex.szeredi.hu>
In-Reply-To: <E1PRQDn-0007jZ-5S@pomaz-ex.szeredi.hu>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Michael Leun <lkml20101129@newton.leun.net>, hughd@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Miklos Szeredi schrieb:
> On Mon, 6 Dec 2010, Michael Leun wrote:
>> At the moment I'm trying to create an easy to reproduce scenario.
>>

To be honest that somewhat sliddered down on my todo-list due to not
much time and kernel_cache worked around that...

> I've managed to reproduce the BUG.

...so I'm very happy you found a way to reproduce yourself.

[...]

> Attached patch attempts to do this without adding more fields to
> struct address_space.  It fixes the bug in my testing.

I'll add this patch on my work machine monday morning (happened for me
only on that quadcore, I realize now...) and turn off kernel_cache
again, of course, and let you know what happens.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
