Subject: Re: 2.5.41-mm1 oops on boot (EIP at kmem_cache_alloc)
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <3DA4543B.A2E5C5B1@digeo.com>
References: <1034177616.1306.180.camel@spc9.esa.lanl.gov>
	<3DA4543B.A2E5C5B1@digeo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 09 Oct 2002 10:25:14 -0600
Message-Id: <1034180714.32404.200.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Andrew Morton <akpm@zip.com.au>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2002-10-09 at 10:07, Andrew Morton wrote:
> Steven Cole wrote:
> > 
> > Greetings,
> > 
> > I got an oops when booting 2.5.41-mm1 on my dual p3.
> 
> Manfred sent through an update - don't know if it will
> fix this though:
> 
> 
[patch snipped]

Yep, that worked.  Thanks.  I also got the same debug message
for mm/slab.c:1374 which I reported for 2.5.41-bk2, plus the usual
set of "bad: scheduling while atomic!" messages on boot up.

Steven

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
