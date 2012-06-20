Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id B72CD6B0062
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 01:01:46 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so6652150ghr.14
        for <linux-mm@kvack.org>; Tue, 19 Jun 2012 22:01:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1339792575-17637-1-git-send-email-kosaki.motohiro@gmail.com>
References: <1339792575-17637-1-git-send-email-kosaki.motohiro@gmail.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Wed, 20 Jun 2012 01:01:25 -0400
Message-ID: <CAHGf_=qmCdfv0jxOqdrHduTgnjPxgBT7oTdhkywSCCRAKu3A-A@mail.gmail.com>
Subject: Re: [PATCH] mm, fadvise: don't return -EINVAL when filesystem has no
 optimization way
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, Eric Wong <normalperson@yhbt.net>

On Fri, Jun 15, 2012 at 4:36 PM,  <kosaki.motohiro@gmail.com> wrote:
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>
> Eric Wong reported his test suite was fail when /tmp is tmpfs.
>
> https://lkml.org/lkml/2012/2/24/479
>
> Current,input check of POSIX_FADV_WILLNEED has two problems.
>
> 1) require a_ops->readpage.
> =A0 But in fact, force_page_cache_readahead() only require
> =A0 a target filesystem has either ->readpage or ->readpages.
> 2) return -EINVAL when filesystem don't have ->readpage.
> =A0 But, posix says, it should be retrieved a hint. Thus fadvise()
> =A0 should return 0 if filesystem has no optimization way.
> =A0 Especially, userland application don't know a filesystem type
> =A0 of TMPDIR directory as Eric pointed out. Then, userland can't
> =A0 avoid this error. We shouldn't encourage to ignore syscall
> =A0 return value.
>
> Thus, this patch change a return value to 0 when filesytem don't
> support readahead.
>
> Cc: linux-mm@kvack.org
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Hillf Danton <dhillf@gmail.com>
> Signed-off-by: Eric Wong <normalperson@yhbt.net>
> Tested-by: Eric Wong <normalperson@yhbt.net>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---

no objection?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
