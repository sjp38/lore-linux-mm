Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8C02FC43218
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 23:21:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D31720859
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 23:21:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XQq46nLU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D31720859
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70BD46B000C; Mon, 10 Jun 2019 19:21:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BD466B0269; Mon, 10 Jun 2019 19:21:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D1816B026B; Mon, 10 Jun 2019 19:21:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 34CF06B000C
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 19:21:30 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id i18so5200602otl.5
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 16:21:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=ZaE9J9S5+4tokzmlUvtvROgLbYm6CbLOjAt2bzs6+ko=;
        b=DlY460GTsHXebAiA9JZZdxVu3kMMcNqQbzR5rPhx2um4iSH8Zf4BEkvcM+CzkJduEl
         npOBVFnZzaSEKWB7NJ3I0PODX2UMG5JDuAs+UlQBA7i/KUECsQncOz1oBjG3zWOYygKs
         UizsCtQ373j/xrmg+nDfXl4uAWQ7pV1X+rpJcYBQGgFlQFGzXKcxOtSyMybi5A0D9lA5
         InBujb3iyr8OKK4WDOV0jJQWb3xXvPG0zY0Cxn6YEW3IwCUAqokVOjJdm3dAwDGg2555
         zVnxEVZbMskLD0pLcUiEeBMuUb2XYmCTbrsRtLFkE6+bQsx8XhNEBbeAEL4kkdAn6GqK
         uqUQ==
X-Gm-Message-State: APjAAAXcOaWas18bsSSlCWoZwF2vQQI2cAL9TKOGnRC0rzey768Fen5k
	7BoIcaHx3CKii6zbqRH/I/ZH3atb9wbLbGnAoX2IGvWrujrBXe20wRk0BojcR3ye28YtMr5VxdO
	kglO1CfbQChBSFdua+LsNtjKrLOoGBBAQvlLEnmZ4LZvQaqHb7XnaFI/dXHJrUNTtEA==
X-Received: by 2002:a05:6830:117:: with SMTP id i23mr798843otp.47.1560208889901;
        Mon, 10 Jun 2019 16:21:29 -0700 (PDT)
X-Received: by 2002:a05:6830:117:: with SMTP id i23mr798815otp.47.1560208889276;
        Mon, 10 Jun 2019 16:21:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560208889; cv=none;
        d=google.com; s=arc-20160816;
        b=jECiC7K/f+n3Ysh9MkunukxYqePd7l4GQFx6kLYmz5QaqTHmKE6ew0B8nUgv2uazsA
         S08mqjAeZKGuQTQT10mab6xT3AEIW2kQuUfFC7TuYm3xQiFS9Vzads+TVAlkB91k2v4h
         7SfCjXxEyqX2vpFcS1o9vFNhPqTcdM8pzd8mjjVQVQ7SaXfUbBVrBjuxoXEADmH5h0/P
         vn0KzCVHMUSAlgSjv6Evft1GZMNGEe++fgMYlMQgJLIPn+ez+BrRcMvm8OsjjHtONS7d
         z8mTjW31vAxlvyRCnuxnHGKN8D50qZ4QFbLaRlle6jFN2l0OowrD4/6AZbDLgcDFfI8O
         Xl9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=ZaE9J9S5+4tokzmlUvtvROgLbYm6CbLOjAt2bzs6+ko=;
        b=AEbOK8TTX13f16ug2iw3nvJ7xJPIho8RsmgHe/00zb4vhUiGb7eN81xORc6IIKHzEL
         nBWnVehexJ4Igab5ZA9lFn1Dxh/X2m2gCmATwODsLmSN6zf678L87d8vnlEuzHQFbqjb
         AcvOJfclAQxPSdpQpDV08MhelwiU+qsuX08uifdTeZHLsqENxvPWl2KIpmqWSH0bj6cm
         XJcjo35czVaKNCzdv4/39lyQ8Qgui1TK5vY7Iyh/YXLoP+D4ctovoAz2lyRSfrS+mtkz
         eaHs2xVekw1wtHyG3rjme1tDPR719hpUwPaalGztDgCJtAHb4C4sIM4FUF0uEPPh/9FK
         FMeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XQq46nLU;
       spf=pass (google.com: domain of hjl.tools@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hjl.tools@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h187sor4324870oib.95.2019.06.10.16.21.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Jun 2019 16:21:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of hjl.tools@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=XQq46nLU;
       spf=pass (google.com: domain of hjl.tools@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hjl.tools@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=ZaE9J9S5+4tokzmlUvtvROgLbYm6CbLOjAt2bzs6+ko=;
        b=XQq46nLUk1w0so/Oo7f4Obzwh/o1q87LWsXwXUYuy18n6wtiBRK2ftGBmxm0auLw3C
         2yYiVAkdcv6+/IVh7X6QrM0UoSGQyitdM1QDCifV12RE9hSZfSNyJQrEQfP2SMg4enWZ
         9LDHi3uZQaqUAoUSQ0q3cxiPm+2hhlnnol/CR7tdZmeUtkO7SxOTVDda6RZ80MibiTWD
         lnM9MHvgLA0qymLGPVIp3eSUnd1KmStoOEVcrMnZzpgJDMBk/K3h1H5rHaQxobmMSEsZ
         7xq5E1OCNHUfIZU9DJSeMtA0aMcMep/1d7coTjVhV//p15VgmmRXrPIBHbhiOyr1iHtd
         A5xA==
X-Google-Smtp-Source: APXvYqzb5bNwl6WsntXoXRG9f925hb0b4zMvZ1roOsKlf05inct+tI9izH6k+IgRME05YsAxf20EyAgYGYpegeQTvhQ=
X-Received: by 2002:aca:c508:: with SMTP id v8mr13855096oif.104.1560208888753;
 Mon, 10 Jun 2019 16:21:28 -0700 (PDT)
MIME-Version: 1.0
References: <20190606200926.4029-1-yu-cheng.yu@intel.com> <20190606200926.4029-4-yu-cheng.yu@intel.com>
 <20190607080832.GT3419@hirez.programming.kicks-ass.net> <aa8a92ef231d512b5c9855ef416db050b5ab59a6.camel@intel.com>
 <20190607174336.GM3436@hirez.programming.kicks-ass.net> <b3de4110-5366-fdc7-a960-71dea543a42f@intel.com>
 <34E0D316-552A-401C-ABAA-5584B5BC98C5@amacapital.net> <7e0b97bf1fbe6ff20653a8e4e147c6285cc5552d.camel@intel.com>
 <25281DB3-FCE4-40C2-BADB-B3B05C5F8DD3@amacapital.net> <e26f7d09376740a5f7e8360fac4805488b2c0a4f.camel@intel.com>
 <3f19582d-78b1-5849-ffd0-53e8ca747c0d@intel.com> <5aa98999b1343f34828414b74261201886ec4591.camel@intel.com>
 <0665416d-9999-b394-df17-f2a5e1408130@intel.com> <5c8727dde9653402eea97bfdd030c479d1e8dd99.camel@intel.com>
 <ac9a20a6-170a-694e-beeb-605a17195034@intel.com> <328275c9b43c06809c9937c83d25126a6e3efcbd.camel@intel.com>
 <92e56b28-0cd4-e3f4-867b-639d9b98b86c@intel.com> <1b961c71d30e31ecb22da2c5401b1a81cb802d86.camel@intel.com>
 <ea5e333f-8cd6-8396-635f-a9dc580d5364@intel.com>
In-Reply-To: <ea5e333f-8cd6-8396-635f-a9dc580d5364@intel.com>
From: "H.J. Lu" <hjl.tools@gmail.com>
Date: Mon, 10 Jun 2019 16:20:52 -0700
Message-ID: <CAMe9rOqLxNxE-gGX9ozX=emW9iQ+gOeUiS3ec5W4jmF6wk6cng@mail.gmail.com>
Subject: Re: [PATCH v7 03/14] x86/cet/ibt: Add IBT legacy code bitmap setup function
To: Dave Hansen <dave.hansen@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, Andy Lutomirski <luto@amacapital.net>, 
	Peter Zijlstra <peterz@infradead.org>, "the arch/x86 maintainers" <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, 
	LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, 
	Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, 
	Balbir Singh <bsingharora@gmail.com>, Borislav Petkov <bp@alien8.de>, 
	Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Eugene Syromiatnikov <esyr@redhat.com>, Florian Weimer <fweimer@redhat.com>, Jann Horn <jannh@google.com>, 
	Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, 
	Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, 
	Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Randy Dunlap <rdunlap@infradead.org>, 
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>, 
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>, Dave Martin <Dave.Martin@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 10, 2019 at 3:59 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> > We then create PR_MARK_CODE_AS_LEGACY.  The kernel will set the bitmap, but it
> > is going to be slow.
>
> Slow compared to what?  We're effectively adding one (quick) system call
> to a path that, today, has at *least* half a dozen syscalls and probably
> a bunch of page faults.  Heck, we can probably avoid the actual page
> fault to populate the bitmap if we're careful.  That alone would put a
> syscall on equal footing with any other approach.  If the bit setting
> crossed a page boundary it would probably win.
>
> > Perhaps we still let the app fill the bitmap?
>
> I think I'd want to see some performance data on it first.

Updating legacy bitmap in user space from kernel requires

long q;

get_user(q, ...);
q |= mask;
put_user(q, ...);

instead of

*p |= mask;

get_user + put_user was quite slow when we tried before.

-- 
H.J.

