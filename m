Date: Tue, 25 Nov 2008 15:43:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH][V4]Make get_user_pages interruptible
Message-Id: <20081125154354.001a6ae0.akpm@linux-foundation.org>
In-Reply-To: <1227605300.1566.17.camel@penberg-laptop>
References: <604427e00811241521t3e75650ft48bc60cdfb16df0e@mail.gmail.com>
	<1227605300.1566.17.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: yinghan@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, menage@google.com, rientjes@google.com, rohitseth@google.com
List-ID: <linux-mm.kvack.org>

On Tue, 25 Nov 2008 11:28:20 +0200
Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> ___You might want to add an explanation why we check both 'tsk' and
> 'current' in either in the patch description or as a comment, though. Or
> just add a link to the mailing list archives in the description or
> something.

As a code comment, I'd suggest.

> > Signed-off-by:	Paul Menage <menage@google.com>
> > Singed-off-by:	Ying Han <yinghan@google.com>
>   ^^^^^^
> 
> I'm sure you have a beautiful singing voice but from legal point of
> view, it's probably better to just sign it off. ;-)

That's my favorite typo.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
