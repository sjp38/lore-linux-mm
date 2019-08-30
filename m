Return-Path: <SRS0=hlfI=W2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BF19C3A5A3
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 04:11:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CCC282087F
	for <linux-mm@archiver.kernel.org>; Fri, 30 Aug 2019 04:11:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TCGMafDG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CCC282087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43D426B000A; Fri, 30 Aug 2019 00:11:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3ED246B000C; Fri, 30 Aug 2019 00:11:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DAD86B000D; Fri, 30 Aug 2019 00:11:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0065.hostedemail.com [216.40.44.65])
	by kanga.kvack.org (Postfix) with ESMTP id 0B57E6B000A
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 00:11:11 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id ACAD7181AC9AE
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 04:11:10 +0000 (UTC)
X-FDA: 75877769100.18.patch97_27505f4d03f0b
X-HE-Tag: patch97_27505f4d03f0b
X-Filterd-Recvd-Size: 6928
Received: from mail-wm1-f66.google.com (mail-wm1-f66.google.com [209.85.128.66])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 30 Aug 2019 04:11:09 +0000 (UTC)
Received: by mail-wm1-f66.google.com with SMTP id o184so5884421wme.3
        for <linux-mm@kvack.org>; Thu, 29 Aug 2019 21:11:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:reply-to:from:date:message-id
         :subject:to:cc;
        bh=EzdpqBHFBURqZtpqMz86yppY6L9goi80pSe5/xSwXtU=;
        b=TCGMafDGV40KPc2+AkZEqcuDwEa7xEze4WiCa/yfEroGBVTaTVfSCrVhKhoM8S3wsD
         qBJF/mHmd4gGjBnB135iZLpABxCysDufVbbhyNyROpHJkRJflTokdXTPycQbsBM3FIpN
         Ln9AJ7Fc9Oa257XZ+rl4cmFElbTvE2Zyr+D/zJarSJ9vGtrMxZqY6mtl+pTn37vFzdzR
         AEbg30TX45+bcbH4xwbwsmo7YLf28EUUvv6b6s7sevLXkN+4kC58bSocwdesXEtYBYy+
         tc9mvZWJmSxJn9eBqSEPBh+vBf6DGtIQxDJomPxdLKNXdZK8Sdk46dcKiI9cwCeEqihX
         hlIA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:reply-to
         :from:date:message-id:subject:to:cc;
        bh=EzdpqBHFBURqZtpqMz86yppY6L9goi80pSe5/xSwXtU=;
        b=isWr/I6o4znxSuWrSHjh0OZM1RqQ17H2bA37uMuqi/Gjjh3e7m6Fbe49bGWBdlEjVB
         3MyPEzMsNqhaMmbju+eYr+uU1LOrJ4/Ryglq+TorZWuqfiU4eW58KaT4lvVfNRaH7vH6
         qR6tQraPR+3AM+Dc4Hni46d24hOcvtTRYpEWoYErvtjzHwsqnrLgzBWd9+mjpWZpeYbc
         ooOi/7JNqYhHxf76ZEf5gXkUxoQ6ueSsZ9abYcsH4ou5xhObd4cXXmwYh/UHowSZh4lb
         rNHQF/sLYrPSqfuSBVcI9YZyIufvUQoU8b+t7H1ZTio+NjIGxXP4eAZQe0kfy3Vc+WJT
         6V+Q==
X-Gm-Message-State: APjAAAWOhCl9LSHirYQGXF1gQknU3PVkUWBP9M2F9eifunsWM0m3RDbp
	KRC4WuBleWD7BHte6kzX5S/X97paA/1AOvAS/AE=
X-Google-Smtp-Source: APXvYqzQODrGE115hX6AyOOjmhKJAZ5etXq0AxSfXgroo4468fZ3yfVGVy4BG2ukkYO8P4FUDTk9u4mSj4EBsbaVke4=
X-Received: by 2002:a05:600c:225a:: with SMTP id a26mr16372285wmm.81.1567138268731;
 Thu, 29 Aug 2019 21:11:08 -0700 (PDT)
MIME-Version: 1.0
References: <20190828034012.sBvm81sYK%akpm@linux-foundation.org>
 <8b09d93a-bc42-bd8e-29ee-cd37765f4899@infradead.org> <20190828171923.4sir3sxwsnc2pvjy@treble>
 <57d6ab2e-1bae-dca3-2544-4f6e6a936c3a@infradead.org> <20190828200134.d3lwgyunlpxc6cbn@treble>
 <20190829082445.GM2369@hirez.programming.kicks-ass.net> <20190829233735.yp3mwhg6er353qw5@treble>
In-Reply-To: <20190829233735.yp3mwhg6er353qw5@treble>
Reply-To: sedat.dilek@gmail.com
From: Sedat Dilek <sedat.dilek@gmail.com>
Date: Fri, 30 Aug 2019 06:10:56 +0200
Message-ID: <CA+icZUVEAJziiuuQ2vzzjYbDrzUMVd+-pkJnmJkt8PPQ6szdPQ@mail.gmail.com>
Subject: Re: mmotm 2019-08-27-20-39 uploaded (objtool: xen)
To: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, 
	akpm@linux-foundation.org, broonie@kernel.org, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-next@vger.kernel.org, 
	mhocko@suse.cz, mm-commits@vger.kernel.org, sfr@canb.auug.org.au
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 30, 2019 at 1:38 AM Josh Poimboeuf <jpoimboe@redhat.com> wrote:
>
> On Thu, Aug 29, 2019 at 10:24:45AM +0200, Peter Zijlstra wrote:
> > On Wed, Aug 28, 2019 at 03:01:34PM -0500, Josh Poimboeuf wrote:
> > > On Wed, Aug 28, 2019 at 10:56:25AM -0700, Randy Dunlap wrote:
> > > > >> drivers/xen/gntdev.o: warning: objtool: gntdev_copy()+0x229: call to __ubsan_handle_out_of_bounds() with UACCESS enabled
> > > > >
> > > > > Easy one :-)
> > > > >
> > > > > diff --git a/tools/objtool/check.c b/tools/objtool/check.c
> > > > > index 0c8e17f946cd..6a935ab93149 100644
> > > > > --- a/tools/objtool/check.c
> > > > > +++ b/tools/objtool/check.c
> > > > > @@ -483,6 +483,7 @@ static const char *uaccess_safe_builtin[] = {
> > > > >         "ubsan_type_mismatch_common",
> > > > >         "__ubsan_handle_type_mismatch",
> > > > >         "__ubsan_handle_type_mismatch_v1",
> > > > > +       "__ubsan_handle_out_of_bounds",
> > > > >         /* misc */
> > > > >         "csum_partial_copy_generic",
> > > > >         "__memcpy_mcsafe",
> > > > >
> > > >
> > > >
> > > > then I get this one:
> > > >
> > > > lib/ubsan.o: warning: objtool: __ubsan_handle_out_of_bounds()+0x5d: call to ubsan_prologue() with UACCESS enabled
> > >
> > > And of course I jinxed it by calling it easy.
> > >
> > > Peter, how do you want to handle this?
> > >
> > > Should we just disable UACCESS checking in lib/ubsan.c?
> >
> > No, that is actually unsafe and could break things (as would you patch
> > above).
>
> Oops.  -EFIXINGTOOMANYOBJTOOLISSUESATONCE
>
> > I'm thinking the below patch ought to cure things:
> >
> > ---
> > Subject: x86/uaccess: Don't leak the AC flags into __get_user() argument evalidation
>
> s/evalidation/evaluation
>
> > Identical to __put_user(); the __get_user() argument evalution will too
> > leak UBSAN crud into the __uaccess_begin() / __uaccess_end() region.
> > While uncommon this was observed to happen for:
> >
> >   drivers/xen/gntdev.c: if (__get_user(old_status, batch->status[i]))
> >
> > where UBSAN added array bound checking.
> >
> > This complements commit:
> >
> >   6ae865615fc4 ("x86/uaccess: Dont leak the AC flag into __put_user() argument evaluation")
> >
> > Reported-by: Randy Dunlap <rdunlap@infradead.org>
> > Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> > Cc: luto@kernel.org
> > ---
> >  arch/x86/include/asm/uaccess.h | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> >
> > diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
> > index 9c4435307ff8..35c225ede0e4 100644
> > --- a/arch/x86/include/asm/uaccess.h
> > +++ b/arch/x86/include/asm/uaccess.h
> > @@ -444,8 +444,10 @@ __pu_label:                                                      \
> >  ({                                                                   \
> >       int __gu_err;                                                   \
> >       __inttype(*(ptr)) __gu_val;                                     \
> > +     __typeof__(ptr) __gu_ptr = (ptr);                               \
> > +     __typeof__(size) __gu_size = (size);                            \
> >       __uaccess_begin_nospec();                                       \
> > -     __get_user_size(__gu_val, (ptr), (size), __gu_err, -EFAULT);    \
> > +     __get_user_size(__gu_val, __gu_ptr, __gu_size, __gu_err, -EFAULT);      \
> >       __uaccess_end();                                                \
> >       (x) = (__force __typeof__(*(ptr)))__gu_val;                     \
> >       __builtin_expect(__gu_err, 0);                                  \
>
> Reviewed-by: Josh Poimboeuf <jpoimboe@redhat.com>
>

Tested-by Sedat Dilek <sedat.dilek@gmail.com>

- Sedat -

