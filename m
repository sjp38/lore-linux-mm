Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80AFDC4CECD
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 21:09:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 28E1620862
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 21:09:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mdJRDVIT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28E1620862
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C979D6B0005; Tue, 17 Sep 2019 17:09:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C481C6B0006; Tue, 17 Sep 2019 17:09:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B37026B0007; Tue, 17 Sep 2019 17:09:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0042.hostedemail.com [216.40.44.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9093F6B0005
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 17:09:14 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 2E9A81B678
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 21:09:14 +0000 (UTC)
X-FDA: 75945653028.06.rail72_5094cb007a51a
X-HE-Tag: rail72_5094cb007a51a
X-Filterd-Recvd-Size: 9231
Received: from mail-ot1-f68.google.com (mail-ot1-f68.google.com [209.85.210.68])
	by imf44.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 21:09:13 +0000 (UTC)
Received: by mail-ot1-f68.google.com with SMTP id z26so4425764oto.1
        for <linux-mm@kvack.org>; Tue, 17 Sep 2019 14:09:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=QdU9BDYRKLYCRbAsHPJh2Gv4jbezARTTYcilC4RNwq0=;
        b=mdJRDVITCzCqTygbuJCcq3TxNY/x6iF7/JlMI1FujZuj7Xc/DZ2g+8pJEgmfxZbNzO
         xaHKTv5lytDY/4XGaashUdDgZQ+NegRRMexM03lUG9/kL175Fu3kRVxnG3AWDrFEUE3R
         AomRL0dJzZGTMmR/7hK7RSlCuNsuM/n9nIEfd95Re89ahqnyKb+AbbVUALRkERS8yGZt
         2bTjhpzxSPr5FJ1i+kC/3a8+BMbojBXpFmXT1xj1PrQY21gj2UL+KKT2NuvDAz+BkfMV
         wzdcTDTnglXiSdlE46iaJ541s34QGoTVEdk08MZbonFIWEik7Gd+BwgCR/7Oor4yGwRM
         QWEA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=QdU9BDYRKLYCRbAsHPJh2Gv4jbezARTTYcilC4RNwq0=;
        b=iuqV4tQUQUqbzqg5OsvpyantV97MSTGjIkY75re1kK1zgZq8dCPL9Yeiu5QpogVt8Z
         avwRs7Oj71xw87lZXCBFOpPjMY6DK2rb8Ya7eD15gmc+dRwyJB5qDPCaK+xCXvFDpF/i
         DOaYZzcdPH7NkIKDonFkNSSA5xT1/8pwTkjwsKIoqZZcLK98oho7JEhoCT9g92QUioqm
         T2Vpt5+ovQEiGhk1EeT4+Et3aCMKDojA3tP+ZBjOvOnOF9m0qEVrGAj6v5Y+dOwJO58w
         twfkpIU1nRDeVEDWNt4hHWAaP96dMGZIFKAsXHBN1onJnC+bgRo6a7XbUO7xccr/uo+C
         IH2w==
X-Gm-Message-State: APjAAAUF48rpmzbqqHT9if8Lrlxka+9/kLQKEnHLODCvsu6R23w5LVFc
	OwPdAb3KO5SFY6UgV1aAuBEe7CVdsa8qgOHp5Ww=
X-Google-Smtp-Source: APXvYqyl4qf+Hxr8C1phgpbRQ9rA5+rr/UzZojA5HAS/2u4758ewu7YKcuz8zrJcSKwTvFRp8EDZRNy7PsUBWruxywM=
X-Received: by 2002:a9d:6f08:: with SMTP id n8mr766360otq.128.1568754552905;
 Tue, 17 Sep 2019 14:09:12 -0700 (PDT)
MIME-Version: 1.0
References: <20190917073444.GA14505@archlinux-threadripper> <fc341ec3-65c7-ee49-eb03-9b069a8170b2@oracle.com>
In-Reply-To: <fc341ec3-65c7-ee49-eb03-9b069a8170b2@oracle.com>
From: =?UTF-8?B?RMOhdmlkIEJvbHZhbnNrw70=?= <david.bolvansky@gmail.com>
Date: Tue, 17 Sep 2019 23:09:01 +0200
Message-ID: <CAOrgDVOqKD3dedVKFXo+JwKAAWaX3f2c3yUyEpm=sRr5Pu2N8g@mail.gmail.com>
Subject: Re: -Wsizeof-array-div in mm/hugetlb.c
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Nathan Chancellor <natechancellor@gmail.com>, Davidlohr Bueso <dave@stgolabs.net>, 
	Nick Desaulniers <ndesaulniers@google.com>, Ilie Halip <ilie.halip@gmail.com>, linux-mm@kvack.org, 
	clang-built-linux@googlegroups.com
Content-Type: multipart/alternative; boundary="000000000000dda51e0592c62109"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000002, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--000000000000dda51e0592c62109
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

You can use extra parens.

size(arr) / (size(int))

ut 17. 9. 2019 o 23:06 Mike Kravetz <mike.kravetz@oracle.com> nap=C3=ADsal(=
a):

> On 9/17/19 12:34 AM, Nathan Chancellor wrote:
> > Hi all,
> >
> > Clang recently added a new diagnostic in r371605, -Wsizeof-array-div,
> > that tries to warn when sizeof(X) / sizeof(Y) does not compute the
> > number of elements in an array X (i.e., sizeof(Y) is wrong). See that
> > commit for more details:
> >
> >
> https://github.com/llvm/llvm-project/commit/3240ad4ced0d3223149b72a4fc2a4=
d9b67589427
> >
> > There is a warning in mm/hugetlb.c in hugetlb_fault_mutex_hash:
> >
> > mm/hugetlb.c:4055:40: warning: expression does not compute the number o=
f
> > elements in this array; element type is 'unsigned long', not 'u32' (aka
> > 'unsigned int') [-Wsizeof-array-div]
> >         hash =3D jhash2((u32 *)&key, sizeof(key)/sizeof(u32), 0);
> >                                           ~~~ ^
> > mm/hugetlb.c:4049:16: note: array 'key' declared here
> >         unsigned long key[2];
> >                       ^
> > 1 warning generated.
> >
> > Should this warning be silenced? What is the reasoning behind having ke=
y
> > be an array of unsigned longs but representing it as an array of u32s?
>
> Well, the second argument to jhash2 is "the number of u32's in the key".
> This is the reason for the sizeof(key)/sizeof(u32) calculation.  It
> certainly
> is not trying to calculate the number of elements in the array as
> suggested by
> the warning.
>
> > Would it be better to avoid the cast and have it just be an array of
> > u32s directly?
>
> I did not write this code, but it is much easier to do the assignments
> (below)
> to build the key if the array is unsigned long as opposed to u32.
>
> struct address_space *mapping;
> pgoff_t idx;
> unsigned long key[2];
>
>         key[0] =3D (unsigned long) mapping;
>         key[1] =3D idx;
>
> > u32s directly? I am not familiar with this code so I may be naive for
> > asking such questions but we'd like to get these warnings cleaned up so
> > that this warning can be useful down the road.
>
> I suppose it would be possible to change 'key' to be something else besid=
es
> an array (such as struct or union) to eliminate the warning.  But, I woul=
d
> prefer to have some type of directive to indicate the code is ok as is.  =
It
> is not trying to calculate the number of elements in the array as suspect=
ed
> by the clang diagnostic.
>
> --
> Mike Kravetz
>

--000000000000dda51e0592c62109
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">You can use extra parens.<div><br></div><div>size(arr) / (=
size(int))</div></div><br><div class=3D"gmail_quote"><div dir=3D"ltr" class=
=3D"gmail_attr">ut 17. 9. 2019 o=C2=A023:06 Mike Kravetz &lt;<a href=3D"mai=
lto:mike.kravetz@oracle.com">mike.kravetz@oracle.com</a>&gt; nap=C3=ADsal(a=
):<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0=
.8ex;border-left:1px solid rgb(204,204,204);padding-left:1ex">On 9/17/19 12=
:34 AM, Nathan Chancellor wrote:<br>
&gt; Hi all,<br>
&gt; <br>
&gt; Clang recently added a new diagnostic in r371605, -Wsizeof-array-div,<=
br>
&gt; that tries to warn when sizeof(X) / sizeof(Y) does not compute the<br>
&gt; number of elements in an array X (i.e., sizeof(Y) is wrong). See that<=
br>
&gt; commit for more details:<br>
&gt; <br>
&gt; <a href=3D"https://github.com/llvm/llvm-project/commit/3240ad4ced0d322=
3149b72a4fc2a4d9b67589427" rel=3D"noreferrer" target=3D"_blank">https://git=
hub.com/llvm/llvm-project/commit/3240ad4ced0d3223149b72a4fc2a4d9b67589427</=
a><br>
&gt; <br>
&gt; There is a warning in mm/hugetlb.c in hugetlb_fault_mutex_hash:<br>
&gt; <br>
&gt; mm/hugetlb.c:4055:40: warning: expression does not compute the number =
of<br>
&gt; elements in this array; element type is &#39;unsigned long&#39;, not &=
#39;u32&#39; (aka<br>
&gt; &#39;unsigned int&#39;) [-Wsizeof-array-div]<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0hash =3D jhash2((u32 *)&amp;key, size=
of(key)/sizeof(u32), 0);<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0~~~ ^<br>
&gt; mm/hugetlb.c:4049:16: note: array &#39;key&#39; declared here<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unsigned long key[2];<br>
&gt;=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0^<br>
&gt; 1 warning generated.<br>
&gt; <br>
&gt; Should this warning be silenced? What is the reasoning behind having k=
ey<br>
&gt; be an array of unsigned longs but representing it as an array of u32s?=
<br>
<br>
Well, the second argument to jhash2 is &quot;the number of u32&#39;s in the=
 key&quot;.<br>
This is the reason for the sizeof(key)/sizeof(u32) calculation.=C2=A0 It ce=
rtainly<br>
is not trying to calculate the number of elements in the array as suggested=
 by<br>
the warning.<br>
<br>
&gt; Would it be better to avoid the cast and have it just be an array of<b=
r>
&gt; u32s directly?<br>
<br>
I did not write this code, but it is much easier to do the assignments (bel=
ow)<br>
to build the key if the array is unsigned long as opposed to u32.<br>
<br>
struct address_space *mapping;<br>
pgoff_t idx;<br>
unsigned long key[2];<br>
<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 key[0] =3D (unsigned long) mapping;<br>
=C2=A0 =C2=A0 =C2=A0 =C2=A0 key[1] =3D idx;<br>
<br>
&gt; u32s directly? I am not familiar with this code so I may be naive for<=
br>
&gt; asking such questions but we&#39;d like to get these warnings cleaned =
up so<br>
&gt; that this warning can be useful down the road.<br>
<br>
I suppose it would be possible to change &#39;key&#39; to be something else=
 besides<br>
an array (such as struct or union) to eliminate the warning.=C2=A0 But, I w=
ould<br>
prefer to have some type of directive to indicate the code is ok as is.=C2=
=A0 It<br>
is not trying to calculate the number of elements in the array as suspected=
<br>
by the clang diagnostic.<br>
<br>
-- <br>
Mike Kravetz<br>
</blockquote></div>

--000000000000dda51e0592c62109--

