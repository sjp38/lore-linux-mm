Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_2 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61584C3A5A7
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 15:02:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 242F623431
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 15:02:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Y0dYwB/x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 242F623431
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C75B06B026A; Tue,  3 Sep 2019 11:02:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C26DE6B026B; Tue,  3 Sep 2019 11:02:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B3D0E6B026C; Tue,  3 Sep 2019 11:02:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0105.hostedemail.com [216.40.44.105])
	by kanga.kvack.org (Postfix) with ESMTP id 9476B6B026A
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 11:02:50 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 3289F181AC9BA
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 15:02:50 +0000 (UTC)
X-FDA: 75893926500.23.stop66_8d0b7e9e4fc01
X-HE-Tag: stop66_8d0b7e9e4fc01
X-Filterd-Recvd-Size: 5480
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 15:02:49 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id l22so8060718qtp.10
        for <linux-mm@kvack.org>; Tue, 03 Sep 2019 08:02:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=98UJ89ZiZ75QQYhHn10zS32n71fYy3DwoNcRQRVS5xk=;
        b=Y0dYwB/xEIg2VC6kphV8moKQMLXSqjyrxIDvPmAgzYa7jRAFu+rhArsFpgpxNorwxF
         gHTeIuv/iD4Osf2V9qXXedGunN+ouk+dYxB/wokeKoDvPfNrjfb1JlTrJ2lG+Iu2xoe8
         JAbKHDYsO+QD2AGmQ2Q0w+50if55VPTX6DUbkWsl7ddh3kYlzHhS70XKbYo+sutA8I3H
         LEJJiwbr0XaAYu5yLRW4Jtm0uQBwIfiDkSBfI4x0S/BRs0uUDHQ0ARjWz59xZLqbkBPf
         J+hyZOZ41bFrhG7YcJvCAOxiTz+SvDl87P2/LOc+17Xg84onz/vXt6zb68kOdAIN4K0V
         LRzQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:message-id:subject:from:to:cc:date:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=98UJ89ZiZ75QQYhHn10zS32n71fYy3DwoNcRQRVS5xk=;
        b=ZcFOhhre6qHUcUo20V1CsFGo+v6UM57tvJkPDQByFtik/qv0C/H0KUKtTUKFVEON/c
         s4wDA2MwSbfMmRbuRp2EcuwsqqhCSybHsg1CgaVpI7fMOo7zyCXZToXUFsBgTqBWF6ij
         ROxOGTnPsYjilFgy3D32pvzCxB0yZo+GRS2FUhIzMYMjireuCp2QuP0nk/teFh2ZeU/D
         Xb/hE5LfPY2nVvFX0lj+9GcUUb16kUG0I+BUPWcrmY09TffM/3Oo72LPU4R2HBAmcpvt
         ycbLv1GTdDksnorI7Zw6qV3HL5qgPh1L3L1RVK1/xFhJSvPQlbDa2KXHE8ql4QSaEX+L
         /eDA==
X-Gm-Message-State: APjAAAXe8ycJ3xhoyDbi2W4k92rJVXIwr7zy/p3uKOxi0j2Gctqot+ZB
	XBgeXwQ5lPHYYd4JoTbqYgBSUA==
X-Google-Smtp-Source: APXvYqzTAE6mfgfo1ByrawGaOyifrsk7CtcAySIiPJNBqNzUp8BpFsqQkls2qLZH4XeyuvxZZpIQaw==
X-Received: by 2002:ac8:6a0a:: with SMTP id t10mr19414483qtr.0.1567522968447;
        Tue, 03 Sep 2019 08:02:48 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id z5sm98214qki.55.2019.09.03.08.02.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Sep 2019 08:02:47 -0700 (PDT)
Message-ID: <1567522966.5576.51.camel@lca.pw>
Subject: Re: [RFC PATCH] mm, oom: disable dump_tasks by default
From: Qian Cai <cai@lca.pw>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa
 <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>,
  LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>
Date: Tue, 03 Sep 2019 11:02:46 -0400
In-Reply-To: <20190903144512.9374-1-mhocko@kernel.org>
References: <20190903144512.9374-1-mhocko@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-09-03 at 16:45 +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>=20
> dump_tasks has been introduced by quite some time ago fef1bdd68c81
> ("oom: add sysctl to enable task memory dump"). It's primary purpose is
> to help analyse oom victim selection decision. This has been certainly
> useful at times when the heuristic to chose a victim was much more
> volatile. Since a63d83f427fb ("oom: badness heuristic rewrite")
> situation became much more stable (mostly because the only selection
> criterion is the memory usage) and reports about a wrong process to
> be shot down have become effectively non-existent.

Well, I still see OOM sometimes kills wrong processes like ssh, systemd
processes while LTP OOM tests with staight-forward allocation patterns. I=
 just
have not had a chance to debug them fully. The situation could be worse w=
ith
more complex allocations like random stress or fuzzy testing.

>=20
> dump_tasks can generate a lot of output to the kernel log. It is not
> uncommon that even relative small system has hundreds of tasks running.
> Generating a lot of output to the kernel log both makes the oom report
> less convenient to process and also induces a higher load on the printk
> subsystem which can lead to other problems (e.g. longer stalls to flush
> all the data to consoles).

It is only generate output for the victim process where I tested on those=
 large
NUMA machines and the output is fairly manageable.

>=20
> Therefore change the default of oom_dump_tasks to not print the task
> list by default. The sysctl remains in place for anybody who might need
> to get this additional information. The oom report still provides an
> information about the allocation context and the state of the MM
> subsystem which should be sufficient to analyse most of the oom
> situations.
>=20
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> =C2=A0mm/oom_kill.c | 2 +-
> =C2=A01 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index eda2e2a0bdc6..d0353705c6e6 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -52,7 +52,7 @@
> =C2=A0
> =C2=A0int sysctl_panic_on_oom;
> =C2=A0int sysctl_oom_kill_allocating_task;
> -int sysctl_oom_dump_tasks =3D 1;
> +int sysctl_oom_dump_tasks;
> =C2=A0
> =C2=A0/*
> =C2=A0 * Serializes oom killer invocations (out_of_memory()) from all c=
ontexts to

