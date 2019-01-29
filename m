Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	PLING_QUERY,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E968C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 13:16:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B5AB20880
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 13:16:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="f061IAuH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B5AB20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D4FE8E0002; Tue, 29 Jan 2019 08:16:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0858D8E0001; Tue, 29 Jan 2019 08:16:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB54D8E0002; Tue, 29 Jan 2019 08:16:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id C3C138E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:16:57 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id b14so15705528itd.1
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 05:16:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=IkoDHTcoQExAmP/zAYGRu0okBS/vxY+ZLfd6eRLq2ws=;
        b=I7FeULeLW82NsBysvwqZj6rDKrKLusZ/4n+VIltNcntkjJT4XFNX0pFQ7vkZSU6Vha
         TU5rPVqTEAkEcn79ESUfDrSAJcWpNUq/kKrBsuElgHfKYeimiZFprQy4xLy0rGXph4Ek
         z1nUjqknK3eJM2v66+skh+Io9vnxWe1fJYTNu5aEPd/tvhkEbf67qFNyoRAMsQCKT4nl
         5J+L8D1PA6vjhIMOAOL9Aa/N6nhUj4bDoNno80i9fM/KJHaENMH0GwlFM660tMFF15Qg
         b/TJoBBUlAe2j8ESwjcH8PMNOBE/0sVTxzM3+WhzxdccIN1EUysxHZKY6Neii+QWinXA
         WZxA==
X-Gm-Message-State: AHQUAub2v7d+TWKJRUZgNf5Uv77yaeFLdRjJjuJtI5N0FcUKbDOGV32k
	EZRxjN3dEniBG74FEFIhttykj/bEYM49spUerPNdsRae6cRH1gx0WfDe+z6DrUk8kbk5coFawXl
	Ms8D7ngZOn/NEp0abNCUFND4xwxlSM4tO7NjUvUQLwA63gP1jX+lQgOXVTdfHrgd2nFOJXafwYR
	0WH0xYyg9308ew0dCUC6EuV6QFhh582YI09IqE/HlfjZz2uFknJahuEQHheRJUiPGI/Nba/99PV
	H/fMe0CPtwCqzxyJ5bnky6GOjSGJ6mIzPVC3hPt8IbTgdv4cJlEjS7BUUucz0mnL6f8F6DKKEq7
	RiRcKjQOwJJDBC6HFKVJ7cO/GuwR2tIxvpLzEolYt2Xl1hPJtWTAWyq7aUsMshTufZBqa7wDMEL
	t
X-Received: by 2002:a6b:156:: with SMTP id 83mr14667786iob.63.1548767817485;
        Tue, 29 Jan 2019 05:16:57 -0800 (PST)
X-Received: by 2002:a6b:156:: with SMTP id 83mr14667759iob.63.1548767816858;
        Tue, 29 Jan 2019 05:16:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548767816; cv=none;
        d=google.com; s=arc-20160816;
        b=TEPEIbtZK+pMvRY01aBetc8vvaTNwU7SVNDPepvAC2Gbai6Ot2TXuFDc4+L2AhQ91W
         HIWH54txPff46QE7PM7VhINOO9jMZ141XQako6xgXItVF2k5/AdPVq+rIN0/7EsS5u9+
         8lNRgqiacijOA8LIFVZupL+dBy0/XyeMpFZbnxuSOdYH8Hup31j0+AevEJKTwBZp0XLn
         NYD6fyTjw18SX6tHC9iX2GankNSq+w9JBTy/Mi04BM6udRFFFDziTkUKK8GwVQlCmWFb
         cZlhFS0utDYzKFBoAioT3KAHzN/BD095LnW8bk5QwRd0vsrx2n3VoVXbXchf3yzkAJk0
         W4Qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=IkoDHTcoQExAmP/zAYGRu0okBS/vxY+ZLfd6eRLq2ws=;
        b=qGEKIZfuNaZzg8dk8ww1ecmZSatX5zn9xEzdPZOdvEBiwU7943ukzVdDgfQFBn/VWd
         BxtzMmoGkrFhJhLwrtXgj51xAQLIAnlAOFJq5Vk2klpX4NtNT1meUU8W094I39/cVH3e
         bffE/VFNM2eZ/WzqF+oWvEMdjhqwu2qSeRWyf91ZgP85BztYGGtlqxnuN8KKNsdGLdH+
         sniqo1CO2FiYypLYh60AwTspIxlxWQ4lDVFJoz4G8OluIDFhJrl4HqLAjKYgJykZNE2h
         a+hF98z8EqRWfNodVrPcF/mI+vWczY+p2tbxfNy7j0PNhuKCLQYjBMn1dqdUTvCcuHZH
         0YKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=f061IAuH;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 73sor4008361itv.7.2019.01.29.05.16.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Jan 2019 05:16:56 -0800 (PST)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=f061IAuH;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=IkoDHTcoQExAmP/zAYGRu0okBS/vxY+ZLfd6eRLq2ws=;
        b=f061IAuHSK40I6nwWINrYYQYRCskJ9MACDwUkTWtcLX1aQvOTh17RYGlMImOEtf+Dd
         acKrpU8urBDqKrja8BBPGU/+nT6RVfROPCxwCZimgWsUrKreBe5PqpstY3NI800dTk+B
         xGYZymOzfSWs2UXdEK/ekgexvdqxH4+1Wk//UTa9dtBFpo0iAjzUhnRSykfnS7uBhbnN
         xG7r2zSbXB99vdr3zYuyP6yFz7OtwCKcvffIm3rA1PDQ7gmGm4e80jifZc0GNTJxN1as
         DApyhr7QFfWnC1NyvEwujhryzwldweuPn5V6sbbYfUgf4p8zP9/hJE35p67u0XSBY3hb
         GzwA==
X-Google-Smtp-Source: ALg8bN6HUj/A2UU9bghOpcHs1qK2Z+MApKf0C4wuxVMRcYDAospR59LbC5gWi/li/WD2y0jw96rJ6UbiFVPgZsFKDXE=
X-Received: by 2002:a05:660c:f94:: with SMTP id x20mr11173972itl.144.1548767816077;
 Tue, 29 Jan 2019 05:16:56 -0800 (PST)
MIME-Version: 1.0
References: <CAKcZhuW-ozJp-MVU3gw=uhuSc9+HTMVJza8QRUL3TaRrbqjJew@mail.gmail.com>
 <CACT4Y+aJADsj37Y8jPAV7PASqKm_L-iJ=MDv68yPUO0TFvhdRg@mail.gmail.com>
 <CACT4Y+ZxgzdbCeFquYmKThfiTGg3pZhn90X_Fk3yRXGYfepU4Q@mail.gmail.com>
 <CAKcZhuWE_2+D_AP_U0XZP-bjb=8Eec1Ku3KD8qO8K0zDGo98Ow@mail.gmail.com>
 <CACT4Y+Ye+0bBV5sB1F3wVbCC1guyA=RdsRnYHgrar=AhftGtQA@mail.gmail.com> <20190121175842.0f526757@vmware.local.home>
In-Reply-To: <20190121175842.0f526757@vmware.local.home>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 29 Jan 2019 14:16:43 +0100
Message-ID: <CACT4Y+Y7PJ1=dv6wzDTVRkFJCnrtDYyksmYp6UibW9a8_ob0Nw@mail.gmail.com>
Subject: Re: [RESEND BUG REPORT] System hung! Due to ftrace or KASAN?
To: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Zenghui Yu <zenghuiyu96@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	"H. Peter Anvin" <hpa@zytor.com>, "the arch/x86 maintainers" <x86@kernel.org>, linux-trace-devel@vger.kernel.org, 
	kasan-dev <kasan-dev@googlegroups.com>, 
	"open list:KERNEL BUILD + fi..." <linux-kbuild@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Andrey Konovalov <andreyknvl@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Mark Rutland <mark.rutland@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Steven Rostedt <rostedt@goodmis.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 1:27 AM Andrew Morton <akpm@linux-foundation.org> wrote:
>
> On Mon, 21 Jan 2019 10:36:25 +0100 Dmitry Vyukov <dvyukov@google.com> wrote:
>
> > > Thanks Dmitry! I'll try to test this commit tomorrow.
> > >
> > > BTW, I have bisect-ed and tested for this issue today. Finally it turned out
> > > that
> > >         bffa986c6f80e39d9903015fc7d0d99a66bbf559 is the first bad commit.
> > > So I'm wondering if anywhere need to be fixed in commit bffa986c6f80 ("kasan:
> > > move common generic and tag-based code to common.c").
> >
> > Thanks for bisecting. I think we have understanding of what happens
> > here and it's exactly this that needs to be fixed:
> > https://groups.google.com/d/msg/kasan-dev/g8A8PLKCyoE/vXnirYEnCAAJ
> > And this commit already fixes it.
>
> Has that been sent in my direction?  I can't find it.
>
> If sending it please add
>
> Tested-by: Dmitry Vyukov <dvyukov@google.com>
> Acked-by: Steven Rostedt (VMware) <rostedt@goodmis.org>


Yes, it's here (State: New):
https://lore.kernel.org/patchwork/patch/1024393/

This page says it was mailed to linux-mm mailing list too:
https://groups.google.com/forum/#!topic/kasan-dev/g8A8PLKCyoE

But I can't find linux-mm archives here:
http://vger.kernel.org/vger-lists.html

How can I add a tag to an existing change under review? Patchwork does
not show something like "add Tested-by: me tag" to me on the patch
page.

Patchwork shows Todo list on the main page with "Your todo list
contains patches that have been delegated to you". But I don't see an
option to delegate this patch to you either...

