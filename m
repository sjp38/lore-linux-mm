Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EB9016B005A
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 23:09:15 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 5so1695306qwf.44
        for <linux-mm@kvack.org>; Wed, 16 Sep 2009 20:09:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1bc66b163326564dafb5a7dd8959fd56.squirrel@webmail-b.css.fujitsu.com>
References: <2375c9f90909160235m1f052df0qb001f8243ed9291e@mail.gmail.com>
	 <1bc66b163326564dafb5a7dd8959fd56.squirrel@webmail-b.css.fujitsu.com>
Date: Thu, 17 Sep 2009 11:09:17 +0800
Message-ID: <2375c9f90909162009w5cca547ah5df74972694eab09@mail.gmail.com>
Subject: Re: kcore patches (was Re: 2.6.32 -mm merge plans)
From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

2009/9/16 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
> Am=EF=BF=BD+1rico_Wang =E3=81=95=E3=82=93=E3=81=AF=E6=9B=B8=E3=81=8D=E3=
=81=BE=E3=81=97=E3=81=9F=EF=BC=9A
>> On Wed, Sep 16, 2009 at 7:15 AM, Andrew Morton
>> <akpm@linux-foundation.org> wrote:
>>>#kcore-fix-proc-kcores-statst_size.patch: is it right?
>>>kcore-fix-proc-kcores-statst_size.patch
>>
>> Hmm, I think KAMEZAWA Hiroyuki's patchset is a much better fix for this.
>> Hiroyuki?
>>
> Hmm ? My set is not agaisnt "file size" of /proc/kcore.
>
> One problem of this patch is..this makes size of /proc/kcore as 0 bytes.
> Then, objdump cannot read this. (it checks file size.)
> readelf can read this. (it ignores file size.)

Hmm, ok.


>
> I wonder what you mention is.... because we know precise kclist_xxx
> after my series, we can calculate kcore's size in precise by
> get_kcore_size().


Yeah, that is why I think your patchset for kcore can replace this.

>
> It seems /proc's inode->i_size is "static" and we cannot
> provides return value of get_kcore_size() directly. It may need
> some work and should depends on my kclist_xxx patch sets which are not
> in merge candidates. If you can wait, I'll do some work for fixing this
> problem. (but will not be able to merge directly against upstream.)
>
> But for now, we have to use some fixed value....and using above
> patch for 2.6.31 is not very bad.


Just saw your new patchset for this, I will review them.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
