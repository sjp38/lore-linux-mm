From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH 1/2] vmap: cope with vm_unmap_aliases before vmalloc_init()
Date: Thu, 6 Nov 2008 21:41:00 +1100
References: <49010D41.1080305@goop.org> <4911EB5C.4030901@goop.org> <20081106100234.GM4890@elte.hu>
In-Reply-To: <20081106100234.GM4890@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200811062141.01437.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thursday 06 November 2008 21:02, Ingo Molnar wrote:
> * Jeremy Fitzhardinge <jeremy@goop.org> wrote:
> > Jeremy Fitzhardinge wrote:
> >> Xen can end up calling vm_unmap_aliases() before vmalloc_init() has
> >> been called.  In this case its safe to make it a simple no-op.
> >>
> >> Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citrix.com>
> >
> > Ping?  Nick, Ingo: do you want to pick these up, or shall I send them to
> > Linus myself?
>
> i've applied them to tip/core/urgent and will send them to Linus
> unless Nick or Andrew has objections.

Thanks, yeah ack from me on those. I'm generally expecting Andrew to
pick up and merge mm patches, but I guess he wasn't cc'ed this time.
Anyway, if Ingo gets them upstream, that would be fine too.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
