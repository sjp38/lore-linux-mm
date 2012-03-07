Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 817766B004A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 05:39:13 -0500 (EST)
Received: by vcbfk14 with SMTP id fk14so6935015vcb.14
        for <linux-mm@kvack.org>; Wed, 07 Mar 2012 02:39:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120307002616.GP13462@redhat.com>
References: <1330594374-13497-1-git-send-email-lliubbo@gmail.com>
	<alpine.LSU.2.00.1203061515470.1292@eggly.anvils>
	<20120307001148.GO13462@redhat.com>
	<20120307002616.GP13462@redhat.com>
Date: Wed, 7 Mar 2012 18:39:12 +0800
Message-ID: <CAA_GA1d1MSQVcW=pabjVj0+oOyC1OzJmyqry-bNvZ=rDeTp--w@mail.gmail.com>
Subject: Re: [PATCH 1/2] ksm: clean up page_trans_compound_anon_split
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, akpm@linux-foundation.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, linux-mm@kvack.org

Hi Andrea,

On Wed, Mar 7, 2012 at 8:26 AM, Andrea Arcangeli <aarcange@redhat.com> wrot=
e:
> On Wed, Mar 07, 2012 at 01:11:48AM +0100, Andrea Arcangeli wrote:
>> (the function was invoked only on compound pages in the first place).
>
> BTW, most certainly I did at some point this change:
>
> - =C2=A0 =C2=A0 =C2=A0 if (page_trans_compound_anon_split(page))
> + =C2=A0 =C2=A0 =C2=A0 if (PageTransCompound(page) && page_trans_compound=
_anon_split(page))
>
> Before doing this change, the "cleaned up" version would have been
> broken.
>

I think this patch may still break the origin meaning.

In case PageTransCompound(page) but !PageAnon(head) after this cleanup,
page_trans_compound_anon_split(page) will return 1 instead of 0 which
will cause following
PageAnon check to a compounded page.

So please just ignore this cleanup. Sorry for my noise.


Hugh,  Thank you for your review also.

--=20
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
