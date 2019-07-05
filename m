Return-Path: <SRS0=h0DJ=VC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C8815C5B57D
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 05:22:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 86980218A3
	for <linux-mm@archiver.kernel.org>; Fri,  5 Jul 2019 05:22:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86980218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=perches.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1060C6B0003; Fri,  5 Jul 2019 01:22:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B6358E0003; Fri,  5 Jul 2019 01:22:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE6FD8E0001; Fri,  5 Jul 2019 01:22:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id D0BA06B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 01:22:47 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id g30so8387186qtm.17
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 22:22:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=jK5+snnq0EIuq4mXVsTR0Iixsj6PvWUO7DzQbhly8PM=;
        b=FWUwyDlMjgdz1GZqYKaZx/wleDREMBDEuw5rLQQhQakxweVIF5ByyuRwnwMm0RqmrZ
         oh7atEHhJXJNmJFh+zNrcvvzSkoHp4mTEO7aupzwlAnoIxol2AOUf5iWOlFaQ5QXGQbm
         UxToMbHhGZYGrfwesFH9zDl5x/Faoea4suiFL4wRN2iMaVKSxWNe76Ix5JHY9tW2ayFs
         vuUmZjEOpC7ZZ9AdAeyLZWtio6C4vyVbXDyRZGZUGrqcm8EqYYjKucIMuTurfSoMai1K
         N0Gm4HW52FROq9quw7dx5GP+flA35tmdPQ96muWfDb1dCKdV5hsjKP1n8KTG+JRzJgwe
         DYbA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 216.40.44.113 is neither permitted nor denied by best guess record for domain of joe@perches.com) smtp.mailfrom=joe@perches.com
X-Gm-Message-State: APjAAAXyz1aTNoG/txYSrkSIIAnJKeuNaIoqiAho3coxrs/ECjBFslTf
	DkAqzNazgH326rRyY0fJkO3QkdShd5G2cI8DB5JGkC/TsisfajQhmXyloNemdxAS3c/ZWwvn5hT
	qlrr9b99AXa5LsnpOE1HVnG6juc0NFnTiMo/dODzGz9rnhDul7K3ZKenXIai8gnw=
X-Received: by 2002:a37:6357:: with SMTP id x84mr1538950qkb.393.1562304167590;
        Thu, 04 Jul 2019 22:22:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwlmBTSPNwHAzl5LxXmQmYsfpL44+OTl17YZFT1DSzPvRJcSL/2mO6mCWgczcMbNw69wWLI
X-Received: by 2002:a37:6357:: with SMTP id x84mr1538921qkb.393.1562304167003;
        Thu, 04 Jul 2019 22:22:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562304167; cv=none;
        d=google.com; s=arc-20160816;
        b=Hz0g0uM+9mUmzFyBT/JJCno+sbdBLU8DSBqVn3bpM5dwY+Xc8JAaEgdO/BgSDY+sVx
         MQRQsscww+AX+pwUL2o8qXWXBePhum/97lkKZrtXurbdkwUWwGn84VRXjd8zN8znO9ye
         n6jm+PlNnPUfewH8znxr35Q7Hr+DCaeSaiCjOoOcj4/3cGO/+6iXxsxbsabVsl76jC7a
         ww9BzseRIVrI3mukN5/EkPwivBfwrF3wxJ3+4Mjp8XX6eAIRhL4ua8KJf177jyHYTW9d
         4C5Pap3jhNImjuEkzZyYA1JeIfJVuAqB1+M+wmduLOzwLcGHS/DVsbKaQRW9UyKmM3KO
         UtOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id;
        bh=jK5+snnq0EIuq4mXVsTR0Iixsj6PvWUO7DzQbhly8PM=;
        b=S0grF90Jdo1uMSJ0Qj0149nxGa6iUDJB1qlC7dUa8m26Kw7wkV1L84rvZAx3K77z5+
         NNUAp5qC8bfCRkGRNgWnXB20QTj9g1NCYNlSl5APp2uPtI/4Ll4dBCEPPzow7BDl3W2g
         b7F7q3N9kn94QYUvlS73OX2sqdu3ZWIySt814Bw5x+rtsbu5DWAxNrSB4hMK4F1udyVC
         cTAxm811n1pD75i1ug4msdnNai9HHibEBRHmMBMA+glH+8lYeCVKVLIQpL72yEKjZWPf
         K2hR+mT0XpXLZegVNmfH9r4MPqZ/5YNuAsUQdThpHm+QebEu8PVeZXps05LZcX0UD02J
         jUwA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 216.40.44.113 is neither permitted nor denied by best guess record for domain of joe@perches.com) smtp.mailfrom=joe@perches.com
Received: from smtprelay.hostedemail.com (smtprelay0113.hostedemail.com. [216.40.44.113])
        by mx.google.com with ESMTPS id v14si3542365qtv.201.2019.07.04.22.22.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jul 2019 22:22:46 -0700 (PDT)
Received-SPF: neutral (google.com: 216.40.44.113 is neither permitted nor denied by best guess record for domain of joe@perches.com) client-ip=216.40.44.113;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 216.40.44.113 is neither permitted nor denied by best guess record for domain of joe@perches.com) smtp.mailfrom=joe@perches.com
Received: from filter.hostedemail.com (clb03-v110.bra.tucows.net [216.40.38.60])
	by smtprelay07.hostedemail.com (Postfix) with ESMTP id 85F32181D3368;
	Fri,  5 Jul 2019 05:22:46 +0000 (UTC)
X-Session-Marker: 6A6F6540706572636865732E636F6D
X-HE-Tag: level75_17cfce2dff144
X-Filterd-Recvd-Size: 2521
Received: from XPS-9350 (cpe-23-242-196-136.socal.res.rr.com [23.242.196.136])
	(Authenticated sender: joe@perches.com)
	by omf03.hostedemail.com (Postfix) with ESMTPA;
	Fri,  5 Jul 2019 05:22:43 +0000 (UTC)
Message-ID: <5f4680cce78573ecfbbdc0dfca489710581b966f.camel@perches.com>
Subject: Re: mmotm 2019-07-04-15-01 uploaded (gpu/drm/i915/oa/)
From: Joe Perches <joe@perches.com>
To: Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell
	 <sfr@canb.auug.org.au>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>, Randy Dunlap
 <rdunlap@infradead.org>, Mark Brown <broonie@kernel.org>, 
 linux-fsdevel@vger.kernel.org, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linux-Next Mailing List
 <linux-next@vger.kernel.org>, mhocko@suse.cz, mm-commits@vger.kernel.org, 
 Michal Wajdeczko <michal.wajdeczko@intel.com>, Daniel Vetter
 <daniel.vetter@ffwll.ch>, Jani Nikula <jani.nikula@linux.intel.com>, Joonas
 Lahtinen <joonas.lahtinen@linux.intel.com>,  Rodrigo Vivi
 <rodrigo.vivi@intel.com>, Intel Graphics <intel-gfx@lists.freedesktop.org>,
 DRI <dri-devel@lists.freedesktop.org>, Chris Wilson
 <chris@chris-wilson.co.uk>
Date: Thu, 04 Jul 2019 22:22:41 -0700
In-Reply-To: <20190704220931.f1bd2462907901f9e7aca686@linux-foundation.org>
References: <20190704220152.1bF4q6uyw%akpm@linux-foundation.org>
	 <80bf2204-558a-6d3f-c493-bf17b891fc8a@infradead.org>
	 <CAK7LNAQc1xYoet1o8HJVGKuonUV40MZGpK7eHLyUmqet50djLw@mail.gmail.com>
	 <20190705131435.58c2be19@canb.auug.org.au>
	 <20190704220931.f1bd2462907901f9e7aca686@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
User-Agent: Evolution 3.30.5-0ubuntu0.18.10.1 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2019-07-04 at 22:09 -0700, Andrew Morton wrote:
> diff(1) doesn't seem to know how to handle a zero-length file.
> 
> y:/home/akpm> mkdir foo
> y:/home/akpm> cd foo
> y:/home/akpm/foo> touch x
> y:/home/akpm/foo> diff -uN x y
> y:/home/akpm/foo> date > x
> y:/home/akpm/foo> diff -uN x y
> --- x   2019-07-04 21:58:37.815028211 -0700
> +++ y   1969-12-31 16:00:00.000000000 -0800
> @@ -1 +0,0 @@
> -Thu Jul  4 21:58:37 PDT 2019
> 
> So when comparing a zero-length file with a non-existent file, diff
> produces no output.

Why use the -N option ?

$ diff --help
[...]
  -N, --new-file                  treat absent files as empty

otherwise

$ cd $(mktemp -d -p .)
$ touch x
$ diff -u x y
diff: y: No such file or directory


