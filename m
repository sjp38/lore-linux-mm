Received: by ro-out-1112.google.com with SMTP id o32so2483988rog.11
        for <linux-mm@kvack.org>; Mon, 21 Jan 2008 18:18:59 -0800 (PST)
Message-ID: <9a8748490801211818p6a7c48a2q580bd4aebbdcbe7e@mail.gmail.com>
Date: Tue, 22 Jan 2008 03:18:59 +0100
From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: [PATCH -v7 2/2] Update ctime and mtime for memory-mapped files
In-Reply-To: <4df4ef0c0801211757y1f751bbbv4ce4bbf7455a68c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <12009619562023-git-send-email-salikhmetov@gmail.com>
	 <12009619584168-git-send-email-salikhmetov@gmail.com>
	 <9a8748490801211740r5c764f6ev9c331479f63ef362@mail.gmail.com>
	 <4df4ef0c0801211751w39d7b9e5ne2e8b788051d3e3a@mail.gmail.com>
	 <9a8748490801211754t51cbc65bg20dea2f8cf6d4516@mail.gmail.com>
	 <4df4ef0c0801211757y1f751bbbv4ce4bbf7455a68c@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Salikhmetov <salikhmetov@gmail.com>
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

On 22/01/2008, Anton Salikhmetov <salikhmetov@gmail.com> wrote:
> 2008/1/22, Jesper Juhl <jesper.juhl@gmail.com>:
> > On 22/01/2008, Anton Salikhmetov <salikhmetov@gmail.com> wrote:
> > > 2008/1/22, Jesper Juhl <jesper.juhl@gmail.com>:
> > > > Some very pedantic nitpicking below;
> > > >
> > > > On 22/01/2008, Anton Salikhmetov <salikhmetov@gmail.com> wrote:
> > ...
> > > > > +               if (file && (vma->vm_flags & VM_SHARED)) {
> > > > > +                       if (flags & MS_ASYNC)
> > > > > +                               vma_wrprotect(vma);
> > > > > +                       if (flags & MS_SYNC) {
> > > >
> > > > "else if" ??
> > >
> > > The MS_ASYNC and MS_SYNC flags are mutually exclusive, that is why I
> > > did not use the "else-if" here. Moreover, this function itself checks
> > > that they never come together.
> > >
> >
> > I would say that them being mutually exclusive would be a reason *for*
> > using "else-if" here.
>
> This check is performed by the sys_msync() function itself in its very
> beginning.
>
> We don't need to check it later.
>

Sure, it's just that, to me, using 'else-if' makes it explicit that
the two are mutually exclusive. Using "if (...), if (...)" doesn't.
Maybe it's just me, but I feel that 'else-if' here better shows the
intention...  No big deal.

-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
