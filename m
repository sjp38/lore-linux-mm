Return-Path: <SRS0=WbXp=VF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC5CEC48BE7
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 08:36:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 801BE20665
	for <linux-mm@archiver.kernel.org>; Mon,  8 Jul 2019 08:36:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cOMsmIgo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 801BE20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B0B88E000D; Mon,  8 Jul 2019 04:36:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 187178E0002; Mon,  8 Jul 2019 04:36:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09C148E000D; Mon,  8 Jul 2019 04:36:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id DF02F8E0002
	for <linux-mm@kvack.org>; Mon,  8 Jul 2019 04:36:36 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id v3so11769413ios.4
        for <linux-mm@kvack.org>; Mon, 08 Jul 2019 01:36:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=5KXyzOyddJPSYupMaPtJc3n1+Qs9tx3Gcb2Q7zVo0M8=;
        b=V0ABwHHAYwIrDQF9KqZiE2i8o+KS8kbXiFIXMIocDKS0RenQkjMBa6k3RTBrg6Fuwq
         H3+0ucmSh63aaEzKfR5khRLE1gSSYKXYgikIdsqX7MnDUd4rerw02UpMBwhlLVystbbl
         vEdwKjNJTdlkGHyt72lr8m41nkKieOvjQyLRR0vOfaDO7LonsOEMipKitFCYh7u5KOwy
         zcRFmBXvSzpbM+BuAtEIUpKGHLRqbw+DtMc+lVjXO/1slwLfY93NFl7VfSK981ixEG8H
         aIRrNmX91qYO+MjxcIibb7eHQLrRX+3wPfg5YVxfPmB77JWBYs6oiNTrvgWN4E059kHT
         T9IQ==
X-Gm-Message-State: APjAAAUDLMxv3poiAY9l1qPzGQ1yXyfTS6hajMZqGZ2EhHuzwFzHl/s1
	qCkYL3UZjPwtrWOqllk/MFiEjYpm51zpxhxPqR6yXNsUy+u1cHQb9mZ6w1lu56TIacVR1A4eFGe
	mJ2M3L3Qw/4tc0a5yX1Uf2M4pYH8r/hCKFIvl29BHHRI6vddJj1jhlNcYH4tHGQKFyw==
X-Received: by 2002:a05:6602:cc:: with SMTP id z12mr11845725ioe.86.1562574996646;
        Mon, 08 Jul 2019 01:36:36 -0700 (PDT)
X-Received: by 2002:a05:6602:cc:: with SMTP id z12mr11845674ioe.86.1562574995707;
        Mon, 08 Jul 2019 01:36:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562574995; cv=none;
        d=google.com; s=arc-20160816;
        b=LVDVPF7uf+gvemAVuVlaQgbxqipylAUAw2vcm00LFTuEmfsZk/X1xvc7qbS2GaDBFc
         YHnVaT5uLXP2mqUi0QW971/ThSfXkYEmW5Q6h+VvcZk6JNd765IiU5nwAYH5W29dBBDY
         pfQFS0OiqGmdb4yJ63eaXC0NqOc+Ir/2x8IBG9GNxNhZav3vs5TFcQg4WuHJuopkXabU
         nlHcyxi1oTlv6qS+lJMMQW3dRHhMyFKjtSyrGDR5O7JnCPHRacUk2AeEaS9rPfU+M1Q0
         DyWp/Kzhv3/szuJY1rdJBtO4NeEmh6lUGxdtd3D5cYOc++TdIEbNfMvBwwwWPf6OCkQF
         iouQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=5KXyzOyddJPSYupMaPtJc3n1+Qs9tx3Gcb2Q7zVo0M8=;
        b=XIAld3lZxZkFsLLOLhN+H3D3bsul/RlzcvYstxYgfdTC1/XQo2KtZyDgo+dEM0T2dO
         vCYNXaMZDG7ONAz3qn1pRBPPUQlDtoD4kC+4w76atSO5r8T7Wl8jHWnPwvWtljEyWvow
         xy1RsBXc4P0Xk1JBbNcK7yTosZKcWwmNnArcFE0zKOhNLz88OCH+y+Ya1wg2hatkKuId
         zgwsyLY1sEzSJIxVqsD7rSaX0AH+fAceHYrhGUez0g3rYge7JUmmI4va7oWpptlt4n9Y
         73AVfyLd0OGZPSnLIbGSJKH6FkiWquzzZ0l33mG6elQ/hrAByc+TppSqH4GYxlypdc50
         6maQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cOMsmIgo;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p14sor11342050ios.125.2019.07.08.01.36.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 08 Jul 2019 01:36:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cOMsmIgo;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=5KXyzOyddJPSYupMaPtJc3n1+Qs9tx3Gcb2Q7zVo0M8=;
        b=cOMsmIgo9no2UIxYQtl0IEhs9cOfaY/6hH+TSNYWkEVjYrtyDyiSG+Pawi7rst84iL
         aYMFDkhVgQ713ZWq/WNdEtQUY3srXzZzw6MniZc45HgtCzqilWOYA4acWuiVnXpt6yCn
         dYF7IAD/K7goEhoSST/5CMrxkxRbHqybP9YsubSqGJ+1GueL5Ta2hGjNUlxXwFCc1BEO
         WZ1+QrX+fsuoq8p3EohEENriAsyZrotv0Lh+a/HQbO5y1KeHvr9lhZOUp8qSZZ5AaeL4
         HN3Qosc6+tKtmoIL0erNdz9FKdlU/HmzbGtDN9Tbcxr+J5fBiL5lJMyfjeWH2F/YDbOz
         ajKA==
X-Google-Smtp-Source: APXvYqxjK31i5rr/fwm4g6B2ljMVmD03cvBH/BrY4xuXXtnM1WvV466gG06eq12moEwOXDBhPpeTUgO7m3jJQdXjkBs=
X-Received: by 2002:a6b:6f06:: with SMTP id k6mr13682792ioc.32.1562574994974;
 Mon, 08 Jul 2019 01:36:34 -0700 (PDT)
MIME-Version: 1.0
References: <1562300143-11671-1-git-send-email-kernelfans@gmail.com>
 <1562300143-11671-2-git-send-email-kernelfans@gmail.com> <alpine.DEB.2.21.1907072133310.3648@nanos.tec.linutronix.de>
In-Reply-To: <alpine.DEB.2.21.1907072133310.3648@nanos.tec.linutronix.de>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Mon, 8 Jul 2019 16:36:23 +0800
Message-ID: <CAFgQCTvwS+yEkAmCJnsCfnr0JS01OFtBnDg4cr41_GqU79A4Gg@mail.gmail.com>
Subject: Re: [PATCH 2/2] x86/numa: instance all parsed numa node
To: Thomas Gleixner <tglx@linutronix.de>
Cc: x86@kernel.org, Michal Hocko <mhocko@suse.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Tony Luck <tony.luck@intel.com>, Andy Lutomirski <luto@kernel.org>, 
	Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	"H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>, 
	Pavel Tatashin <pavel.tatashin@microsoft.com>, Mel Gorman <mgorman@techsingularity.net>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, 
	Stephen Rothwell <sfr@canb.auug.org.au>, Qian Cai <cai@lca.pw>, Barret Rhoden <brho@google.com>, 
	Bjorn Helgaas <bhelgaas@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 8, 2019 at 3:44 AM Thomas Gleixner <tglx@linutronix.de> wrote:
>
> On Fri, 5 Jul 2019, Pingfan Liu wrote:
>
> > I hit a bug on an AMD machine, with kexec -l nr_cpus=4 option. nr_cpus option
> > is used to speed up kdump process, so it is not a rare case.
>
> But fundamentally wrong, really.
>
> The rest of the CPUs are in a half baken state and any broadcast event,
> e.g. MCE or a stray IPI, will result in a undiagnosable crash.
Very appreciate if you can pay more word on it? I tried to figure out
your point, but fail.

For "a half baked state", I think you concern about LAPIC state, and I
expand this point like the following:

For IPI: when capture kernel BSP is up, the rest cpus are still loop
inside crash_nmi_callback(), so there is no way to eject new IPI from
these cpu. Also we disable_local_APIC(), which effectively prevent the
LAPIC from responding to IPI, except NMI/INIT/SIPI, which will not
occur in crash case.

For MCE, I am not sure whether it can broadcast or not between cpus,
but as my understanding, it can not. Then is it a problem?

From another view point, is there any difference between nr_cpus=1 and
nr_cpus> 1 in crashing case? If stray IPI raises issue to nr_cpus>1,
it does for nr_cpus=1.

Thanks,
  Pingfan

