Date: Wed, 23 Oct 2002 08:49:11 +0200 (CEST)
From: Ingo Molnar <mingo@elte.hu>
Reply-To: Ingo Molnar <mingo@elte.hu>
Subject: Re: install_page() lockup
In-Reply-To: <3DB63586.A3D4AC22@digeo.com>
Message-ID: <Pine.LNX.4.44.0210230847190.2334-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Dave McCracken <dmccr@us.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 22 Oct 2002, Andrew Morton wrote:

> Ingo's new patch is using install_page much more than we used to (I
> don't think I've ever run it before), so we're running fairly untested
> codepaths here.

i added install_page() for fremap()'s purposes so i'd be surprised if
anything else used it. I have shared-pte turned off in my tests, will try
with it on as well.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
