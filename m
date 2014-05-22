Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id B96E06B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 17:03:07 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id c41so3016075eek.31
        for <linux-mm@kvack.org>; Thu, 22 May 2014 14:03:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id x49si2719140eef.23.2014.05.22.14.03.04
        for <linux-mm@kvack.org>;
        Thu, 22 May 2014 14:03:05 -0700 (PDT)
Message-ID: <537e6609.c9630e0a.682e.ffffc1bcSMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 0/4] pagecache scanning with /proc/kpagecache
Date: Thu, 22 May 2014 17:02:39 -0400
In-Reply-To: <537e385d.8764b40a.0a1f.ffffabccSMTPIN_ADDED_BROKEN@mx.google.com>
References: <1400639194-3743-1-git-send-email-n-horiguchi@ah.jp.nec.com> <20140521154250.95bc3520ad8d192d95efe39b@linux-foundation.org> <537d5ee4.4914e00a.5672.ffff85d5SMTPIN_ADDED_BROKEN@mx.google.com> <20140521193336.5df90456.akpm@linux-foundation.org> <CALYGNiMeDtiaA6gfbEYcXbwkuFvTRCLC9KmMOPtopAgGg5b6AA@mail.gmail.com> <20140522103632.GA23680@node.dhcp.inet.fi> <537e385d.8764b40a.0a1f.ffffabccSMTPIN_ADDED_BROKEN@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill@shutemov.name
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, gorcunov@openvz.org

On Thu, May 22, 2014 at 01:47:48PM -0400, Naoya Horiguchi wrote:
...
> > BTW, does everybody happy with mincore() interface? We report 1 there=
 if
> > pte is present, but it doesn't really say much about the page for cas=
es
> > like zero page...
> =

> According to manpage of mincore(2), =

>   mincore()  returns a vector that indicates whether pages of the calli=
ng process's vir=E2=80=90
>   tual memory are resident in core (RAM), and so will not  cause  a  di=
sk  access  (page
>   fault) if referenced.  ...
> =

> so we can assume that the callers want to predict whether they will hav=
e
> page faults. But it depends on whether the access is read or write.
> So I think current mincore() is not enough to do this prediction precis=
ely
> for privately shared pages (including zero page and ksm page).
> Maybe we need a new syscall to solving this problem.

Sorry, this is not correct, we can use upper bits of each vector to
show protection info of page table entry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
