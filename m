Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 832608E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 02:05:54 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id t18so15400507qtj.3
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 23:05:54 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q14sor74096602qta.2.2019.01.10.23.05.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 23:05:53 -0800 (PST)
MIME-Version: 1.0
References: <CALaQ_hpCKoLxp-0cgxw9TqPGBSzY7RhrnFZ0jGAQ11HbOZkZ3w@mail.gmail.com>
 <20190107095229.uvfuxpglreibxlo4@mbp>
In-Reply-To: <20190107095229.uvfuxpglreibxlo4@mbp>
From: Nathan Royce <nroycea+kernel@gmail.com>
Date: Fri, 11 Jan 2019 01:05:41 -0600
Message-ID: <CALaQ_hraox3anhupk_psorbAwyWK5wN-dHyp6bbGvQteyVWZsg@mail.gmail.com>
Subject: Re: kmemleak: Cannot allocate a kmemleak_object structure - Kernel 4.19.13
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

One more thought that may be nothing, but when kmemleak crashed,
SUnreclaim was at 932552 kB, and after reclaimed/cleared 299840 kB.
There weren't any performance issues like when I had a leak of 5.5 gB
in the 4.18 kernel.

On Mon, Jan 7, 2019 at 3:52 AM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> Under memory pressure, kmemleak may fail to allocate memory. See this
> patch for an attempt to slightly improve things but it's not a proper
> solution:
>
> http://lkml.kernel.org/r/20190102180619.12392-1-cai@lca.pw
>
> --
> Catalin
