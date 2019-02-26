Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8AC6C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 14:35:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 81F6320C01
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 14:35:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="XRKcLkoJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 81F6320C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23D1C8E0004; Tue, 26 Feb 2019 09:35:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E96C8E0001; Tue, 26 Feb 2019 09:35:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 08A628E0004; Tue, 26 Feb 2019 09:35:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id B164F8E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:35:53 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id n24so9670119pgm.17
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 06:35:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=AUt4iAfRYbk6BwjoCKxvIK1Q45AuJd2RFSG+AdGqGGc=;
        b=LJpN7Rnc8Q/Y8+OPUgHVQqm54+RA3GBEkKY41otNq8iEqRDFoJ2FIDzPcaQiRwMGiN
         sMEDPlHLGvQA/W3IRRGKxln9V9zyGQF3zQdvdTyRY7Tjh4Do0mt2NykAIZre7/UVVjVI
         TphfqH0iVD7P//7DSRI0FPw3Vi8EDcvBVL82kNKr2GMfRwUmV3yt38ak6Cn6Co32DEG7
         5H+zVCJsjq6v9iB0Pl6rhEOpDPSv21bRugdRd5f9WLVvDUL3tWNehG6RznHynrPQnZNK
         Mx5NYvHoHrmrdQ+D4Tzv9VPGvT+dGW+1iSjAumIg901xy422XJOMeGCbhCQAkvwmZv8u
         hgFQ==
X-Gm-Message-State: AHQUAubSkVxidgSTK0rfDLu2dsme/kHmpWrQJnGpiMMagUikizdb9KjX
	2eYubvLpHArNOlLTaMzxYxekSR2jMKaY8vJKn5wTpvQCmX+n+BXa3yjAp8lHvXxSMdpfUCPVb/q
	QeyhM5cPhwcBKyG1Mo9d1d+iqPYVDchdDwONb+/CEQi0VDQ4WzzfTrDAz/gVNGL2jxQA06F6wOB
	ns0EMAiXoINDUPsWPZ+4tKY1ra536kq08+3NaTFEQDV3nip1reDoeIC7iPLoaFDSg3OmJyP/P6q
	4NavpJTxk9ucEVCQor7rffvjNthzEtfNI2XJV1cnHsh3BlPcOM2D7uIzRXdDlbXD/7sYjvNNjju
	4zXyqy6tyWGeFD8lEreaI9Au52vW++C8qn3BuEap7coYMvBPelLeSFY+zUAbM0w600+t7KPF859
	d
X-Received: by 2002:a63:6e8d:: with SMTP id j135mr22602pgc.160.1551191753334;
        Tue, 26 Feb 2019 06:35:53 -0800 (PST)
X-Received: by 2002:a63:6e8d:: with SMTP id j135mr22543pgc.160.1551191752426;
        Tue, 26 Feb 2019 06:35:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551191752; cv=none;
        d=google.com; s=arc-20160816;
        b=j8NqG8sMc61CQMn7OUgpLStzM5p82vC0wyWGaI0V9NEjP0482mFjZO1S2c67S00Mdb
         lnSHcyZDt7FBdAqHZYDAFkPpWhA6n77XG1EjeNnRwI43BrVjxO3xvxMWSZb6pvHxy8pg
         SbdKBX1gONcrlsEH6oHhPiRCNp+TMo2ba34lfxs90Uj72dy2USUkdGPRQH0zk7cAJ55i
         H28UZKEorsZLBvkAild1JBJUFiATevT6njOh322/Y1bc65iJ3P4u8xz3F38iIW1+UQcv
         QGJW8Tnqo4zRCsAeS3Cui/tSHrVYBDn7YQm8l5u5sdLT+nkc+2hRmAa6mO2yV4iQxW2Q
         IsXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=AUt4iAfRYbk6BwjoCKxvIK1Q45AuJd2RFSG+AdGqGGc=;
        b=q3rR6tllgSIF7NUp21zelSHU3tDWk7WDCT+28YAiRl5EEPMKGaNkHGJh+95/5XcO0o
         O9GcT6COLGCpEwm+ntmhxIZRpaxKq+ZbPyzn/fLnMuRsQbN6B5Agq7AUCL2XoDq5y/TZ
         yxF3rwCJHpvG0Fb64xuOw9Eewy+ArMZ9RumzkY5K6RCPL/uQMrG916rEqt43FPmyXAoq
         ETqY/bh27DdO6iF9FxutlBl5U9LPW4zv//JxheTmTIcQcHgnwNgkP0gI9UMK2VUogMpJ
         AUE8cXUD5K7wVdZkq+HoxkBIRudLxtfRUqH+VPKf4YGceaXqVpHmYcuI3Oo1LLUZbKIU
         gJDg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=XRKcLkoJ;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q16sor20600113pfi.33.2019.02.26.06.35.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Feb 2019 06:35:52 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=XRKcLkoJ;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=AUt4iAfRYbk6BwjoCKxvIK1Q45AuJd2RFSG+AdGqGGc=;
        b=XRKcLkoJARsdGGCLNMsEu1Vu8sk3uYCwX73ehOf3+cVLv75cO4w/3UTqMluqhaIGyh
         cCy4xvROzeQSaFXI2Iu8ow09wzrfeUVrM4ZBHYRiwLLWx0shcllKfcDdFKilrD1Kr8Mf
         pLE8gRxiLBO8WSSp7OrsZFKA+euo20XGdvScqo95ZZCUwpBjOnXMacjezDCcsLkt/Mth
         pHEFCvychKIJQf6QLymBizZy5Tzkwkra5iyXKKlgGp2QSjfkxadk85kayKTWgP4jHqma
         lYOKPh4aOy50Vdd3ysijeaTRxrjd48CuRB+UX9PdLo8hQkWNFjb25zGeU7TCq+mn7l5N
         FWRw==
X-Google-Smtp-Source: AHgI3IbiQNlPq53/tUpD5IAq8EfXkU5pkBI8V4LoDzop7lQaXJ2OSriJDpc1tkZELm721YxkXsfJtn4Ts8mziEe1cTs=
X-Received: by 2002:a62:6383:: with SMTP id x125mr25941741pfb.239.1551191751796;
 Tue, 26 Feb 2019 06:35:51 -0800 (PST)
MIME-Version: 1.0
References: <cover.1550839937.git.andreyknvl@google.com> <a958e202cdbe6e1bac8a37b7f3d9881d1b22993d.1550839937.git.andreyknvl@google.com>
 <a38275b0-f6cd-20e1-3c48-544846586a16@intel.com>
In-Reply-To: <a38275b0-f6cd-20e1-3c48-544846586a16@intel.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 26 Feb 2019 15:35:40 +0100
Message-ID: <CAAeHK+wLm7zSUC8dJv3LgdyvpkBN8u_24ene6b91PgM570VWbQ@mail.gmail.com>
Subject: Re: [PATCH v10 06/12] fs, arm64: untag user pointers in copy_mount_options
To: Dave Hansen <dave.hansen@intel.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Feb 23, 2019 at 12:03 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 2/22/19 4:53 AM, Andrey Konovalov wrote:
> > --- a/fs/namespace.c
> > +++ b/fs/namespace.c
> > @@ -2730,7 +2730,7 @@ void *copy_mount_options(const void __user * data)
> >        * the remainder of the page.
> >        */
> >       /* copy_from_user cannot cross TASK_SIZE ! */
> > -     size = TASK_SIZE - (unsigned long)data;
> > +     size = TASK_SIZE - (unsigned long)untagged_addr(data);
> >       if (size > PAGE_SIZE)
> >               size = PAGE_SIZE;
>
> I would have thought that copy_from_user() *is* entirely capable of
> detecting and returning an error in the case that its arguments cross
> TASK_SIZE.  It will fail and return an error, but that's what it's
> supposed to do.
>
> I'd question why this code needs to be doing its own checking in the
> first place.  Is there something subtle going on?

The comment above exact_copy_from_user() states:

Some copy_from_user() implementations do not return the exact number of
bytes remaining to copy on a fault.  But copy_mount_options() requires that.
Note that this function differs from copy_from_user() in that it will oops
on bad values of `to', rather than returning a short copy.

