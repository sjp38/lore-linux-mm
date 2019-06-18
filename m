Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2304BC31E5B
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 15:31:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BED7B2085A
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 15:31:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BED7B2085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 249AC6B0005; Tue, 18 Jun 2019 11:31:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FA368E0002; Tue, 18 Jun 2019 11:31:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10FDB8E0001; Tue, 18 Jun 2019 11:31:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id E5B406B0005
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 11:31:13 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id h47so12710808qtc.20
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 08:31:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=enVeaDd9KA1FhkBFIcyRHmn1gPk9Dn42G5cz03oOzOw=;
        b=R8OrjsOz5Arww87W/GTbbi7w0+0IzQtfjpQPuppwo0TH9893a5z4tGXbQ3403TyKhL
         S0HEOxSOrwwVinODivwMLuS3DC/MiXNksGGhIzDbH7Q5tYoX7yH6jDzct+2ofo0LSkOf
         xQP2Y99noHUwz2vvUf4rZPhaZhilHRKhamxVEiSPkEb6aeLb9uXIAw761KXgioT84lII
         8V+xD1b9h1EjLQzr9ShMQthAIAbJKriVngYkgXoiskm5GYgiXe1jcHVbENYkBrncnkBK
         J94Q6PGPYPE0xwd8NXRK/GBGQ2GxAnzXK1xfiA34rfpPsqKo9enepfUGPqOTWeOk7Xwk
         bzhA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Gm-Message-State: APjAAAUEHZYs9HanC+s4QdEIEx1Pe5eqgiUrxtiy1zRInZb1pTGvqcul
	5T6BV4syocNOQRSt+4Ya6eBCPdypzv7aOF56D8D6J97zzjN78o/KdL/Pcm8qccwffaSKXJm1F9q
	aYEAHC5Zc549x8Ofkub3myjx93Sk6QJqVRA1f7DU2vgQ3isR8uef7V27l9bTI9wM=
X-Received: by 2002:a37:aa8e:: with SMTP id t136mr28268738qke.222.1560871873702;
        Tue, 18 Jun 2019 08:31:13 -0700 (PDT)
X-Received: by 2002:a37:aa8e:: with SMTP id t136mr28268696qke.222.1560871873223;
        Tue, 18 Jun 2019 08:31:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560871873; cv=none;
        d=google.com; s=arc-20160816;
        b=iTjB6GKDZRDw/E0CgFjCi2ZMBDAUwUgyGlo4Vq6P3v97omOvntx/ZwQD/+I6qfGt4W
         NJJbhMsd1wb0hY91ZPnlluz/7hIEVJc1Br4xGZ15zOkZGmVeHu6IRAebRh3WOyOSywCX
         uGb9RXiPzPsQUFj1ruu+Wa3JMET5RL+h5jJUIvCboFKzU1gyc/DBpf+efZ583PRIKTSU
         zFANo1JWSJGVnSvLdwLTe6zY9fjGbvhxZx6910gEvlssGRvRt4kT+VAYft8vbTgCjJf0
         MPXP0m5Z7uc0pW1e6N0Jh/usRwT+AarVkA45J9xssg428a+ZU8fsMV0YCEQymTCY4NH9
         yoSg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=enVeaDd9KA1FhkBFIcyRHmn1gPk9Dn42G5cz03oOzOw=;
        b=0xOMTMsnI9PYK0Xq80ZSQpvSqA0YzfoZjJUOZGAWjsnOim8njH0fhiyIn8RcjtOE9Q
         r98DVvUcdD+51iF8SfLTKAa7aqImMv/gZvCvJ2g8IBgDClFknhwm/gThLghWhJFOzWrH
         eJ85EEucP9kihwfhKOlrS0GMB04tdID2/+56uf2ebOQrU8uO9/r6DaEVUlTQf2oRfMoL
         HvrpGfoObMzNeybRLH0ed9YOwR4jAJWAAO5cXZqUzBmjKPf2gAnmR9YEzNkXuvpwFts8
         GasXMS/Bs0ugHlQI3xi1T7KN+YNsii+0FukiQxwrWjt4LUlPY9+7lscMDzm8qWqxAYQw
         yMnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w6sor21448993qth.14.2019.06.18.08.31.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Jun 2019 08:31:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of arndbergmann@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=arndbergmann@gmail.com
X-Google-Smtp-Source: APXvYqzapZcyoXvg/K9EJjtdZZMPh8k1zuhs32ixPde8PXyTRUBF8PG/4CP94Bb7WQNtLtRHg8lQle5wZPdwdvBvQuU=
X-Received: by 2002:aed:33a4:: with SMTP id v33mr66076417qtd.18.1560871872815;
 Tue, 18 Jun 2019 08:31:12 -0700 (PDT)
MIME-Version: 1.0
References: <20190618095347.3850490-1-arnd@arndb.de> <5ac26e68-8b75-1b06-eecd-950987550451@virtuozzo.com>
In-Reply-To: <5ac26e68-8b75-1b06-eecd-950987550451@virtuozzo.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 18 Jun 2019 17:30:55 +0200
Message-ID: <CAK8P3a1CAKecyinhzG9Mc7UzZ9U15o6nacbcfSvb4EBSaWvCTw@mail.gmail.com>
Subject: Re: [PATCH] [v2] page flags: prioritize kasan bits over last-cpuid
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, 
	Linux-MM <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, 
	Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Mark Rutland <mark.rutland@arm.com>, 
	Linus Torvalds <torvalds@linux-foundation.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 18, 2019 at 4:30 PM Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
> On 6/18/19 12:53 PM, Arnd Bergmann wrote:
> > ARM64 randdconfig builds regularly run into a build error, especially
> > when NUMA_BALANCING and SPARSEMEM are enabled but not SPARSEMEM_VMEMMAP:
> >
> >  #error "KASAN: not enough bits in page flags for tag"
> >
> > The last-cpuid bits are already contitional on the available space,
> > so the result of the calculation is a bit random on whether they
> > were already left out or not.
> >
> > Adding the kasan tag bits before last-cpuid makes it much more likely
> > to end up with a successful build here, and should be reliable for
> > randconfig at least, as long as that does not randomize NR_CPUS
> > or NODES_SHIFT but uses the defaults.
> >
> > In order for the modified check to not trigger in the x86 vdso32 code
> > where all constants are wrong (building with -m32), enclose all the
> > definitions with an #ifdef.
> >
>
> Why not keep "#error "KASAN: not enough bits in page flags for tag"" under "#ifdef CONFIG_KASAN_SW_TAGS" ?

I think I had meant the #error to leave out the mention of KASAN, as there
might be other reasons for using up all the bits, but then I did not change
it in the end.

Should I remove the "KASAN" word or add the #ifdef when resending?

     Arnd

