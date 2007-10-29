Received: by nz-out-0506.google.com with SMTP id s1so1117923nze
        for <linux-mm@kvack.org>; Mon, 29 Oct 2007 01:17:38 -0700 (PDT)
Message-ID: <45a44e480710290117u492dbe82ra6344baf8bb1e370@mail.gmail.com>
Date: Mon, 29 Oct 2007 01:17:37 -0700
From: "Jaya Kumar" <jayakumar.lkml@gmail.com>
Subject: Re: vm_ops.page_mkwrite() fails with vmalloc on 2.6.23
In-Reply-To: <20071029004002.60c7182a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <1193064057.16541.1.camel@matrix>
	 <20071029004002.60c7182a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: stefani@seibold.net, linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 10/29/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Mon, 22 Oct 2007 16:40:57 +0200 Stefani Seibold <stefani@seibold.net> wrote:
> >
> > The problem original occurs with the fb_defio driver (driver/video/fb_defio.c).
> > This driver use the vm_ops.page_mkwrite() handler for tracking the modified pages,
> > which will be in an extra thread handled, to perform the IO and clean and
> > write protect all pages with page_clean().
> >

Hi,

An aside, I just tested that deferred IO works fine on 2.6.22.10/pxa255.

I understood from the thread that PeterZ is looking into page_mkclean
changes which I guess went into 2.6.23. I'm also happy to help in any
way if the way we're doing fb_defio needs to change.

Thanks,
jaya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
