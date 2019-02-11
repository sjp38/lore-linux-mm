Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=0.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	TRACKER_ID autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 154B2C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 15:34:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB695222A4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 15:34:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=stwm.de header.i=@stwm.de header.b="OxNU3yDc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB695222A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=stwm.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4F1698E00F2; Mon, 11 Feb 2019 10:34:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A0A48E00EB; Mon, 11 Feb 2019 10:34:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 391DB8E00F2; Mon, 11 Feb 2019 10:34:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id D00FF8E00EB
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:34:36 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id v24so1730584wrd.23
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 07:34:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:user-agent:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=19nuiacV19xmkpfgKbv+iH3PJpuaptko+I7zTJ2ft7c=;
        b=BgMxNojjM8YVmtysyLYTty4IMg4369sU7A0ys5W7cMhpHlqcZWyZsNDRk2KVqE16qo
         JbCZ2KFg7jdPzAa46IKbmqVAd0iukK1BUOtV8M3XZ4PxDw3rGuNMq3yD9AfrpVFkphPz
         m9c9oeXQdse9dzF8GAa59LKK5zvUYPwP25BK0Z+WIL/yMcnqo2Qi5qUz422zj4QdvLO/
         NmEdDNspL36HjpgX617MkK3pZOFhWCYKGoYcqsWmwDbTmkGkqihbRfGg2L8DTv/2Emnw
         Luo1+CUtSQrFOiq5Sw4d7vN6KeDe7rTbKF4wuMSxQ/Hsv4LGdgLmOJ4jkPo89cKi+63u
         eW9A==
X-Gm-Message-State: AHQUAuabsrFBg1h1tA9VLlAYwyjVQwW7mdHExBMo7rSV3iTFwo+KEkgd
	yXdsNjasAjBCdlRG5yWZ578DIPfspYU7UZBeruHYzeVWo/idFAaBqHKHst/gYOw7Gx6t7U/9asK
	rzWGYbaHG6y9FHVaWvO95vj5BRvII/OxlI+3UMsGIf5/pxcj09JStmzCBQ8KgrzN5iA==
X-Received: by 2002:adf:fd50:: with SMTP id h16mr29897085wrs.231.1549899276417;
        Mon, 11 Feb 2019 07:34:36 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZeqOEM17USSxGWek1T0xbbhXzg7+sTICQQws4ZSCwLWmL5E83oJnauAnsxNX/nSSxhVwZe
X-Received: by 2002:adf:fd50:: with SMTP id h16mr29897034wrs.231.1549899275495;
        Mon, 11 Feb 2019 07:34:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549899275; cv=none;
        d=google.com; s=arc-20160816;
        b=IuF1HGNfTTzp8DmfW8Z86Me4l3O8LkjTrlIYbftNthOo7pLUS9RF9HeoAl/k1JJ330
         WVszc/R9GjYibG4E9INAoVcnB8EIkC9YzxxPv4ychR+VHo4DkjpYucKRi42WJ+Y4mdMC
         MxOFk2NxB2s2N93Tr3ljzZsA5krst8xwI8hImJjrQJ8yexl4ov8IvU35qGFy64035qeC
         qdSSSKidth6Vdg8gUufvyBwbSBN8xrUa6iCOrUzIQQ1nPDPJsbfq8joZteIUJ+3hCSlu
         rxYHorb4ZSfaO5ZfnglzfOA0Hwh0LPG9SEJgeYNvvLoJ4MbALo0XUDHcW51dnxDJnqjD
         KYnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :user-agent:message-id:date:subject:cc:to:from:dkim-signature;
        bh=19nuiacV19xmkpfgKbv+iH3PJpuaptko+I7zTJ2ft7c=;
        b=UM3bdb67ELiqldjGURE0NA3Kh0gbe611yw/7AXmaJduV3JWGi24z0i2M4TFbRywHw3
         SLRzvuYnP2/6qGGIf2zWv4pJxPV514yvCfYxx3M66wKg9IRqg68CDJydxB55e/ct0j7t
         YQ6fJm+hsGoSUsa0Xx4JRrjeHO0BQeWSAnDMtfGycd2Mvk63BL74XaTPRggGj3IV2LcF
         OxXMVcybr6tVFs9u0kz2tzNVedWDgAtLQhd+e565qsUrFPtcITqONhKX4dwhkGYvmohK
         IhHXUyQgkwzcDe1GGb1DFiX9Kyd5R+Y58oL3PZU9Ff6HBQQ18WcIKbMM18HBpnJ7sbVL
         VUOw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@stwm.de header.s=stwm-20170627 header.b=OxNU3yDc;
       spf=neutral (google.com: 141.84.225.229 is neither permitted nor denied by best guess record for domain of linux@stwm.de) smtp.mailfrom=linux@stwm.de
Received: from email.studentenwerk.mhn.de (dresden.studentenwerk.mhn.de. [141.84.225.229])
        by mx.google.com with ESMTPS id p4si9139853wmc.85.2019.02.11.07.34.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 07:34:35 -0800 (PST)
Received-SPF: neutral (google.com: 141.84.225.229 is neither permitted nor denied by best guess record for domain of linux@stwm.de) client-ip=141.84.225.229;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@stwm.de header.s=stwm-20170627 header.b=OxNU3yDc;
       spf=neutral (google.com: 141.84.225.229 is neither permitted nor denied by best guess record for domain of linux@stwm.de) smtp.mailfrom=linux@stwm.de
Received: from mailhub.studentenwerk.mhn.de (mailhub.studentenwerk.mhn.de [127.0.0.1])
	by email.studentenwerk.mhn.de (Postfix) with ESMTP id 43yqbH0G0LzRhS4;
	Mon, 11 Feb 2019 16:34:35 +0100 (CET)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=stwm.de;
	s=stwm-20170627; t=1549899275;
	bh=19nuiacV19xmkpfgKbv+iH3PJpuaptko+I7zTJ2ft7c=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=OxNU3yDcaN3H1PrQOaftLhUJN35jnqGVr7zf3DIfQaerJ+PBnG72ioCK/o22gUoGI
	 mqCrhncgFmEv6eUGE8+1pv04CGWidvzpOwV+a970M56vbCBKRUaw7cYKbEmON9/E7b
	 wHPpgVbBgEEM6D81PEOtYaIUFC8KT0j92eqy5x04M1pNN+BdsQ3KLjdsl40KsMY7Vm
	 fxZXM6reSNRnSTFbLdun0Nd0DqFQs9vvZd6Lfo0xN2SO2ZMF/zwWWETX5+Q0Hcjz81
	 3SxMOhUGKQZMCBMTKR7OEsh8oroJ6yW2SNnqZv2xs91Nv6oPCK3CYJXIwi90YYDCJY
	 U0p2ouScLPNdQ==
From: Wolfgang Walter <linux@stwm.de>
To: Jan Kara <jack@suse.cz>
Cc: Dave Chinner <david@fromorbit.com>, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Chris Mason <clm@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, akpm@linux-foundation.org, vdavydov.dev@gmail.com
Subject: Re: [PATCH 1/2] Revert "mm: don't reclaim inodes with many attached pages"
Date: Mon, 11 Feb 2019 16:34:34 +0100
Message-ID: <2582452.8YSf1DXvRS@stwm.de>
User-Agent: KMail/4.14.3 (Linux/4.18.12-041812-generic; KDE/4.14.13; x86_64; ; )
In-Reply-To: <20190207102750.GA4570@quack2.suse.cz>
References: <20190130041707.27750-1-david@fromorbit.com> <20190131221904.GL4205@dastard> <20190207102750.GA4570@quack2.suse.cz>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Am Donnerstag, 7. Februar 2019, 11:27:50 schrieb Jan Kara:
> On Fri 01-02-19 09:19:04, Dave Chinner wrote:
> > Maybe for memcgs, but that's exactly the oppose of what we want to
> > do for global caches (e.g. filesystem metadata caches). We need to
> > make sure that a single, heavily pressured cache doesn't evict smal=
l
> > caches that lower pressure but are equally important for
> > performance.
> >=20
> > e.g. I've noticed recently a significant increase in RMW cycles in
> > XFS inode cache writeback during various benchmarks. It hasn't
> > affected performance because the machine has IO and CPU to burn, bu=
t
> > on slower machines and storage, it will have a major impact.
>=20
> Just as a data point, our performance testing infrastructure has bise=
cted
> down to the commits discussed in this thread as the cause of about 40=
%
> regression in XFS file delete performance in bonnie++ benchmark.

We also bisected our big IO-performance problem of an imap-server (star=
ting=20
with 4.19.3) down to

=09mm: don't reclaim inodes with many attached pages
=09commit a76cf1a474d7dbcd9336b5f5afb0162baa142cf0 upstream.

On other servers the filesystems sometimes seems to hang for 10 seconds=
 and=20
more.

We also see a performance regression compared to 4.14 even with this pa=
tch=20
reverted, but much less dramatic.

Now I saw this thread and I'll try to revert

172b06c32b949759fe6313abec514bc4f15014f4

and see if this helps.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts

