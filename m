Date: Thu, 19 Jun 2008 10:48:15 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Can get_user_pages( ,write=1, force=1, ) result in a read-only
 pte and _count=2?
In-Reply-To: <200806192221.34103.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0806191047490.7815@schroedinger.engr.sgi.com>
References: <20080618164158.GC10062@sgi.com> <Pine.LNX.4.64.0806191209370.7324@blonde.site>
 <200806192207.40838.nickpiggin@yahoo.com.au> <200806192221.34103.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Robin Holt <holt@sgi.com>, Ingo Molnar <mingo@elte.hu>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 19 Jun 2008, Nick Piggin wrote:

> You could always use another page flag, of course ;)

Some are available now. If you are fast you will get one...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
