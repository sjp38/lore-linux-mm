Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4D9BC04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:07:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AA7E217D7
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 16:07:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="SslTEkbd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AA7E217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A6056B0006; Tue, 21 May 2019 12:07:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 457496B0007; Tue, 21 May 2019 12:07:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 320046B0008; Tue, 21 May 2019 12:07:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 06ACF6B0006
	for <linux-mm@kvack.org>; Tue, 21 May 2019 12:07:51 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id x27so9872813ote.6
        for <linux-mm@kvack.org>; Tue, 21 May 2019 09:07:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Z6DwY5PU6T6VLE2Cxc9SEtMv6vL/0lIxHi6A4Ph2gaM=;
        b=alKcuy6qQsTmYFsQZaitSmVVg0YE5VRMsypO8/wGTKWiighuTqv/ZEvKtBffHc9RwO
         ACg5iQJ/OInpiWOdDFJZUYNyamMEPsgz8jGU/OkEUDk3owHM2dUvdnUGuWyfm0D1JxSV
         yx433FR2rYSE3sdiw5V2DP19wiV7rL4Pr4MM46f5Dr12RiVRfOLVnARlU2VGBWUvwGmw
         Mv+SV/U3M6b1zF23O34wtPcTdlQLyQLeyRFzMBQXinWXB5GEENnc4JvVWC8XI7PB/C63
         ldoD8tcQ8uk62Wj+8N3j3tXP+q2TwzNFcmlaZABMcwOa8zi1KO4Hoa0V/+KBimtmeMtV
         sQCw==
X-Gm-Message-State: APjAAAVvF4ZvQkUNjK1ExIjKN6SoIi7nLHMZeTxo4r5tykM883IwSdsT
	QIhPDmG46JDRhuZ2cnTL297IX6UfEzKklOTdKfhWicK5o9UalaJg+yZrSlzislneHFeBwqBiLO8
	YvwirvEpea1WQA8mlpY84nTKEAOL8KAwDY9BUDaqNu0O76tbPXBcSs+5HaT2gbRjhfg==
X-Received: by 2002:a9d:70d2:: with SMTP id w18mr165706otj.289.1558454870767;
        Tue, 21 May 2019 09:07:50 -0700 (PDT)
X-Received: by 2002:a9d:70d2:: with SMTP id w18mr165669otj.289.1558454870230;
        Tue, 21 May 2019 09:07:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558454870; cv=none;
        d=google.com; s=arc-20160816;
        b=okLb0gC11DtlNmUDp/Xqk37rXtu2XPnqe3SW1JnMdeymiDObdptKpR57dqTQCFc0Gq
         kUx8qGfzpR3ZBQOCFwHl0TreAxDoNbnze/uRN+lY3OdtSdlZWitpx3y7A0UnyVxlkLBr
         NAufVQ5kIurGp1urleqkYig5n7xKgLghusFa6cIoZ1oZsuHKAnCYzhWMeht9QTfrwK6b
         LI5yGI27G6RlG10pRracHYudRCY9y6HwMnqYlCnE4USgWwMHDPZHYy4hMBJCBMuFO4K+
         F9BFU6mLkgEoR9LoYRagbs0c20VEiAZxfHDaztPfa7D6rQOSTTmrZPQAP12WcxSG7iem
         nQMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Z6DwY5PU6T6VLE2Cxc9SEtMv6vL/0lIxHi6A4Ph2gaM=;
        b=QhTxFASDBbHBVPzXocCotaOXMJzjYqpwp7pj196ES0xv/k3YqNNkqxSF6taRlknK9x
         3Ks9JSzsCFmBqw2+qHrWiKcEDWlT2KYLXA52n61WYf20DM7c0zXwQMdylPcLyKx5ypqP
         fcaDGzyJy8tM5EnpTmyeH6wL2/qSSWKAKDL8WvvVXhbNmBvKnocyzl7Fhwt1jTuDGgF4
         10KV5c6cVeycz1YEaLw/D6EvJrJxypTYXoLRDhsMKGPjAIbHLfPzA8i4eIW8VvYgtOZ0
         YebP80OYZSheVBmZZxf0uHWlg0mkRpUAJZ1Ie8ew1sCPS9X4u3Qkv4OVLmj8CQtMgC0u
         /3Hg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=SslTEkbd;
       spf=pass (google.com: domain of elver@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=elver@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l12sor9877336otn.177.2019.05.21.09.07.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 09:07:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of elver@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=SslTEkbd;
       spf=pass (google.com: domain of elver@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=elver@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Z6DwY5PU6T6VLE2Cxc9SEtMv6vL/0lIxHi6A4Ph2gaM=;
        b=SslTEkbdrlh+dYn1Z2W0PtxBFm87izCTK1dQ7tOb865Ax7UFvqpS5sEEsMfHN/jPt4
         ArS1sJ3XSNP/EeAIKaLyVqYC8EiXiubErXlPjLcp+TyxJAnybFh16zALk/7gtxozJ41P
         KzASIrypc+6NtC9XdsGoAw1uMIjWfxQX6Z1RlBG3zDpvdLdxwWGRXiaAU9lXevplUU4q
         zUYpyyWHjMnF+TUT+mvvj0aHcn3/ZAaR/T7k6F8wm+ezWT12bHRSp0ZcoZBjjCUJtmlu
         hE6THKH/921P6gA0xBGqAXuBDU6uh+7eqvIz6hNvFTs+RsExIrG1H79MaOo4k4dkL4kY
         l5+g==
X-Google-Smtp-Source: APXvYqyf0tOjVEyL+KKurLWTQXmmLJuTqu1V19ngBUj4PHyEdLuQ8Dtp7m/dOY8siMci3gIMl1odSi90OcaYYfOkpLw=
X-Received: by 2002:a9d:362:: with SMTP id 89mr6331724otv.17.1558454869448;
 Tue, 21 May 2019 09:07:49 -0700 (PDT)
MIME-Version: 1.0
References: <20190520154751.84763-1-elver@google.com> <ebec4325-f91b-b392-55ed-95dbd36bbb8e@virtuozzo.com>
 <CAG_fn=W+_Ft=g06wtOBgKnpD4UswE_XMXd61jw5ekOH_zeUVOQ@mail.gmail.com>
In-Reply-To: <CAG_fn=W+_Ft=g06wtOBgKnpD4UswE_XMXd61jw5ekOH_zeUVOQ@mail.gmail.com>
From: Marco Elver <elver@google.com>
Date: Tue, 21 May 2019 18:07:37 +0200
Message-ID: <CANpmjNN177XBadNfoSmizQF7uZV61PNPQSftT7hPdc3HmdzSjA@mail.gmail.com>
Subject: Re: [PATCH v2] mm/kasan: Print frame description for stack bugs
To: Alexander Potapenko <glider@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Dmitriy Vyukov <dvyukov@google.com>, 
	Andrey Konovalov <andreyknvl@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, kasan-dev <kasan-dev@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 May 2019 at 17:53, Alexander Potapenko <glider@google.com> wrote:
>
> On Tue, May 21, 2019 at 5:43 PM Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> >
> > On 5/20/19 6:47 PM, Marco Elver wrote:
> >
> > > +static void print_decoded_frame_descr(const char *frame_descr)
> > > +{
> > > +     /*
> > > +      * We need to parse the following string:
> > > +      *    "n alloc_1 alloc_2 ... alloc_n"
> > > +      * where alloc_i looks like
> > > +      *    "offset size len name"
> > > +      * or "offset size len name:line".
> > > +      */
> > > +
> > > +     char token[64];
> > > +     unsigned long num_objects;
> > > +
> > > +     if (!tokenize_frame_descr(&frame_descr, token, sizeof(token),
> > > +                               &num_objects))
> > > +             return;
> > > +
> > > +     pr_err("\n");
> > > +     pr_err("this frame has %lu %s:\n", num_objects,
> > > +            num_objects == 1 ? "object" : "objects");
> > > +
> > > +     while (num_objects--) {
> > > +             unsigned long offset;
> > > +             unsigned long size;
> > > +
> > > +             /* access offset */
> > > +             if (!tokenize_frame_descr(&frame_descr, token, sizeof(token),
> > > +                                       &offset))
> > > +                     return;
> > > +             /* access size */
> > > +             if (!tokenize_frame_descr(&frame_descr, token, sizeof(token),
> > > +                                       &size))
> > > +                     return;
> > > +             /* name length (unused) */
> > > +             if (!tokenize_frame_descr(&frame_descr, NULL, 0, NULL))
> > > +                     return;
> > > +             /* object name */
> > > +             if (!tokenize_frame_descr(&frame_descr, token, sizeof(token),
> > > +                                       NULL))
> > > +                     return;
> > > +
> > > +             /* Strip line number, if it exists. */
> >
> >    Why?

The filename is not included, and I don't think it adds much in terms
of ability to debug; nor is the line number included with all
descriptions. I think, the added complexity of separating the line
number and parsing is not worthwhile here. Alternatively, I could not
pay attention to the line number at all, and leave it as is -- in that
case, some variable names will display as "foo:123".

> >
> > > +             strreplace(token, ':', '\0');
> > > +
> >
> > ...
> >
> > > +
> > > +     aligned_addr = round_down((unsigned long)addr, sizeof(long));
> > > +     mem_ptr = round_down(aligned_addr, KASAN_SHADOW_SCALE_SIZE);
> > > +     shadow_ptr = kasan_mem_to_shadow((void *)aligned_addr);
> > > +     shadow_bottom = kasan_mem_to_shadow(end_of_stack(current));
> > > +
> > > +     while (shadow_ptr >= shadow_bottom && *shadow_ptr != KASAN_STACK_LEFT) {
> > > +             shadow_ptr--;
> > > +             mem_ptr -= KASAN_SHADOW_SCALE_SIZE;
> > > +     }
> > > +
> > > +     while (shadow_ptr >= shadow_bottom && *shadow_ptr == KASAN_STACK_LEFT) {
> > > +             shadow_ptr--;
> > > +             mem_ptr -= KASAN_SHADOW_SCALE_SIZE;
> > > +     }
> > > +
> >
> > I suppose this won't work if stack grows up, which is fine because it grows up only on parisc arch.
> > But "BUILD_BUG_ON(IS_ENABLED(CONFIG_STACK_GROUWSUP))" somewhere wouldn't hurt.
> Note that KASAN was broken on parisc from day 1 because of other
> assumptions on the stack growth direction hardcoded into KASAN
> (e.g. __kasan_unpoison_stack() and __asan_allocas_unpoison()).
> So maybe this BUILD_BUG_ON can be added in a separate patch as it's
> not specific to what Marco is doing here?

Happy to send a follow-up patch, or add here. Let me know what you prefer.

Thanks,
-- Marco

