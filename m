Date: Mon, 16 Feb 2004 16:12:15 -0500 (EST)
From: Zwane Mwaikambo <zwane@linuxpower.ca>
Subject: Re: 2.6.3-rc3-mm1
In-Reply-To: <Pine.LNX.3.96.1040216141554.2146A-100000@gatekeeper.tmr.com>
Message-ID: <Pine.LNX.4.58.0402161610110.11793@montezuma.fsmlabs.com>
References: <Pine.LNX.3.96.1040216141554.2146A-100000@gatekeeper.tmr.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Davidsen <davidsen@tmr.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Feb 2004, Bill Davidsen wrote:

> > I think it was a good change, and was appropriate to 2.5.x.  But for 2.6.x
> > the benefit didn't seem to justify the depth of the change.

Rather unfortunate that allyes didn't fix things.

> And will it be appropriate for 2.7? It really does give a start to
> trimming code you don't want in a small kernel, and would have been nice
> so people could use it for any processor specific additions to 2.6.
>
> Not arguing, but it was a step to improve control of creeping unnecessary
> archetecture support.

Well the -tiny tree has that and a lot more drastic trimmings, Andrew is
there already an arrangement to feed the not so brutal changes to you?

	Zwane
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
