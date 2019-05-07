Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF1EDC04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:43:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CD2120675
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:43:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="Co2UIiT1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CD2120675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 12C366B0006; Tue,  7 May 2019 13:43:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B5996B0007; Tue,  7 May 2019 13:43:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E98C56B0008; Tue,  7 May 2019 13:43:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 86F816B0006
	for <linux-mm@kvack.org>; Tue,  7 May 2019 13:43:54 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id d24so2690035lfm.17
        for <linux-mm@kvack.org>; Tue, 07 May 2019 10:43:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=fkA+Y9XnOGjl/cdVGrUxZb5095BOcP1bwTD0zYW4RLc=;
        b=WWCv5L+LuP1vlF/BkTdK/VP/pot7fgCJVoRmVeMOO5XhTkUu9yj1jUD24pKZ+uM6W4
         /VRVdX1rjpKtZibUUJK70o0mHJAKQImz5frO26k0MCXcocfffiAKvuBTNXuKXfour+vI
         cTMxK3nc/noUnHROgreOKvm+DmEdHK33zofKKTpWeEMdtDZMV/GOIhV3ntIyALiKYGew
         gg4QlzWPE5IvXpbt68678dvq2NAXePIIPRRKYHeLz5PcQwMNNnLK1I8Zm433QFtZNMRa
         BXfX5rE2QcN2/l5+gedknP0Dyx3v/hRbIC/mf9KbNN7rJ/6CReltHn7t30mngEgsBR2F
         fSgg==
X-Gm-Message-State: APjAAAWUPw5HgF2311RatouVCWd17OhfvdAze6kWpZqEDCVIK+1IuJTd
	4HbjL3xN1LK7POYCyDgDWLhSBgvHVI//dkFwYU/fXtkT6X5v/r2zSWcdAdHLNj8/HlEyMFeX4eR
	U9y54aZpdSyhRTU0I9i1k0jnVVp9YawMhecursGUzfLUvwTk4HnLhJLvXpIhzZ0UTwA==
X-Received: by 2002:a2e:86c5:: with SMTP id n5mr18561597ljj.184.1557251033822;
        Tue, 07 May 2019 10:43:53 -0700 (PDT)
X-Received: by 2002:a2e:86c5:: with SMTP id n5mr18561569ljj.184.1557251033127;
        Tue, 07 May 2019 10:43:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557251033; cv=none;
        d=google.com; s=arc-20160816;
        b=OtLQl4yN1pPdjkYSHmFJl6Vb6Y2nodD6q9D1fQBagfVoQEVWxQX2EOu2n2BHUsdEQP
         rVd3cQy87wk3pbLuH+moTiX+I4oQrMMZrfGMXRqEEg6YfyX1S6BbvHbSPKJKcI0KUs+z
         zob1G8yU6H5ONu8sLIHH4SN56KMau7aSsMWM71nySTDWlWgHVpvEeC1RWz7hEIcTxR5h
         c8PCdSg9svf3WXPJZUhV5g+qBtqFU3Wf/ZNRW2ou+BhMJxpR2vMOSeNgmkvZMtZt0kwN
         d7H45bOPlLBUirRX6wvQKg+HGU3QYes4gAWkUHYMn3KhTpZ0fBM9UHstcXbrnqg2Y1Tk
         G9Cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=fkA+Y9XnOGjl/cdVGrUxZb5095BOcP1bwTD0zYW4RLc=;
        b=0JoNGg9LiFK7hb144SrSrqbXjU0F2YrpjuFv/0Oc5hV/Vfx6gkRZInPi0v0cwkVNBO
         48UqufNLBfCemeG97p1haUanC1UdQ/90tt0OeNux3y9bmTk+5yGZ3k7xE287fVsFEgLY
         wKmBuANGO90JmUUt2i0hwdt9Iv8fD+zEcwQCvRhkjvnCwQkrfXp/U1u3W7oWRXQcSSBo
         c/PRaya16jOoeQ4Atb+5hHDyu1Vssf+FbiuLTHLdgSWmWcDHdG6g6zqRXopcd2s2CN04
         IM27U4Jv1LV2FqFLNm2DlxXBqSTPRNjPmkgakF5/3ApEIitutlxP/TuO7/V8rfUlAFJa
         yYpw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=Co2UIiT1;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n6sor5701560lji.36.2019.05.07.10.43.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 May 2019 10:43:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=Co2UIiT1;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=fkA+Y9XnOGjl/cdVGrUxZb5095BOcP1bwTD0zYW4RLc=;
        b=Co2UIiT1iv1WhhnvT+1SLlkyQw1jm+jIn7F5nCWplNQ4zzVNCu8DWJlLaOs5Q4eA6v
         dX3/gvVrHWhpmKzMeYWueRW2iIbmxXCiloZEhDBiCwMyJ/AqK/gQeIT/nMiqjhbY4PKo
         2MHqNXryyh0L0banXslg9ahMI3L+ftSr/qVDk=
X-Google-Smtp-Source: APXvYqz4Npzwt6MN3IViFgimCpFmxR/dEjdmGZe1HKqIaeFosGOK/KUyP9b/4GyFD5IAm/aAFtXHBQ==
X-Received: by 2002:a05:651c:97:: with SMTP id 23mr6796037ljq.143.1557251032197;
        Tue, 07 May 2019 10:43:52 -0700 (PDT)
Received: from mail-lj1-f182.google.com (mail-lj1-f182.google.com. [209.85.208.182])
        by smtp.gmail.com with ESMTPSA id r26sm3354750lfa.62.2019.05.07.10.43.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 10:43:50 -0700 (PDT)
Received: by mail-lj1-f182.google.com with SMTP id f23so15133575ljc.0
        for <linux-mm@kvack.org>; Tue, 07 May 2019 10:43:49 -0700 (PDT)
X-Received: by 2002:a2e:9d86:: with SMTP id c6mr16010057ljj.135.1557251027975;
 Tue, 07 May 2019 10:43:47 -0700 (PDT)
MIME-Version: 1.0
References: <20190507053826.31622-1-sashal@kernel.org> <20190507053826.31622-62-sashal@kernel.org>
 <CAKgT0Uc8ywg8zrqyM9G+Ws==+yOfxbk6FOMHstO8qsizt8mqXA@mail.gmail.com>
 <CAHk-=win03Q09XEpYmk51VTdoQJTitrr8ON9vgajrLxV8QHk2A@mail.gmail.com>
 <20190507170208.GF1747@sasha-vm> <CAHk-=wi5M-CC3CUhmQZOvQE2xJgfBgrgyAxp+tE=1n3DaNocSg@mail.gmail.com>
 <20190507171806.GG1747@sasha-vm> <20190507173224.GS31017@dhcp22.suse.cz> <20190507173655.GA1403@bombadil.infradead.org>
In-Reply-To: <20190507173655.GA1403@bombadil.infradead.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 7 May 2019 10:43:31 -0700
X-Gmail-Original-Message-ID: <CAHk-=wjFkwKpRGP-MJA6mM6ZOu0aiqtvmqxKR78HHXVd_SwpUg@mail.gmail.com>
Message-ID: <CAHk-=wjFkwKpRGP-MJA6mM6ZOu0aiqtvmqxKR78HHXVd_SwpUg@mail.gmail.com>
Subject: Re: [PATCH AUTOSEL 4.14 62/95] mm, memory_hotplug: initialize struct
 pages for the full memory section
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Sasha Levin <sashal@kernel.org>, 
	Alexander Duyck <alexander.duyck@gmail.com>, LKML <linux-kernel@vger.kernel.org>, 
	stable <stable@vger.kernel.org>, Mikhail Zaslonko <zaslonko@linux.ibm.com>, 
	Gerald Schaefer <gerald.schaefer@de.ibm.com>, 
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, Dave Hansen <dave.hansen@intel.com>, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>, 
	Pasha Tatashin <Pavel.Tatashin@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, 
	Heiko Carstens <heiko.carstens@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Sasha Levin <alexander.levin@microsoft.com>, linux-mm <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 7, 2019 at 10:36 AM Matthew Wilcox <willy@infradead.org> wrote:
>
> Can we do something with qemu?  Is it flexible enough to hotplug memory
> at the right boundaries?

It's not just the actual hotplugged memory, it's things like how the
e820 tables were laid out for the _regular_ non-hotplug stuff too,
iirc to get the cases where something didn't work out.

I'm sure it *could* be emulated, and I'm sure some hotplug (and page
poison errors etc) testing in qemu would be lovely and presumably some
people do it, but all the cases so far have been about odd small
special cases that people didn't think of and didn't hit. I'm not sure
the qemu testing would think of them either..

                Linus

