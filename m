Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id DC1FF9000BD
	for <linux-mm@kvack.org>; Mon, 19 Sep 2011 10:47:40 -0400 (EDT)
Received: by eye13 with SMTP id 13so2409948eye.14
        for <linux-mm@kvack.org>; Mon, 19 Sep 2011 07:47:36 -0700 (PDT)
Date: Mon, 19 Sep 2011 18:46:58 +0400
From: Vasiliy Kulikov <segoon@openwall.com>
Subject: Re: [kernel-hardening] Re: [RFC PATCH 2/2] mm: restrict access to
 /proc/slabinfo
Message-ID: <20110919144657.GA5928@albatros>
References: <20110910164001.GA2342@albatros>
 <20110910164134.GA2442@albatros>
 <20110914192744.GC4529@outflux.net>
 <20110918170512.GA2351@albatros>
 <CAOJsxLF8DBEC9o9pSwa6c6pMg8ByFBdsDnzg22P3ucQcP98uzA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAOJsxLF8DBEC9o9pSwa6c6pMg8ByFBdsDnzg22P3ucQcP98uzA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-hardening@lists.openwall.com, Kees Cook <kees@ubuntu.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Rosenberg <drosenberg@vsecurity.com>, Theodore Tso <tytso@mit.edu>, Alan Cox <alan@linux.intel.com>, Jesper Juhl <jj@chaosbits.net>, Linus Torvalds <torvalds@linux-foundation.org>

Hello Pekka,

On Mon, Sep 19, 2011 at 17:30 +0300, Pekka Enberg wrote:
> > On Wed, Sep 14, 2011 at 12:27 -0700, Kees Cook wrote:
> >> On Sat, Sep 10, 2011 at 08:41:34PM +0400, Vasiliy Kulikov wrote:
> >> > Historically /proc/slabinfo has 0444 permissions and is accessible to
> >> > the world.  slabinfo contains rather private information related both to
> >> > the kernel and userspace tasks.  Depending on the situation, it might
> >> > reveal either private information per se or information useful to make
> >> > another targeted attack.  Some examples of what can be learned by
> >> > reading/watching for /proc/slabinfo entries:
> >> > ...
> >> > World readable slabinfo simplifies kernel developers' job of debugging
> >> > kernel bugs (e.g. memleaks), but I believe it does more harm than
> >> > benefits.  For most users 0444 slabinfo is an unreasonable attack vector.
> >> >
> >> > Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
> 
> On Sun, Sep 18, 2011 at 8:05 PM, Vasiliy Kulikov <segoon@openwall.com> wrote:
> >> Haven't had any mass complaints about the 0400 in Ubuntu (sorry Dave!), so
> >> I'm obviously for it.
> >>
> >> Reviewed-by: Kees Cook <kees@ubuntu.com>
> >
> > Looks like the members of the previous slabinfo discussion don't object
> > against the patch now and it got two other Reviewed-by responses.  Can
> > you merge it as-is or should I probably convince someone else?
> 
> We discussed this in March (google for 'Make /proc/slabinfo 0400')

Sure, I've read it and included the link in the patch description :)

> and
> concluded that it's not worth it doesn't really protect from anything

Closing only slabinfo doesn't add any significant protection against
kernel heap exploits per se, no objections here.  

But as said in the desciption, the reason for this patch is not protecting
against exploitation heap bugs.  It is a source of infoleaks of kernel
and userspace activity, which should be forbidden to non-root users.

> and causes harm to developers.

One note: only to _kernel_ developers.  It means it is a strictly
debugging feature, which shouldn't be enabled in the production systems.

Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
