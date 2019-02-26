Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C100AC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 05:40:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8149D2173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 05:40:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Xk3xGW2b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8149D2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24C508E0004; Tue, 26 Feb 2019 00:40:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FC5B8E0002; Tue, 26 Feb 2019 00:40:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 112818E0004; Tue, 26 Feb 2019 00:40:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id D53F98E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 00:40:27 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id w200so1144265itc.8
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 21:40:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=bIKVYbyUVD0x9jdnyL5+5v/G/5aUpgYhlC/5rQZY9dI=;
        b=kl0HM0OINOIAYnxa7b507EM6ngo4ly8cio0ddq0YICjX2yn7OzfjR6vW59SfVmee7V
         gc0eNRISSPtbxVdMJ432a3ecEj2QaIXAdlcq+AhMiXuB5ssv0+m6mp1DZSnAHd/oZxIZ
         4NgVNHfZHMHA65nJWjiiRI+fRE5DT69rUoorei5+QNn2lFUJmnyIMuvr8fEb98+3g9b/
         m9IbJnpCECJejj8e3mj5LnIai7B9SI9/oFoaiueNjEkl0KsvoaTr5PQqVnEnuLOyc4FF
         BaWlLgXnXagze2tI7U0nAbtIxhN4mvcg3Y/vpwiR2rDmRVKKQfMm5RaIW00gk568oUz/
         VRZw==
X-Gm-Message-State: APjAAAXPgzYhtYbh+2s6K7g0gw8AjxlDxmRHbukyzCC6LERd9bX8Y5jK
	/UJhOuYu9UYlosyPev9jwKzsAEmun5fyuRR+qL2m2NHaGbpxPmY0oGHLd6N3kz450Nx5ptklKzL
	NfV8s59I8CQP0Zx2TJEoMVquLRLA8HALbkrkyarX4F3QlUEWErvvPrZA/IPtEJ8NRgw3Qaazgh2
	xpQ5D0j2touMWtPBqCKJu4vZOTBqy8jG7ky/YOX9jXtMustE0+PQYkyxsNVLWI6KVgFVtQoadHj
	phcGPnHrkEsG7iPU7YC+2YmSKa9+sci1dckQcM2nMFA85pSdKMU2ZF5d6qJu0+51ErIKsqiAvn5
	82N8gc09rHo3pTtNV3EsIfICG49Do5QQFJFyvAa4PbwvFUhvL2doTLsB/KBxxSwa1nON0MM4ghC
	7
X-Received: by 2002:a24:1395:: with SMTP id 143mr1418155itz.32.1551159627544;
        Mon, 25 Feb 2019 21:40:27 -0800 (PST)
X-Received: by 2002:a24:1395:: with SMTP id 143mr1418144itz.32.1551159626857;
        Mon, 25 Feb 2019 21:40:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551159626; cv=none;
        d=google.com; s=arc-20160816;
        b=wcztcoJFNo2rLJIQbIgcx2YeknIH8E200Oyx0I5Xp5cDltcCbJXRnj8AHpuiWC6c0o
         hoboEW2U1Xbo3X8n1BMl2XCl+M+0mqML9iOdXyJtt/5eJjl93MGIl4l+4SxehX9I7j81
         Y2IHxdeYLBn20hehxQRj7rNi7CT+dblkpyDMh3267Rf3a9F5y7y6Jl5Q+3Ta3SJRAv5c
         E9P6AnIgQhw112TtdsL5qZ4+Mggrz0SIHBAQbUQY+2gQjgjRfHmFWNFh2/8J/mmQNyes
         zLFJkDAQfv4fIaRiRdSWhbEzlojPhN3fQz8Az/5v73emGRABdVl2QnHoEzX0iDLtRmKE
         JswA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=bIKVYbyUVD0x9jdnyL5+5v/G/5aUpgYhlC/5rQZY9dI=;
        b=VjWhPvNWa9YvErLn77YsV1EQfOeXTFjmTW9h8GN1/kkxe5ivWEcAkif2TtRZ97Mfgq
         dQdEAC+RUGQFMWoxwfyC5SBnxHptVyN0GZQiOi+WNqqcA/2EJ4ywX6BvQQgPKZO1dxXz
         5qZU+6UYz8K/a5mZe3OefSF0534aimvEmwS0ThFUG6JYKGCudIh6iBADPWz8y8r8MBXJ
         M+2eZNQTIQnCoQ34yQCqbLrptFV3yg56zda3COZ2Xq1sN+6nFAHqaIhuBMYH8nmDWoCw
         RG4aSnueoOebvllCHDXay6dZnt1GdEI4wLV748zme7I8h1xiWd257YhCMfnAV8pjgCPA
         EYMw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Xk3xGW2b;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y22sor5342585iof.16.2019.02.25.21.40.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Feb 2019 21:40:26 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Xk3xGW2b;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bIKVYbyUVD0x9jdnyL5+5v/G/5aUpgYhlC/5rQZY9dI=;
        b=Xk3xGW2bqs+MwP5/OcRg0YjG9YK6BLHu1KzjWW9S0qmW7NMxGSExR/Kxrg9HIevQ6g
         kY8uVzwwSOeom37T8+lBvj8V4Cmm1+zqbAUyZ+/L4iFZwCnTCgjNNiY3Gj6v+K+LwFTN
         wqfnsg6Ab+sDGisUbqN+Aw/FslwU29H4SfDJOnq1sMOnpy3tWwY5U9DRuznQG7exZKss
         QG3txwqor0aEb6S4xbgJj8ccQ0O/Wdtk/EPN7qnlTMhdBmGbjN799O44fBw/yI+GbrQ8
         u+hZcW0iDPfh0wJPdmFOG+wCvIyrv99j71kS+E0xMKOEy1g2d6J91YpHGfjf39+8QD24
         Z9sQ==
X-Google-Smtp-Source: AHgI3IYmVN0LcCx7sA2wfEjGjxoRPGcF9q1sVEiceCmzWHXRkjjxMmrkI1iTdBUJuPNPILwfnxsyWEMd8bKC6uNA8lc=
X-Received: by 2002:a6b:640d:: with SMTP id t13mr5456944iog.102.1551159626677;
 Mon, 25 Feb 2019 21:40:26 -0800 (PST)
MIME-Version: 1.0
References: <1551011649-30103-1-git-send-email-kernelfans@gmail.com>
 <1551011649-30103-4-git-send-email-kernelfans@gmail.com> <8f703c5f-44c7-3a96-487e-3bdf46ee41b0@intel.com>
In-Reply-To: <8f703c5f-44c7-3a96-487e-3bdf46ee41b0@intel.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Tue, 26 Feb 2019 13:40:15 +0800
Message-ID: <CAFgQCTsOqnBdiFHbFVRsjbPkMuV+egUU7RZ-OoXRLndwJAFjoA@mail.gmail.com>
Subject: Re: [PATCH 3/6] x86/numa: define numa_init_array() conditional on CONFIG_NUMA
To: Dave Hansen <dave.hansen@intel.com>
Cc: x86@kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
	Andy Lutomirski <luto@kernel.org>, Andi Kleen <ak@linux.intel.com>, Petr Tesarik <ptesarik@suse.cz>, 
	Michal Hocko <mhocko@suse.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Jonathan Corbet <corbet@lwn.net>, 
	Nicholas Piggin <npiggin@gmail.com>, Daniel Vacek <neelx@redhat.com>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2019 at 11:24 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 2/24/19 4:34 AM, Pingfan Liu wrote:
> > +#ifdef CONFIG_NUMA
> >  /*
> >   * There are unfortunately some poorly designed mainboards around that
> >   * only connect memory to a single CPU. This breaks the 1:1 cpu->node
> > @@ -618,6 +619,9 @@ static void __init numa_init_array(void)
> >               rr = next_node_in(rr, node_online_map);
> >       }
> >  }
> > +#else
> > +static void __init numa_init_array(void) {}
> > +#endif
>
> What functional effect does this #ifdef have?
>
> Let's look at the code:
>
> > static void __init numa_init_array(void)
> > {
> >         int rr, i;
> >
> >         rr = first_node(node_online_map);
> >         for (i = 0; i < nr_cpu_ids; i++) {
> >                 if (early_cpu_to_node(i) != NUMA_NO_NODE)
> >                         continue;
> >                 numa_set_node(i, rr);
> >                 rr = next_node_in(rr, node_online_map);
> >         }
> > }
>
> and "play compiler" for a bit.
>
> The first iteration will see early_cpu_to_node(i)==1 because:
>
> static inline int early_cpu_to_node(int cpu)
> {
>         return 0;
> }
>
> if CONFIG_NUMA=n.
>
> In other words, I'm not sure this patch does *anything*.

I had thought separating [3/6] and [4/6] can ease the review. And I
will merge them in next version.

Thanks and regards,
Pingfan

