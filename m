Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 581EA9000BD
	for <linux-mm@kvack.org>; Mon, 19 Sep 2011 10:30:52 -0400 (EDT)
Received: by gxk2 with SMTP id 2so768123gxk.14
        for <linux-mm@kvack.org>; Mon, 19 Sep 2011 07:30:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110918170512.GA2351@albatros>
References: <20110910164001.GA2342@albatros>
	<20110910164134.GA2442@albatros>
	<20110914192744.GC4529@outflux.net>
	<20110918170512.GA2351@albatros>
Date: Mon, 19 Sep 2011 17:30:49 +0300
Message-ID: <CAOJsxLF8DBEC9o9pSwa6c6pMg8ByFBdsDnzg22P3ucQcP98uzA@mail.gmail.com>
Subject: Re: [kernel-hardening] Re: [RFC PATCH 2/2] mm: restrict access to /proc/slabinfo
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasiliy Kulikov <segoon@openwall.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-hardening@lists.openwall.com, Kees Cook <kees@ubuntu.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Rosenberg <drosenberg@vsecurity.com>, Theodore Tso <tytso@mit.edu>, Alan Cox <alan@linux.intel.com>, Jesper Juhl <jj@chaosbits.net>, Linus Torvalds <torvalds@linux-foundation.org>

> On Wed, Sep 14, 2011 at 12:27 -0700, Kees Cook wrote:
>> On Sat, Sep 10, 2011 at 08:41:34PM +0400, Vasiliy Kulikov wrote:
>> > Historically /proc/slabinfo has 0444 permissions and is accessible to
>> > the world. =A0slabinfo contains rather private information related bot=
h to
>> > the kernel and userspace tasks. =A0Depending on the situation, it migh=
t
>> > reveal either private information per se or information useful to make
>> > another targeted attack. =A0Some examples of what can be learned by
>> > reading/watching for /proc/slabinfo entries:
>> > ...
>> > World readable slabinfo simplifies kernel developers' job of debugging
>> > kernel bugs (e.g. memleaks), but I believe it does more harm than
>> > benefits. =A0For most users 0444 slabinfo is an unreasonable attack ve=
ctor.
>> >
>> > Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>

On Sun, Sep 18, 2011 at 8:05 PM, Vasiliy Kulikov <segoon@openwall.com> wrot=
e:
>> Haven't had any mass complaints about the 0400 in Ubuntu (sorry Dave!), =
so
>> I'm obviously for it.
>>
>> Reviewed-by: Kees Cook <kees@ubuntu.com>
>
> Looks like the members of the previous slabinfo discussion don't object
> against the patch now and it got two other Reviewed-by responses. =A0Can
> you merge it as-is or should I probably convince someone else?

We discussed this in March (google for 'Make /proc/slabinfo 0400') and
concluded that it's not worth it doesn't really protect from anything
and causes harm to developers.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
