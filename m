Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BA400C04AA8
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:24:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F0D521734
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:24:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PxutZQVn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F0D521734
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BEF1B6B0003; Tue, 30 Apr 2019 09:24:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B9E566B0006; Tue, 30 Apr 2019 09:24:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A655A6B0007; Tue, 30 Apr 2019 09:24:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4017E6B0003
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:24:08 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id 140so2774243ljj.17
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 06:24:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=qnpMUYkMmL9pa1NwW2JEoP1ItjcZEv+YmAjkVOUYqyQ=;
        b=PC1TgVMOPtcc6MEBzXysCuARftxGOzjffBcTNaiH3gq7/2Hbn1xmUXb1LQgGNy/nyi
         Mqs5YMLEOw+otSbuNGKs+g4WYqvj+5pSGD0ZS8/sLzEwauIQRRXVsMR6y2QBMluU2GH0
         n7i5RRVJRlMuA2sYlooHno0jlDXMYTJexpPO9dzNQSXhAldLjZ+APAOPXA0gBDfERBBz
         DSilMdg/AlOwOw5UHNLSjjlAQQ75RRDKL8TcCiydNZiPkNptly5CaYDIg0XzlYT2mlCj
         x8P7FaO1HuYHIyHa5G05EZDfkIBUi1zEoGcPub5Y3ZMdrDEErZEG9tdeNDCR+bYg9SKg
         Zweg==
X-Gm-Message-State: APjAAAWvHaIBOi8lVAkRT/M+qOhiHPvdtjtgINHRsmLePsOeWJ3CwFLn
	YZrGL+ox8kyXiZoTde59Y31VpUj7b+QFXZqzE9oAjbkN2vhZru5Qel9imB8JGtWpxdATEze+1sl
	PRgIFHKLYV9E4rSrBVFcV/go1oysMj/EtweNd6ktjlnTwvgnX1dcgCsVujqn5UF77zg==
X-Received: by 2002:ac2:5222:: with SMTP id i2mr33902620lfl.68.1556630647388;
        Tue, 30 Apr 2019 06:24:07 -0700 (PDT)
X-Received: by 2002:ac2:5222:: with SMTP id i2mr33902566lfl.68.1556630646194;
        Tue, 30 Apr 2019 06:24:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556630646; cv=none;
        d=google.com; s=arc-20160816;
        b=CMMfvH4ulekooN+HWv5wEPfrbHoEnxthYDJDp7aOH/7tH1y0yYcHw2A7WYVYrjleJE
         itVbZ2c18sczXE4Fh6mNe/gLG5gWPK3aYrHtNMTOIMFCnLok6nAXlSyq6c+6uoMaYmgJ
         n2GXK6DOdq2mVnd67N6pkuZ9N7YR3RV4YLrHLk4BGCInc2VlQkDPcW4svMDomHugtFqL
         Smnk/zPtYz0blaC4s5+c6C9bTB8tJcRYbvgSrzKLx4bJJT9TEla1WKKocCELFt9Z0AWA
         MDN79IBpnqk4F2n3Xk4sRdm2sO/12lqYgqFVPxuQjMpspU52eDHxy1PcYTbxZtVgQpzq
         jzGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=qnpMUYkMmL9pa1NwW2JEoP1ItjcZEv+YmAjkVOUYqyQ=;
        b=i5KqS1dpuQwxE9/1RrobG1h0sz8vyPKdS6OHH76SnQMplqKm+iTby3Io8itDibmjp9
         CcOt0STtLhmhlTsWKN+qVDT9QGRzdcZaSPI191481AfdplBvwY8xIPZ+BSFpnpFSyFJu
         6ol/pxTCnsVRYKVo2M6ZytD2gzREF1xCrviYWvrwEOnueajnolZmf5Sjbdsfv0t7svni
         51NUhmkmYvChOm+6qfDBJ6FLkwxfRsN797bZrJ8mgXHyMwSWQl9rdMwG0m8YVVMu6Vnm
         2A28dDkaMG2j13w4vzNfkNSXcttqvTijeZi8Nlm3sZspOc9o7ICKsXk90GsaG7NTOGMZ
         zrUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PxutZQVn;
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f9sor8017338lfl.55.2019.04.30.06.24.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 06:24:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PxutZQVn;
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=qnpMUYkMmL9pa1NwW2JEoP1ItjcZEv+YmAjkVOUYqyQ=;
        b=PxutZQVnmGiTrO83tBry4NYVOaB4lJN09Oxip41bc355LYSr1LYeo1lMf41kY1dbPT
         Az2YTmBmBe5x538dT+JRe1+JYJCz1FoZpsDQi9caft0FfB24tBWxwTJv5idXE3tCj309
         ndFGbbBo2539UPe3H3O748UbjUEB5fXovu/9xWmEfhXYjNsDa8MGUA7FNgzTEwcV2NYx
         BzUCxvrUpvXfcEOn53rFrUqaBy+pwlNLr7oHR8TPl+xrEZ1Otp/fmWcn5hIPL8+9gurK
         qq05lb0/OOuJZi6nG1tjGqZ27/O0Si7Z+rZrnHkVNiZ1eEaLz2uJksbogv7Sccdikqvu
         +sog==
X-Google-Smtp-Source: APXvYqxY66JUV3S/EHKt8chK3vxOG3tpmuDiZ0EEFbAfPD2vCxwBJVAqoqvpolQPE+tgSK7CerPsJg==
X-Received: by 2002:a19:5507:: with SMTP id n7mr15109749lfe.140.1556630645642;
        Tue, 30 Apr 2019 06:24:05 -0700 (PDT)
Received: from uranus.localdomain ([5.18.103.226])
        by smtp.gmail.com with ESMTPSA id s24sm7499626ljs.30.2019.04.30.06.24.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 30 Apr 2019 06:24:04 -0700 (PDT)
Received: by uranus.localdomain (Postfix, from userid 1000)
	id 7333A46019C; Tue, 30 Apr 2019 16:24:03 +0300 (MSK)
Date: Tue, 30 Apr 2019 16:24:03 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
To: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>, brgl@bgdev.pl,
	arunks@codeaurora.org, geert+renesas@glider.be, mhocko@kernel.org,
	linux-mm@kvack.org, akpm@linux-foundation.org,
	ldufour@linux.ibm.com, rppt@linux.ibm.com, mguzik@redhat.com,
	mkoutny@suse.cz, vbabka@suse.cz, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/3] mm: get_cmdline use arg_lock instead of mmap_sem
Message-ID: <20190430132403.GG2673@uranus.lan>
References: <20190418182321.GJ3040@uranus.lan>
 <20190430081844.22597-1-mkoutny@suse.com>
 <20190430081844.22597-2-mkoutny@suse.com>
 <4c79fb09-c310-4426-68f7-8b268100359a@virtuozzo.com>
 <20190430093808.GD2673@uranus.lan>
 <1a7265fa-610b-1f2a-e55f-b3a307a39bf2@virtuozzo.com>
 <20190430104517.GF2673@uranus.lan>
 <20190430105609.GA23779@blackbody.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190430105609.GA23779@blackbody.suse.cz>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 30, 2019 at 12:56:10PM +0200, Michal Koutný wrote:
> On Tue, Apr 30, 2019 at 01:45:17PM +0300, Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> > It setups these parameters unconditionally. I need to revisit
> > this moment. Technically (if only I'm not missing something
> > obvious) we might have a race here with prctl setting up new
> > params, but this should be harmless since most of them (except
> > stack setup) are purely informative data.
>
> FTR, when I reviewed that usage, I noticed it was missing the
> synchronization. My understanding was that the mm_struct isn't yet
> shared at this moment. I can see some of the operations take place after
> flush_old_exec (where current->mm = mm_struct), so potentially it is
> shared since then. OTOH, I guess there aren't concurrent parties that
> could access the field at this stage of exec.

Just revisited this code -- we're either executing prctl, either execve.
Since both operates with current task we're safe.

