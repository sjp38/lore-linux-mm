Return-Path: <SRS0=q8/f=WY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFED8C3A5A3
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 01:07:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 70F1F20856
	for <linux-mm@archiver.kernel.org>; Wed, 28 Aug 2019 01:07:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="pVqmtHMR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 70F1F20856
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1F116B0006; Tue, 27 Aug 2019 21:07:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD0806B0008; Tue, 27 Aug 2019 21:07:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C99356B000A; Tue, 27 Aug 2019 21:07:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0058.hostedemail.com [216.40.44.58])
	by kanga.kvack.org (Postfix) with ESMTP id AAF236B0006
	for <linux-mm@kvack.org>; Tue, 27 Aug 2019 21:07:48 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 4EA7E180AD801
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 01:07:48 +0000 (UTC)
X-FDA: 75870049416.01.range77_44184312e7f40
X-HE-Tag: range77_44184312e7f40
X-Filterd-Recvd-Size: 7436
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 28 Aug 2019 01:07:47 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id g4so1122989qtq.7
        for <linux-mm@kvack.org>; Tue, 27 Aug 2019 18:07:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=swyKWCdFIdJtO8JPMoHRDo+8t4IfVauN96cB1sxTR9A=;
        b=pVqmtHMRG20NEOtaXbc9xkIabV73MjCxZ4kk8DC4MW152qTMtD8YMDVDBb15w2tgpp
         EjC/OG0c7ZAQEsRm3grpZ6vmllwpQ8YADMuFVFyxNIWjHsh5jZqV1ZH5PloqqnBR8SuK
         4V2ZFUhZB1USAR649cktJpECErwSk1zmG4/b66fWhTkPo2zxJFptP0GwKbtuy7SVTqT0
         WMVMTBC/MBNaArp30Rneg0rEQwIvmGKHvW7IZd+IpxZoGiVee1RIETFUt2xzgGTnr/LH
         V/KsV0NBE660P/2L9hVp0KsdE4GdX52rqE3ogokLi/eeJf+OkYV8zj50UPYjp3HNKH3R
         1ugg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:subject:from:in-reply-to:date:cc
         :content-transfer-encoding:message-id:references:to;
        bh=swyKWCdFIdJtO8JPMoHRDo+8t4IfVauN96cB1sxTR9A=;
        b=uAc20RE6ANJoS0OkyFxCNzJNo48hqGcINEIpt7ydH2iEjtg3g4Q0L9EvcT8PjW4hH8
         AISWGVy9j1RGW2SRCpmhX6sBDzJ8ypqRZSvBH4lKCbvf2Q+PjZorTf08FWUb8s9EqIIC
         zix42+grpB3Qts6i2ZFXC+BBhulaRV3KOP970z/FSobTnD0TelbOkSelqwpUdr2Uvo1W
         UvtyVR1qut8UH+4UIBXoKanf+lFeaKikJS13PTmJ5NAV/vzIFJkH9DjXOW+gDuh8o8sq
         Cw8qOuKmxDZV7KqcmoS8AkXVhuBcOmVBt89flrqzN0mWIhGtySUF7wHuykQeIeCFyWiH
         y6dw==
X-Gm-Message-State: APjAAAWE6GBn8mhc3XgdRq5Ao1tNrFo28sxWT+jmi2sBCga6rO0WyW4W
	gc7Fjn9RLhme6Qbhlkak6q8yHQ==
X-Google-Smtp-Source: APXvYqyfQo8m7y17h4bRIZhvvcBgdg9k4gYgm5FqehVOsl8ZJQ4f+0i4UOIybK2YhA8XUIlPJTHmUw==
X-Received: by 2002:aed:2fe6:: with SMTP id m93mr1900722qtd.114.1566954467184;
        Tue, 27 Aug 2019 18:07:47 -0700 (PDT)
Received: from qians-mbp.fios-router.home (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id k74sm600020qke.53.2019.08.27.18.07.46
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Aug 2019 18:07:46 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: [PATCH] mm: silence -Woverride-init/initializer-overrides
From: Qian Cai <cai@lca.pw>
In-Reply-To: <CAKwvOdmEZ6ADQyquRYmr+uNFXyZ0wpBZxNCrQnn8qaRZADzjRw@mail.gmail.com>
Date: Tue, 27 Aug 2019 21:07:45 -0400
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 clang-built-linux <clang-built-linux@googlegroups.com>,
 Linux Memory Management List <linux-mm@kvack.org>,
 LKML <linux-kernel@vger.kernel.org>,
 Mark Rutland <mark.rutland@arm.com>,
 Arnd Bergmann <arnd@arndb.de>
Content-Transfer-Encoding: quoted-printable
Message-Id: <3806CFC8-24DF-4CEC-8AFF-98FAF15CFCF6@lca.pw>
References: <1566920867-27453-1-git-send-email-cai@lca.pw>
 <CAKwvOdmEZ6ADQyquRYmr+uNFXyZ0wpBZxNCrQnn8qaRZADzjRw@mail.gmail.com>
To: Nick Desaulniers <ndesaulniers@google.com>
X-Mailer: Apple Mail (2.3445.104.11)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Aug 27, 2019, at 7:25 PM, Nick Desaulniers =
<ndesaulniers@google.com> wrote:
>=20
> On Tue, Aug 27, 2019 at 8:49 AM Qian Cai <cai@lca.pw> wrote:
>>=20
>> When compiling a kernel with W=3D1, there are several of those =
warnings
>> due to arm64 override a field by purpose. Just disable those warnings
>> for both GCC and Clang of this file, so it will help dig "gems" =
hidden
>> in the W=3D1 warnings by reducing some noises.
>>=20
>> mm/init-mm.c:39:2: warning: initializer overrides prior =
initialization
>> of this subobject [-Winitializer-overrides]
>>        INIT_MM_CONTEXT(init_mm)
>>        ^~~~~~~~~~~~~~~~~~~~~~~~
>> ./arch/arm64/include/asm/mmu.h:133:9: note: expanded from macro
>> 'INIT_MM_CONTEXT'
>>        .pgd =3D init_pg_dir,
>>               ^~~~~~~~~~~
>> mm/init-mm.c:30:10: note: previous initialization is here
>>        .pgd            =3D swapper_pg_dir,
>>                          ^~~~~~~~~~~~~~
>>=20
>> Note: there is a side project trying to support explicitly allowing
>> specific initializer overrides in Clang, but there is no guarantee it
>> will happen or not.
>>=20
>> https://github.com/ClangBuiltLinux/linux/issues/639
>>=20
>> Signed-off-by: Qian Cai <cai@lca.pw>
>> ---
>> mm/Makefile | 3 +++
>> 1 file changed, 3 insertions(+)
>>=20
>> diff --git a/mm/Makefile b/mm/Makefile
>> index d0b295c3b764..5a30b8ecdc55 100644
>> --- a/mm/Makefile
>> +++ b/mm/Makefile
>=20
> Hi Qian, thanks for the patch.
> Rather than disable the warning outright, and bury the disabling in a
> directory specific Makefile, why not move it to W=3D2 in
> scripts/Makefile.extrawarn?

It could still be useful to have -Woverride-init/initializer-overrides =
in W=3D1
for people only running W=3D1 to catch some real developer mistakes. W=3D2=

might be too noisy to start with.

>=20
>=20
> I think even better would be to use pragma's to disable the warning in
> mm/init.c.  Looks like __diag support was never ported for clang yet
> from include/linux/compiler-gcc.h to include/linux/compiler-clang.h.
>=20
> Then you could do:
>=20
> 28 struct mm_struct init_mm =3D {
> 29   .mm_rb    =3D RB_ROOT,
> 30   .pgd    =3D swapper_pg_dir,
> 31   .mm_users =3D ATOMIC_INIT(2),
> 32   .mm_count =3D ATOMIC_INIT(1),
> 33   .mmap_sem =3D __RWSEM_INITIALIZER(init_mm.mmap_sem),
> 34   .page_table_lock =3D
> __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
> 35   .arg_lock =3D  __SPIN_LOCK_UNLOCKED(init_mm.arg_lock),
> 36   .mmlist   =3D LIST_HEAD_INIT(init_mm.mmlist),
> 37   .user_ns  =3D &init_user_ns,
> 38   .cpu_bitmap =3D { [BITS_TO_LONGS(NR_CPUS)] =3D 0},
> __diag_push();
> __diag_ignore(CLANG, 4, "-Winitializer-overrides")
> 39   INIT_MM_CONTEXT(init_mm)
> __diag_pop();
> 40 };

The pragma might be fine for Clang, although it seems a bit overkill.
Then, it needs to add something for GCC=E2=80=99s "override-init" as =
well.
If that mm_init.c grows in the future to have more structs, it may =
become
more desirable to use =E2=80=9Cpragma=E2=80=9D to only disable this =
particular struct.

>=20
> I mean, the arm64 case is not a bug, but I worry about turning this
> warning off.  I'd expect it to only warn once during an arm64 build,
> so does the warning really detract from "W=3D1 gem finding?=E2=80=9D

I am running this every day and seeing this every time, so definitely
appreciate disabling it in the kernel itself if not adding too much work
for maintainers. See the end of this file for my current filtering,

https://github.com/cailca/linux-mm/blob/master/compile.sh

>=20
>> @@ -21,6 +21,9 @@ KCOV_INSTRUMENT_memcontrol.o :=3D n
>> KCOV_INSTRUMENT_mmzone.o :=3D n
>> KCOV_INSTRUMENT_vmstat.o :=3D n
>>=20
>> +CFLAGS_init-mm.o +=3D $(call cc-disable-warning, override-init)
>=20
> -Woverride-init isn't mentioned in the commit message, so not sure if
> it's meant to ride along?

Yes, I did also mention GCC will also warn those (from -Woverride-init) =
but
did not include in the warning output which seems redundant.


