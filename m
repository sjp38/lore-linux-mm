Received: by ro-out-1112.google.com with SMTP id o32so2483506rog.11
        for <linux-mm@kvack.org>; Mon, 21 Jan 2008 18:16:38 -0800 (PST)
Message-ID: <9a8748490801211816y4bcd6fefqfb3f2c2af1bbe970@mail.gmail.com>
Date: Tue, 22 Jan 2008 03:16:38 +0100
From: "Jesper Juhl" <jesper.juhl@gmail.com>
Subject: Re: [PATCH -v7 2/2] Update ctime and mtime for memory-mapped files
In-Reply-To: <4df4ef0c0801211807m3c790a2n679f44f3dec6dc9d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <12009619562023-git-send-email-salikhmetov@gmail.com>
	 <12009619584168-git-send-email-salikhmetov@gmail.com>
	 <9a8748490801211740r5c764f6ev9c331479f63ef362@mail.gmail.com>
	 <4df4ef0c0801211751w39d7b9e5ne2e8b788051d3e3a@mail.gmail.com>
	 <4df4ef0c0801211807m3c790a2n679f44f3dec6dc9d@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Salikhmetov <salikhmetov@gmail.com>
Cc: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

On 22/01/2008, Anton Salikhmetov <salikhmetov@gmail.com> wrote:
> 2008/1/22, Anton Salikhmetov <salikhmetov@gmail.com>:
> > 2008/1/22, Jesper Juhl <jesper.juhl@gmail.com>:
> > > Some very pedantic nitpicking below;
> > >
...
>
> By the way, if we're talking "pedantic", then:
>
> >>>
>
> debian:/tmp$ cat c.c
> void f()
> {
>        for (unsigned long i = 0; i < 10; i++)
>                continue;
> }
> debian:/tmp$ gcc -c -pedantic c.c
> c.c: In function 'f':
> c.c:3: error: 'for' loop initial declaration used outside C99 mode
> debian:/tmp$
>

Well, I just wrote the way I'd have writen the loop, I know it's not
the common kernel style.  Just offering my feedback/input :)


-- 
Jesper Juhl <jesper.juhl@gmail.com>
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html
Plain text mails only, please      http://www.expita.com/nomime.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
