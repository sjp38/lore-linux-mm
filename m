Return-Path: <SRS0=hkLx=PX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64D7FC43387
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 07:28:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1945020868
	for <linux-mm@archiver.kernel.org>; Tue, 15 Jan 2019 07:28:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iTLHNNJp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1945020868
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1DEB8E0004; Tue, 15 Jan 2019 02:28:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A2EA8E0002; Tue, 15 Jan 2019 02:28:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 893418E0004; Tue, 15 Jan 2019 02:28:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5D6DA8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 02:28:32 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id r65so1323485iod.12
        for <linux-mm@kvack.org>; Mon, 14 Jan 2019 23:28:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Ti0B2+GOH1sUCCI3lKmEIHaxROwkZe+iQSCsCALUxmw=;
        b=CR0/VsTL8h5qZ4HWHP5KbmByA6tqQm9vTL6qM06ckICbSv+Y3EwMFx5f6YPSLPXO9i
         dqYh4jrQ+LeDknoTab3jybvjgV/aqK3iDfuHQ2Q+JkPRQZpv9IUeIZWttCkuiqq3Oe4x
         LJjwUbmHOF8gIZwmLNO4E0sgdRL96555dV+iPE4pVfaT6DTfdB38bhxQFosjfHASD+JR
         l9j/68OStNbeTAhiCRFrUfuKtl3RiQ17Uf/uuDmiurV0mNTPEYtfmiAIdEUK5Rw27q6m
         8LyLNPEucqb7QmKAjrs1+c75nQWWdnTqhelgdQri/W8alMzygz+1GVtjloP01c4aIs9H
         dJlA==
X-Gm-Message-State: AJcUukcZ32ESmVln2R8+5L14VeONkKrNHjVFoChhVCLKUNochSfg0aWw
	5Yqx0m88Z9pXoU+4EXRtt4tU4MCqv5HtVICrRRly2scHfVaPtrQ+SQNGS6qRG9UdilzsJ7q5Lnp
	x1uKqtn3yOiYVJhdU/L1r0k45G6UJz3OP4WzPErYWvsLAg6ZLFDt1qS5FO8JoDatur7YQDgw/Tk
	a2IYhgqi5p6zqFsOEWGMV/sdS4fFTW/g/OMWqZ940G/1CqaXOfoJOzV8QiMNCc2/C79gyRW5QO/
	g+uZN7gUtdAzgqGYvwnRa6iMGBUbF9wWjB05J0WnZ6dAD7qfbBH+fP/buteZpmDU9cVAiGyklkd
	DxSlHxGpys+NKT3d/LaCGAyb9yznc9tpT/NEgT26whkZ3qstkefFtquMlLmjlwBwgEIVZUTBGqH
	p
X-Received: by 2002:a5d:948e:: with SMTP id v14mr1173174ioj.191.1547537312124;
        Mon, 14 Jan 2019 23:28:32 -0800 (PST)
X-Received: by 2002:a5d:948e:: with SMTP id v14mr1173155ioj.191.1547537311493;
        Mon, 14 Jan 2019 23:28:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547537311; cv=none;
        d=google.com; s=arc-20160816;
        b=kP8hiUwBflG7BdgAL/QtDSgysX4zAv0xA+bEHGVoT6x8E16HCZale5kTxJ9NNgW7fv
         tQWmCHyK6Kgw9XcHYZZlrxEr/53bUjxHxV/tSE7+KGbUuHbKcqY8q2SVNYIxiVPDTGVQ
         sdRcQ9yJjCaesTgquQnSH13pju9Qup5D2tAgmmLgP4xbkQjMfBkP4DaBHl2fYM5czQZY
         9uxcfP4n++7c83eRbwwG1LdQ2JUtwYHZZqhH4xNvXGmnq4RoDzB7Wo+dbcQpZDl3RlD9
         yd9AftY5Te+bD1svXv01qPfAZ8BQA2uUN34Hpr0bY/uFTSosMUzUovBGU8xS/D1bZrgk
         0N5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Ti0B2+GOH1sUCCI3lKmEIHaxROwkZe+iQSCsCALUxmw=;
        b=Jo9dFHzFKCeETdEiwKo/GFULZEVABR9FplDe/siBTGmhl/LsNvBMEOgWcHgmXQ9+zz
         hBxPqfOasDsZLBtkxZoVT6s31+ECGG5QpXcAq0D0FURFQ0RJ6u8A8t2Nu89cGBOKIXgT
         VG21LseRLrH5MdShn7EB3ULd8WLVtjm0fZe3evWSs96J/99L3cGuEONgsB8YB677AkIY
         Gv10YJ8eFdoQTERBCbgbI8R2vbkMUVxBZhyCqseZgK6om+WIMQHrqHpzPa7Q8zHy18l7
         AOH5O/M+9mO0n+dbDl8LZlowIrFtNvnxG/8WJQMgRaDtEZHM+B4OrjU9OKKkl9so8r5D
         6i9w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iTLHNNJp;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v192sor3949259itb.17.2019.01.14.23.28.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 14 Jan 2019 23:28:31 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iTLHNNJp;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Ti0B2+GOH1sUCCI3lKmEIHaxROwkZe+iQSCsCALUxmw=;
        b=iTLHNNJpov1e6c5j8dhFlI+XgtoGgIqdyCEc4w6GCepOHFHUsg5pNNpynFwlwvb8H7
         mCvbJ97rjNZSKJFNK0vyZoldc8/zD/kqIBjNz21JZ/WIPGAlUYke1Nx+JlS1ouE57sy1
         Q4afFRXT0TAZXtStU74WDQnikYgCVu8V/FtYg5/18q7VhRNsWYXeQUQixTRMg8VVOvrZ
         t8I1lcXx3JwEBA/plyK6aD9bn3N7WT7ewacLoyyZ4gFpEyp941PZgsYusHgBGwHToJoV
         OSmsrFuMwLzwfWOOHm6f3yErYmDMTqiySnD2YRpPhvYpS1Im0WN8LwUY0pnhpPleA0Ei
         qLFQ==
X-Google-Smtp-Source: ALg8bN6DTPPimR34oteI/ijt0sww/halUd6Z0r/NZkQw1Wxqsp7JOKTv6I7qSU4QjHuryU7zvHEybRq8MDNlWOWXqxo=
X-Received: by 2002:a24:414c:: with SMTP id x73mr1674837ita.129.1547537311236;
 Mon, 14 Jan 2019 23:28:31 -0800 (PST)
MIME-Version: 1.0
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
 <1547183577-20309-3-git-send-email-kernelfans@gmail.com> <a5fe4d86-3551-7da8-caca-fdd497ace99f@intel.com>
In-Reply-To: <a5fe4d86-3551-7da8-caca-fdd497ace99f@intel.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 15 Jan 2019 15:28:19 +0800
Message-ID:
 <CAFgQCTsMo9+8m9jxUK5Eax44rsY+a3TBpb4HsUrScJW3OQ18Kw@mail.gmail.com>
Subject: Re: [PATCHv2 2/7] acpi: change the topo of acpi_table_upgrade()
To: Dave Hansen <dave.hansen@intel.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, 
	Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, 
	Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Chao Fan <fanc.fnst@cn.fujitsu.com>, 
	Baoquan He <bhe@redhat.com>, Juergen Gross <jgross@suse.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, x86@kernel.org, 
	linux-acpi@vger.kernel.org, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190115072819.r7dA4k84VgBOXJNnSPvSjafXXrDCcB4iac8HQoQ-MKM@z>

On Tue, Jan 15, 2019 at 7:12 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 1/10/19 9:12 PM, Pingfan Liu wrote:
> > The current acpi_table_upgrade() relies on initrd_start, but this var is
>
> "var" meaning variable?
>
> Could you please go back and try to ensure you spell out all the words
> you are intending to write?  I think "topo" probably means "topology",
> but it's a really odd word to use for changing the arguments of a
> function, so I'm not sure.
>
> There are a couple more of these in this set.
>
Yes. I will do it and fix them in next version.

> > only valid after relocate_initrd(). There is requirement to extract the
> > acpi info from initrd before memblock-allocator can work(see [2/4]), hence
> > acpi_table_upgrade() need to accept the input param directly.
>
> "[2/4]"
>
> It looks like you quickly resent this set without updating the patch
> descriptions.
>
> > diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
> > index 61203ee..84e0a79 100644
> > --- a/drivers/acpi/tables.c
> > +++ b/drivers/acpi/tables.c
> > @@ -471,10 +471,8 @@ static DECLARE_BITMAP(acpi_initrd_installed, NR_ACPI_INITRD_TABLES);
> >
> >  #define MAP_CHUNK_SIZE   (NR_FIX_BTMAPS << PAGE_SHIFT)
> >
> > -void __init acpi_table_upgrade(void)
> > +void __init acpi_table_upgrade(void *data, size_t size)
> >  {
> > -     void *data = (void *)initrd_start;
> > -     size_t size = initrd_end - initrd_start;
> >       int sig, no, table_nr = 0, total_offset = 0;
> >       long offset = 0;
> >       struct acpi_table_header *table;
>
> I know you are just replacing some existing variables, but we have a
> slightly higher standard for naming when you actually have to specify
> arguments to a function.  Can you please give these proper names?
>
OK, I will change it to acpi_table_upgrade(void *initrd, size_t size).

Thanks,
Pingfan

