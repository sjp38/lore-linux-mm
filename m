Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C7C286B006A
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 20:24:57 -0400 (EDT)
Received: by iwn41 with SMTP id 41so1535725iwn.14
        for <linux-mm@kvack.org>; Tue, 05 Oct 2010 17:24:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTik34ZKasZMMpx4wD71k+RPccGLvAi1Cwe5UwZpj@mail.gmail.com>
References: <AANLkTik34ZKasZMMpx4wD71k+RPccGLvAi1Cwe5UwZpj@mail.gmail.com>
Date: Wed, 6 Oct 2010 09:24:56 +0900
Message-ID: <AANLkTimbamyq6TnOVmMOjnG2hNWYwsvqBZ2RRvSTXr+X@mail.gmail.com>
Subject: Re: [PATCH] pramfs: Persistent and protected RAM filesystem
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Marco Stornelli <marco.stornelli@gmail.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-embedded@vger.kernel.org, linux-fsdevel@vger.kernel.org, Tim Bird <tim.bird@am.sony.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello.

On Tue, Oct 5, 2010 at 8:39 PM, Marco Stornelli
<marco.stornelli@gmail.com> wrote:
> Hi all,
>
> after a lot of improvement, test, bug fix and new features, it's the
> moment for third round with the kernel community to submit PRAMFS for
> mainline. First of all, I have to say thanks to Tim Bird and CELF to
> actively support the project.

Good to know.
Thanks for your endless effort. :)

>
> Since the last review (June 2009) a lot of things are changed:
>
> - removed any reference of BKL
> - fixed the endianess for the fs layout
> - added support for extended attributes, ACLs and security labels
> - moved out any pte manipulations from fs and inserted them in mm
> - implemented the new truncate convention
> - fixed problems with 64bit archs
>
> ...and much more. Complete "story" in the ChangeLog inserted in the
> documentation file.
>
> Since the patch is long, you can download and review the patch from
> the project site: http:\\pramfs.sourceforge.net. The patch version is
> 1.2.1 for kernel 2.6.36.
> In addition, in the web site tech page, you can find a lot of
> information about implementation, technical details, benchemarking and
> so on.

If you really want to merge it, you have to divide patch into
individual patches instead of all-at-once patch.
Individual patches should have a description and clear feature to
review more easily.
And still we need all-at-once patch to apply the patch and test easily.

> Regards,
>
> Marco
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
