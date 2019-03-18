Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75421C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 11:28:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95F4220857
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 11:27:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b="EMLYXOkv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95F4220857
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=szeredi.hu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E44F96B0003; Mon, 18 Mar 2019 07:27:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCD7C6B0006; Mon, 18 Mar 2019 07:27:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C6E666B0007; Mon, 18 Mar 2019 07:27:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id A24056B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 07:27:58 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id w11so13216390iom.20
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 04:27:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=LAxJSbEYYlHpAgb4zWs+vz96bKyE9c3o0yiZpnj27Cw=;
        b=e5UAa7NyPaR/CEP4VYREv/OxjHbBcQSv0zsYeODpwh+u4IDRPrdSUtYLYCGIECOPGc
         Vx6fzRIh/4mAwZowqr8MRvMCBO854m0Cy82c+tzJVfrhlmsJ8xQtQ/xu6lwVyFYv0+iR
         a7tuQhEIPSXisvGQZ84JPyOGPzjQD5Z32ORtBKMIpJaIK0nWiXm8nbPAUbYxlrUuba3M
         3eQwh//rXsCAikLZVHHMJ/vGcizWxUa4+2UU6kW+mbml5LNzKr34vV0HsE0PaARErhZk
         bJd5r0KJu48MbRM3C0cllGTAKZIm5qOgqGj8YY69KXaW1Dei0a5Lo7VQIq7iBEviC7JT
         b3gA==
X-Gm-Message-State: APjAAAX+2LEuZBX/k4s4st2DmRNHlIDdGNO4xJVee1t5inNj3dMHTCOT
	m94EYqi9Q2RLfBYGWKa1NM9wgkc2GgRF8QxY0oSMcrRAeBMSIGZnqj5N1Uo9cDPt3D+iXN5tkx5
	jeTmPtqBosoOccOszEqovYh97iNqEgnyjeHEqRDQJKhU0UIYn2boQWbC1ydCkkd8MFg==
X-Received: by 2002:a02:2a83:: with SMTP id w125mr10735430jaw.44.1552908478406;
        Mon, 18 Mar 2019 04:27:58 -0700 (PDT)
X-Received: by 2002:a02:2a83:: with SMTP id w125mr10735399jaw.44.1552908477426;
        Mon, 18 Mar 2019 04:27:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552908477; cv=none;
        d=google.com; s=arc-20160816;
        b=E5pf5XXiaNp4/9lr4FhZ8BYr3xEXrhARbjjcGy0U+Cv5bAjvFun0ORvZCsxeuJWybP
         81yQeKMDTYMsdsllRJf1eprQGr7Sv3B5TstLxSm079cRCwTAtBKBxJNofwTqQF8eu8uU
         te57AJkgvAImFSFLoQQUF1oIwxbEPgHTJwu8Pk+oW5uLa8qLxLFoqkb3ySw8OxIq7BzY
         lrncVpBqpG+kWpgltPSxpoQhwb5R3KmYKaS90l1npbXwPUrTdKUP8J2d7uuRF+ibaoQ7
         bqoNvSW96N4yYsmq0j+HtkGofyLohKCNBVRdvUCsKnMVEpcBh8ONzxf+xOEJbqFEzX2n
         xo6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=LAxJSbEYYlHpAgb4zWs+vz96bKyE9c3o0yiZpnj27Cw=;
        b=yEaDcxv/AImfORMEvqF2kyPlwfqJ+Cb7lVSXlfUobFEpKT5vdbeanU2nN+5/4omqZ/
         c/x/mUkkd4hXG2WkTsw00ZI0RP7T2mDSzAJikOFT5sV4lZK6oj8KrS2RCnhv9kqPasxT
         VrXBBkT0iZUClbZWYVMM8MBibqfYqKlfj0y9Y+19DkU2+GQYaSbP56ZwZyrRcshp/MtZ
         43dyR62nRK6r2THXpCpQ/1Z34KvAnGrsOF6ORSaHJTXxGnmdEG/qVXvbA9ARnb4qeYwU
         BI0kpD8mNGgqZG2ha4TYQokydvwpGfmAOM9HNO2xMT8ST5ErDylHMYcey7hffdKzsc8u
         3Vhw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=temperror (no key for signature) header.i=@szeredi.hu header.s=google header.b=EMLYXOkv;
       spf=pass (google.com: domain of miklos@szeredi.hu designates 209.85.220.65 as permitted sender) smtp.mailfrom=miklos@szeredi.hu
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r12sor5061685ioo.40.2019.03.18.04.27.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 04:27:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of miklos@szeredi.hu designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=temperror (no key for signature) header.i=@szeredi.hu header.s=google header.b=EMLYXOkv;
       spf=pass (google.com: domain of miklos@szeredi.hu designates 209.85.220.65 as permitted sender) smtp.mailfrom=miklos@szeredi.hu
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=szeredi.hu; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=LAxJSbEYYlHpAgb4zWs+vz96bKyE9c3o0yiZpnj27Cw=;
        b=EMLYXOkvvmG9owzeZS/RXXNtDUTeqNA8MQZiipMBgyPYwozQ4owKeLGfmsNFccAZQD
         oWhLjK1AHPsP9XfbZIL/OQsZ0nsuFJi2KhnD+z2ftGwXnhvXleij0TZ4HvgO5WpR77il
         cJcmPlQVzwFjBrGOmjpfSezu5sEXA/nKR5qY4=
X-Google-Smtp-Source: APXvYqx0GnOKrX1DNAveg7cQ7kmElxvpIATuPFGMCFVAOC5LsaYKhw9k80oddoZyuMGX2mLCllvs//8mt7PRzJexfWw=
X-Received: by 2002:a5d:8248:: with SMTP id n8mr10767189ioo.246.1552908476414;
 Mon, 18 Mar 2019 04:27:56 -0700 (PDT)
MIME-Version: 1.0
References: <87o998m0a7.fsf@vostro.rath.org> <CAJfpegtQic0v+9G7ODXEzgUPAGOz+3Ay28uxqbafZGMJdqL-zQ@mail.gmail.com>
 <87ef9omb5f.fsf@vostro.rath.org> <CAJfpegu_qxcaQToDpSmcW_ncLb_mBX6f75RTEn6zbsihqcg=Rw@mail.gmail.com>
 <87ef9nighv.fsf@thinkpad.rath.org> <CAJfpegtiXDgSBWN8MRubpAdJFxy95X21nO_yycCZhpvKLVePRA@mail.gmail.com>
 <87zhs7fbkg.fsf@thinkpad.rath.org> <8736ovcn9q.fsf@vostro.rath.org>
 <CAJfpegvjntcpwDYf3z_3Z1D5Aq=isB3ByP3_QSoG6zx-sxB84w@mail.gmail.com>
 <877ee4vgr4.fsf@vostro.rath.org> <878sy3h7gr.fsf@vostro.rath.org>
 <CAJfpeguCJnGrzCtHREq9d5uV-=g9JBmrX_c===giZB7FxWCcgw@mail.gmail.com>
 <CAJfpegu-QU-A0HORYjcrx3fM5FKGUop0x6k10A526ZV=p0CEuw@mail.gmail.com>
 <87bm2ymgnt.fsf@vostro.rath.org> <CAJfpegu+_Qc1LRJgBAU=4jHPkUGPdYnJBxvSvQ6Lx+1_Dj2R=g@mail.gmail.com>
 <87woliwcov.fsf@vostro.rath.org>
In-Reply-To: <87woliwcov.fsf@vostro.rath.org>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Mon, 18 Mar 2019 12:27:45 +0100
Message-ID: <CAJfpegvRxANs08i+ZjNjzeNd1LUccgj6=khitowD8eurcfs_NQ@mail.gmail.com>
Subject: Re: [fuse-devel] fuse: trying to steal weird page
To: Nikolaus Rath <Nikolaus@rath.org>
Cc: linux-mm@kvack.org
Content-Type: multipart/mixed; boundary="0000000000001b50d805845cae76"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--0000000000001b50d805845cae76
Content-Type: text/plain; charset="UTF-8"

On Fri, Mar 1, 2019 at 9:40 PM Nikolaus Rath <Nikolaus@rath.org> wrote:
>
> On Feb 26 2019, Miklos Szeredi <miklos@szeredi.hu> wrote:
> > On Tue, Feb 26, 2019 at 9:35 PM Nikolaus Rath <Nikolaus@rath.org> wrote:
> >>
> >> [ Moving fuse-devel and linux-fsdevel to Bcc ]
> >>
> >> Hello linux-mm people,
> >>
> >> I am posting this here as advised by Miklos (see below). In short, I
> >> have a workload that reliably produces kernel messages of the form:
> >>
> >> [ 2562.773181] fuse: trying to steal weird page
> >> [ 2562.773187] page=<something> index=<something> flags=17ffffc00000ad, count=1, mapcount=0, mapping= (null)
> >>
> >> What are the implications of this message? Is something activelly going
> >> wrong (aka do I need to worry about data integrity)?
> >
> > Fuse is careful and basically just falls back on page copy, so it
> > definitely shouldn't affect data integrity.
> >
> > The more interesting question is: how can page_cache_pipe_buf_steal()
> > return a dirty page?  The logic in remove_mapping() should prevent
> > that, but something is apparently slipping through...
> >
> >>
> >> Is there something I can do to help debugging (and hopefully fixing)
> >> this?
> >>
> >> This is with kernel 4.18 (from Ubuntu cosmic).
> >
> > One thought: have you tried reproducing with a recent vanilla
> > (non-ubuntu) kernel?
>
> Yes, I can reproduce with e.g. 5.0.0-050000rc8 (from
> https://kernel.ubuntu.com/~kernel-ppa/mainline/v5.0-rc8/). However, here
> the flag value is different:
>
> [  278.183571] fuse: trying to steal weird page
> [  278.183576]   page=000000000aab208c index=14944 flags=17ffffc0000097, count=1, mapcount=0, mapping=          (null)
>
> (but still the same across all messages observed with this kernel so
> far).

Ah, so it's just the PG_waiters flag that is triggering the "weird
page" message.   And it looks like it's okay if PG_waiters remains
set, at least that's what I infer from the comments in
wake_up_page_bit().  Patch attached.

I'm not sure about the Ubuntu one, you should try filing a bug report
with them, I think.

Thanks,
Miklos

--0000000000001b50d805845cae76
Content-Type: text/x-patch; charset="US-ASCII"; 
	name="fuse-allow-pg_waiters-in-stolen-patch.patch"
Content-Disposition: attachment; 
	filename="fuse-allow-pg_waiters-in-stolen-patch.patch"
Content-Transfer-Encoding: base64
Content-ID: <f_jte9hekp0>
X-Attachment-Id: f_jte9hekp0

ZGlmZiAtLWdpdCBhL2ZzL2Z1c2UvZGV2LmMgYi9mcy9mdXNlL2Rldi5jCmluZGV4IDhhNjNlNTI3
ODVlOS4uNzY5NjA1Y2RmMmJkIDEwMDY0NAotLS0gYS9mcy9mdXNlL2Rldi5jCisrKyBiL2ZzL2Z1
c2UvZGV2LmMKQEAgLTkwNSw2ICs5MDUsNyBAQCBzdGF0aWMgaW50IGZ1c2VfY2hlY2tfcGFnZShz
dHJ1Y3QgcGFnZSAqcGFnZSkKIAkgICAgICAgMSA8PCBQR191cHRvZGF0ZSB8CiAJICAgICAgIDEg
PDwgUEdfbHJ1IHwKIAkgICAgICAgMSA8PCBQR19hY3RpdmUgfAorCSAgICAgICAxIDw8IFBHX3dh
aXRlcnMgfAogCSAgICAgICAxIDw8IFBHX3JlY2xhaW0pKSkgewogCQlwcmludGsoS0VSTl9XQVJO
SU5HICJmdXNlOiB0cnlpbmcgdG8gc3RlYWwgd2VpcmQgcGFnZVxuIik7CiAJCXByaW50ayhLRVJO
X1dBUk5JTkcgIiAgcGFnZT0lcCBpbmRleD0lbGkgZmxhZ3M9JTA4bHgsIGNvdW50PSVpLCBtYXBj
b3VudD0laSwgbWFwcGluZz0lcFxuIiwgcGFnZSwgcGFnZS0+aW5kZXgsIHBhZ2UtPmZsYWdzLCBw
YWdlX2NvdW50KHBhZ2UpLCBwYWdlX21hcGNvdW50KHBhZ2UpLCBwYWdlLT5tYXBwaW5nKTsK
--0000000000001b50d805845cae76--

