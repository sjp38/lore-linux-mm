From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC] Changing VM_PFNMAP assumptions and rules
Date: Mon, 19 Nov 2007 11:17:52 +1100
References: <6934efce0711091115i3f859a00id0b869742029b661@mail.gmail.com> <200711140426.51614.nickpiggin@yahoo.com.au> <6934efce0711161542n1f73d96au7d0bfababd856098@mail.gmail.com>
In-Reply-To: <6934efce0711161542n1f73d96au7d0bfababd856098@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200711191117.52940.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: benh@kernel.crashing.org, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Saturday 17 November 2007 10:42, Jared Hulbert wrote:
> > And because /dev/mem is out of the picture, so is the requirement of
> > mapping pfn_valid() pages without refcounting them. The sketch I gave
> > in the first post *should* be on the right way
> >
> > I can write the patch for you if you like, but if you'd like a shot at
> > it, that would be great!
>
> I haven't tested this yet and this mailer is broken, I'm just hoping
> to get a little visual review.

No comments, other than, it looks good to me and I wouldn't see any
problems in getting it merged if it is able to solve your problems.

VM_MIXEDMAP is not a bad name, either ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
