Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6DF619000BD
	for <linux-mm@kvack.org>; Mon, 19 Sep 2011 11:13:15 -0400 (EDT)
Received: by ewy25 with SMTP id 25so948428ewy.14
        for <linux-mm@kvack.org>; Mon, 19 Sep 2011 08:13:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110919144657.GA5928@albatros>
References: <20110910164001.GA2342@albatros>
	<20110910164134.GA2442@albatros>
	<20110914192744.GC4529@outflux.net>
	<20110918170512.GA2351@albatros>
	<CAOJsxLF8DBEC9o9pSwa6c6pMg8ByFBdsDnzg22P3ucQcP98uzA@mail.gmail.com>
	<20110919144657.GA5928@albatros>
Date: Mon, 19 Sep 2011 18:13:12 +0300
Message-ID: <CAOJsxLG8gW=BLOptpULsaAEwTravADKbNbXp5e9Wd7xVEfR9AQ@mail.gmail.com>
Subject: Re: [kernel-hardening] Re: [RFC PATCH 2/2] mm: restrict access to /proc/slabinfo
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-hardening@lists.openwall.com, Kees Cook <kees@ubuntu.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Rosenberg <drosenberg@vsecurity.com>, Theodore Tso <tytso@mit.edu>, Alan Cox <alan@linux.intel.com>, Jesper Juhl <jj@chaosbits.net>, Linus Torvalds <torvalds@linux-foundation.org>

Hi Vasiliy,

On Mon, Sep 19, 2011 at 5:46 PM, Vasiliy Kulikov <segoon@openwall.com> wrot=
e:
>> and
>> concluded that it's not worth it doesn't really protect from anything
>
> Closing only slabinfo doesn't add any significant protection against
> kernel heap exploits per se, no objections here.
>
> But as said in the desciption, the reason for this patch is not protectin=
g
> against exploitation heap bugs. =A0It is a source of infoleaks of kernel
> and userspace activity, which should be forbidden to non-root users.

Last time we discussed this, the 'extra protection' didn't seem to be
significant enough to justify disabling an useful kernel debugging
interface by default.

What's different about the patch now?

>> and causes harm to developers.
>
> One note: only to _kernel_ developers. =A0It means it is a strictly
> debugging feature, which shouldn't be enabled in the production systems.

It's pretty much _the_ interface for debugging kernel memory leaks in
production systems and we ask users for it along with /proc/meminfo
when debugging many memory management related issues. When we
temporarily dropped /proc/slabinfo with the introduction of SLUB, people
complained pretty loudly.

I'd be willing to consider this patch if it's a config option that's not en=
abled
by default; otherwise you need to find someone else to merge the patch.
You can add some nasty warnings to the Kconfig text to scare the users
into enabling it. ;-)

                         Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
