Date: Mon, 24 Nov 2003 18:41:58 -0500 (EST)
From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Subject: Re: OOps! was: 2.6.0-test9-mm5
In-Reply-To: <20031124225527.GB1343@mis-mike-wstn.matchmail.com>
Message-ID: <Pine.LNX.4.58.0311241840380.8180@montezuma.fsmlabs.com>
References: <20031121121116.61db0160.akpm@osdl.org>
 <20031124225527.GB1343@mis-mike-wstn.matchmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Fedyk <mfedyk@matchmail.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 24 Nov 2003, Mike Fedyk wrote:

> I'm getting an oops on boot, right after serial is initialised.
>
> Two things it says:
> BAD EIP!
> Trying to kill init!
>
> Yes, I'm using preempt.  I'll try without, and see if that "fixes" the
> problem, and try some other versions, since the last 2.6 booted on this
> machine is 2.6.0-test6-mm4.

Any chance you can capture the oops in it's entirety? It might also be
worth booting with the 'initcall_debug' kernel parameter.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
