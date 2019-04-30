Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4FEBCC43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 09:38:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 095232080C
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 09:38:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ukGEBlNW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 095232080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 966776B0010; Tue, 30 Apr 2019 05:38:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F0DF6B0266; Tue, 30 Apr 2019 05:38:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B9B86B0269; Tue, 30 Apr 2019 05:38:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 16DC86B0010
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 05:38:12 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id y62so543999lfc.16
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 02:38:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=zYjnml+G09Y2iH7YOBy1RnUmEBfOtgqF9A/Rh/pjRIY=;
        b=JxPcnSZFeoDfsg18W7oOGYCcbHzfDcc6mM/q6MtznJZORlshbwLgkNUX2hhZBSo0l5
         M2PMduLRVoidU5PEX6IYBQTVsM017rnsjYWjMky7xdoHsTGVSBZH4F4+j3jkV5M5Ml36
         UBtn7D1gcKbi7kpnq6h4eYiv09oOePBy6d9aUnYVJdAmrL/OrOBsBU6n+L3oTHhHyZiv
         iyjwJ8u3vsYY1dwmUJjhuZE0VqdL2ixeQe3COC/MN3dCj1cyKaD4ESCjxUlLTxqJqoFl
         Q0xEsqmXttB5iMh8IMsZ8TzV0GB6rsjBWPuVDQK/be7YH4QiyxZpvrMyXL9sKXnF4qvf
         OEKQ==
X-Gm-Message-State: APjAAAU81UGnNc1AoxbWJC5U9CcoIazEnsUkmmoQ71zGe9Vw5qHsygbC
	WR4j5WeRm+yoj8GHPxdcKcWB4nOmf6c9+1gs5yNTUkFA3KzcEEKKotjyikaH+qEZCxKJLmyIlaz
	pK7u5xJuk/Wm3mCXptx2LR7W7TfDE98xZaf+D/UZhl0K+zOteNb6jjL42EOv5d0QuFQ==
X-Received: by 2002:ac2:5088:: with SMTP id f8mr37450027lfm.107.1556617091352;
        Tue, 30 Apr 2019 02:38:11 -0700 (PDT)
X-Received: by 2002:ac2:5088:: with SMTP id f8mr37449995lfm.107.1556617090617;
        Tue, 30 Apr 2019 02:38:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556617090; cv=none;
        d=google.com; s=arc-20160816;
        b=tKMPn7yjjUq0H/Evklhd7MATY/o9OZGkZUYcXi1qbXJhyUNF8pb+Uj0ubFyZsMYNNz
         hasmasyhb7HadCJ0bRt+4dqZ0xNeRcyLh7eWgyQ1X9dB3LkFGsphHSAgrGRiK8hXviBY
         XukY9qsgX/qUXcahusXZeL/jwH23pBU7aDNsgqyFeTZJAPENbbjhTzWBYOnDHEUR6vqD
         tr9d8BzVl++A5ZJTHdfoiAOJY06L6SfGQOnjk6p383Tidesy7rbnXWwocq0JRXmbVW/b
         /5wRnwBYEF2oT56UDFHW05KBnZe6IFUo+CF3M8jlJN/YXobyY3uHdzN1NIZ1Hh+PhcGW
         GehA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=zYjnml+G09Y2iH7YOBy1RnUmEBfOtgqF9A/Rh/pjRIY=;
        b=t0vtY7hxHlhXV7dZpEnUL9Mid5V9aTvl5ZKGtOCQpmbLZVfoXbyblEU4Ug0IJ5YliJ
         ECF9GvHDa5kkx/f9EIqjNnOcvA0uTK7+MtkJQ+OCQI2e+6SZ92SKfVNNxMp3MHuC37Lq
         d1aVRaBDgzNHFuDjRCJoVKJZ6AaaQ6NkjNfekCAiIf5dT+QUsCiddm71xQUFUWjei5CH
         dteRMv5bvllLkUh06qereeKt7cL6ZFY0f8KqBaXzrH0kFHRCfRA6K+LSHB5tXPBPDVH6
         LbFM+3p0LE7yXXYn1C+MMcjqnchzgBLIvNcjOLKTHdvWrNoN/YrJlf0AhOz7oVf1OS7U
         KOFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ukGEBlNW;
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q17sor4232445ljj.30.2019.04.30.02.38.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 02:38:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ukGEBlNW;
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=zYjnml+G09Y2iH7YOBy1RnUmEBfOtgqF9A/Rh/pjRIY=;
        b=ukGEBlNWpw3ngsxHEBXIQvlOeQhk4/p8R6GklmoB2a/Xv4c2NAwqOW+cNq7yBLyL2B
         dBM9smuHxp7kZy66IxNEH6kzgwI4RJd82xvidtZDKhUdNbLaEsENurzJ+oj57ObbDtPs
         2gPE4aJopsgxoW0EJ3MNExq6DgBsaZ+Kv6Jfluqf0CtBIn88GNQzHCmQolL80H1brM2K
         yijxEgwd99V9DqOpzUHXvBwaNvpoxs9k9tTcEX9MRgfaanxEYssrdayZTUb/xuilfH7/
         y9GV0XIkScDJQx2nQUJrqtsIXjr2x18uJzzzUjE/TilqtUizxTCPjBmxTC6/AOgrlhFc
         HKig==
X-Google-Smtp-Source: APXvYqxOGwnTEPiPGzR1pnewgUsAD0rmNHah8NK5uqndt/a8Ai7cN9+BqLVfK2dgtlDwZGL1HRdMqw==
X-Received: by 2002:a2e:8648:: with SMTP id i8mr36897627ljj.166.1556617090058;
        Tue, 30 Apr 2019 02:38:10 -0700 (PDT)
Received: from uranus.localdomain ([5.18.103.226])
        by smtp.gmail.com with ESMTPSA id l16sm7876890lfk.44.2019.04.30.02.38.08
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 Apr 2019 02:38:09 -0700 (PDT)
Received: by uranus.localdomain (Postfix, from userid 1000)
	id 840A24603CA; Tue, 30 Apr 2019 12:38:08 +0300 (MSK)
Date: Tue, 30 Apr 2019 12:38:08 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>,
	akpm@linux-foundation.org, arunks@codeaurora.org, brgl@bgdev.pl,
	geert+renesas@glider.be, ldufour@linux.ibm.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org, mguzik@redhat.com,
	mhocko@kernel.org, rppt@linux.ibm.com, vbabka@suse.cz
Subject: Re: [PATCH 1/3] mm: get_cmdline use arg_lock instead of mmap_sem
Message-ID: <20190430093808.GD2673@uranus.lan>
References: <20190418182321.GJ3040@uranus.lan>
 <20190430081844.22597-1-mkoutny@suse.com>
 <20190430081844.22597-2-mkoutny@suse.com>
 <4c79fb09-c310-4426-68f7-8b268100359a@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4c79fb09-c310-4426-68f7-8b268100359a@virtuozzo.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 30, 2019 at 12:09:57PM +0300, Kirill Tkhai wrote:
> 
> This looks OK for me.
> 
> But speaking about existing code it's a secret for me, why we ignore arg_lock
> in binfmt code, e.g. in load_elf_binary().

Well, strictly speaking we probably should but you know setup of
the @arg_start by kernel's elf loader doesn't cause any side
effects as far as I can tell (its been working this lockless
way for years, mmap_sem is taken later in the loader code).
Though for consistency sake we probably should set it up
under the spinlock.

