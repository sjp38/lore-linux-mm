Return-Path: <SRS0=PO26=VY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14B76C7618B
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 17:25:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3C312083B
	for <linux-mm@archiver.kernel.org>; Sat, 27 Jul 2019 17:25:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="t5kSA4pk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3C312083B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 593A18E0003; Sat, 27 Jul 2019 13:25:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 545108E0002; Sat, 27 Jul 2019 13:25:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40C168E0003; Sat, 27 Jul 2019 13:25:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 197888E0002
	for <linux-mm@kvack.org>; Sat, 27 Jul 2019 13:25:16 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id x18so31104715otp.9
        for <linux-mm@kvack.org>; Sat, 27 Jul 2019 10:25:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=GnqU0JRhrXBsiEdVfrpxRYhB+jhyBUboMzh3dp1tPvc=;
        b=KbiadjQN08ZSTlLvyAorjYGvAs4NoxCpDsaTyC/pWIzRQ3zUNesMq+1Yyo3NihXIPf
         GV1yyo2sIlhmSi4QNTkq9Nx2O8lQPhWqxOTvB1PjhmC/fqb9Nc1TRAbBKphmQlEPxwda
         VnT/3KUZjd68Wmz9OWsHaiUMOUXgEHHw5e966B7pl/NJpxw51hpUUdyeaxQukYIXVaQM
         WHiOeZtrZrlLwLKaurErBZQ8KG7ERIgTlg/YQREGeqVDMaRi7qhol6DpS7+ZS1M1TgvO
         vNAEb/052/DM+52ADeBomwQlOF5Sw7gFuzdV2iUZkEIS7MEZ+zOOojS3UsYdx5yoKx/I
         WCpQ==
X-Gm-Message-State: APjAAAVXU1QDIEVbTkD4EVeBiFTe7Rbajc2fFDVVtLcH6ZP0FDky/fdK
	qF5T4eDjPJ5C0/Z++Ek70mdzl+Y6SPTdMGmBBhSch/FjmnCa9ZTWUCoOFQwIGKEBbL06Tpfrm/9
	QSPN8CkdOWEYglUbvYFJMCJZmdKWPvLYut0e21zgQFxRtpNRB+Cu2f6P8vwvVwUOZOQ==
X-Received: by 2002:a9d:5182:: with SMTP id y2mr13429338otg.271.1564248315777;
        Sat, 27 Jul 2019 10:25:15 -0700 (PDT)
X-Received: by 2002:a9d:5182:: with SMTP id y2mr13429322otg.271.1564248315154;
        Sat, 27 Jul 2019 10:25:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564248315; cv=none;
        d=google.com; s=arc-20160816;
        b=wlgrCePy+/n1wS1oLN5TFZQLI1LIi7H1skQH8Lvg7r98z52C8lksX+mZqc6F7aqNwS
         wY6t40HGVuXggVLBsZvRFkoJRmeNcmSNc7yhyi39RXto6ZKIfuAXtOojqAn8V+okjtEq
         3mGsO4WlR2BULSF4bFU9m2Gblj9D/Ea2aazetzptTuURO1v98ZWxf9Zucbt+eUHSV/5N
         zqZroBL4v2gh8lySD2RFchesgRJPPKtdH6R8b1YLfgXN5AuRHm4WXu8t+gyDrWtQ4Bam
         8yJxVHlCj+NpgU9+zfY74YcfZjcpf2hdPdfTqeDEHWC8QqLECe+nq5FODZVFGDUskYiL
         Zm3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=GnqU0JRhrXBsiEdVfrpxRYhB+jhyBUboMzh3dp1tPvc=;
        b=yAQaEw5OgXf+3hcvVAkOCoU1URtErLV6BgSW5BE8U+FjIDKLfhJLKNDe4KpkGj4e/V
         58tfnfM0zlsECBW4bXp/ap8x0whOBuJWbhEEkdehwj5XQSayaDbI7HLZKKA/Ebn3Tu6k
         kpOJuJInSVdTuTlwD7MmtEGEJ1v2MBrRFdPReHTSnkzJ/lMqTqzdTL+rnvPlp+MVs2K0
         1daQzjJVLU+tO9idT8YwYXNxMqCugG6aY12Sp0BjvzH/u5P2Dwgw2SPO+z6nVjKgGwO9
         1tzOAPiOAVqGBxrENBwkhGK2G6Gf4KWHFzpKc5F88kfb7N56mV7eT8LXkl/EtHvSodat
         dAKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=t5kSA4pk;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x6sor28237132otq.80.2019.07.27.10.25.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 27 Jul 2019 10:25:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=t5kSA4pk;
       spf=pass (google.com: domain of lpf.vector@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=lpf.vector@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=GnqU0JRhrXBsiEdVfrpxRYhB+jhyBUboMzh3dp1tPvc=;
        b=t5kSA4pkhco77TShAAaMPIl1DAEIo8hLSMUCCmpXXj9Z8l3AEbxPPtTPHlV27fOVCe
         +QJQV64yQyneiJ4QqJPMJz3diUQwGaL4/cpogzyHUCg0Sw1VfPAdf7kqhvMlLEZveam+
         7DsthIZxv3KZwo3AhW5msgxhNpyk+tXDIzqCHi2JE2v400wzBomRYOUxc+EhGPpTrFLM
         hPMyRRpACoOCg/4w0nvsFNxcp9eX0nTVgXYoCqc0bj25txMqcBi0X59HZZ4tV5F26AZY
         1NDtFdARA+3mlYVIDc5P1pBt/GoLferKZo6H5ZRD+8DssJMi5hiMQP7iV4cWC6Z0GW7e
         2JAw==
X-Google-Smtp-Source: APXvYqzgh59g+ACIfiw2qGNQLkF6F1GlClI1XRgmH1D5Yjm7nb8sSCqgU3QzmV3GAkGYA4zf8O3vnAkHF2nB2QLUeKs=
X-Received: by 2002:a9d:460d:: with SMTP id y13mr53509367ote.368.1564248314917;
 Sat, 27 Jul 2019 10:25:14 -0700 (PDT)
MIME-Version: 1.0
References: <20190725184253.21160-1-lpf.vector@gmail.com> <1564080768.11067.22.camel@lca.pw>
 <CAD7_sbEXQt0oHuD01BXdW2_=G4h8U8ogHVt0N1Yez2ajFJkShw@mail.gmail.com> <20190726071219.GC6142@dhcp22.suse.cz>
In-Reply-To: <20190726071219.GC6142@dhcp22.suse.cz>
From: Pengfei Li <lpf.vector@gmail.com>
Date: Sun, 28 Jul 2019 01:25:02 +0800
Message-ID: <CAD7_sbF7JMbxBF1ZRQKxW-U9S-tEOhneumjGXT3YADEfYCGKYw@mail.gmail.com>
Subject: Re: [PATCH 00/10] make "order" unsigned int
To: Michal Hocko <mhocko@kernel.org>
Cc: Qian Cai <cai@lca.pw>, Andrew Morton <akpm@linux-foundation.org>, 
	Mel Gorman <mgorman@techsingularity.net>, vbabka@suse.cz, aryabinin@virtuozzo.com, 
	osalvador@suse.de, rostedt@goodmis.org, mingo@redhat.com, 
	pavel.tatashin@microsoft.com, rppt@linux.ibm.com, 
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 26, 2019 at 3:12 PM Michal Hocko <mhocko@kernel.org> wrote:
>

Thank you for your comments.

> On Fri 26-07-19 07:48:36, Pengfei Li wrote:
> [...]
> > For the benefit, "order" may be negative, which is confusing and weird.
>
> order = -1 has a special meaning.
>

Yes. But I mean -1 can be replaced by any number greater than
MAX_ORDER - 1 and there is no reason to be negative.

> > There is no good reason not to do this since it can be avoided.
>
> "This is good because we can do it" doesn't really sound like a
> convincing argument to me. I would understand if this reduced a
> generated code, made an overall code readability much better or
> something along those lines. Also we only use MAX_ORDER range of values
> so I could argue that a smaller data type (e.g. short) should be
> sufficient for this data type.
>

I resend an email to interpret the meaning of my commit, and I would be
very grateful if you post some comments on this.

> Please note that _any_ change, alebit seemingly small, can introduce a
> subtle bug. Also each patch requires a man power to review so you have
> to understand that "just because we can" is not a strong motivation for
> people to spend their time on such a patch.

Sincerely thank you, I will keep these in mind.

> --
> Michal Hocko
> SUSE Labs

--
Pengfei

