Return-Path: <SRS0=F7ZL=RH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1AC1AC43381
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 19:53:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CAE7720663
	for <linux-mm@archiver.kernel.org>; Mon,  4 Mar 2019 19:53:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ikd1IfSn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CAE7720663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6B2228E0003; Mon,  4 Mar 2019 14:53:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65FE28E0001; Mon,  4 Mar 2019 14:53:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 54E388E0003; Mon,  4 Mar 2019 14:53:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 133CC8E0001
	for <linux-mm@kvack.org>; Mon,  4 Mar 2019 14:53:56 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id b12so5902747pgj.7
        for <linux-mm@kvack.org>; Mon, 04 Mar 2019 11:53:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=pxef9rdvAgoIkuYMMkRzJku1e77+iPvyDWdKoXG/LJc=;
        b=GVfmiv0dM8hmaESbCOKgzHwgloRKmkq57qynYRUcg8zZQ7tMzDvsLGYu3H9ABtEMWX
         D06sdi9sWbE8xJAGtv7balW7wb80QSHi2ZhEmVB95pY40HwVS5nYsow1RWE0LrjJbW2A
         zz/+I79uGWNn3oIY25zTpuQNjjvxSLO95xdnwmPj9NwdQ8oU0LgYH3m1bnSXLiWxJ2i8
         40/Cemm5RdC8byt2lpAJxv1BT+6rO60jgabS9WlEEMR4rZi82AaT+MZ0v8dOAUotjD8u
         tnTp57jPPnNl6mHr+WtFcnBT4EDqihHeavycJwCHm37G5d9n9Dr3sdY/rbWhSmeCSJrf
         fnfg==
X-Gm-Message-State: APjAAAXHtsB6VW82IEwnTXC7BOXMQLX7A438xoFpCYElpkE2CuoHtRJD
	pakY9LFU1irSUJ3hkp/B+1aZAWBWeL7Uh6HByTy8RbFtIKBcMsHJpRfThrrX/EzxfyeQdCFJVoz
	u67t/GQJnLpqsBM47B+TJjce2Or9KaBFza4AaO5BJbtXxDyzaTHYShrcIXFDVbFN4Ng==
X-Received: by 2002:a63:2907:: with SMTP id p7mr19881010pgp.161.1551729235750;
        Mon, 04 Mar 2019 11:53:55 -0800 (PST)
X-Google-Smtp-Source: APXvYqw7jE86dqbShhv3SYVvZljlPQ8Kz+aWvm9Qeg3urFgqB0KsLlKVVGsBulNy2+KKqvOu86Kv
X-Received: by 2002:a63:2907:: with SMTP id p7mr19880972pgp.161.1551729234811;
        Mon, 04 Mar 2019 11:53:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551729234; cv=none;
        d=google.com; s=arc-20160816;
        b=mZgMGayzlIsxnbQ+nZ/Q4cvNT2BuIsTmr4p3ky0Bt2NrjZjfZKy2fTW2f8U5jvhEDB
         28SgqTgiLNegzy7EmcWc5dBZV9uWU+4glVBqrFDVVP7Q5CwymywoBkw4kPwyS9CA2JOu
         msp96NWqP6EH5TkT+1Gu0fHfM69276fl+gJp059/d4cyuW2Ha5GVTlV+/0j0tDP58z8c
         d3ChqSDPjtlTzS/cD2qpapOdNevkXZjdXld7ULpPOFtjS5ox/FnZUx2aCNO4sHPhPbsT
         TpxrZMAQimVTSAlTfKLPIhSdiQFLRIk94pl7c21ZAqcHLLtj6SeqHNciRXz7x4VQPoE1
         /DHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=pxef9rdvAgoIkuYMMkRzJku1e77+iPvyDWdKoXG/LJc=;
        b=J31qzc/0o1NNqqQVFGgM1Fm+l1TdzNKnc+pPVz5rVtFT+l2PZykD099gPXFY1uco0G
         tkKsUmxSTOr7YPQybKtQU7ucqHmH7jXPmVrcgWqGbhb9XEiF2nk/ohe1gXaEGzBXbjU/
         bFYDraUOr0YSfhXSgHdYRtu1603ycEqef1uovoCjBNxieMhiFe3Co581y3JQgLmJ/Ofo
         mvekJbJvHSadOX7FLnBect9R7nYS/HeUvSaSriJLWRib7lBUYipJNcEeSFUI5L+FV7uQ
         OG3jUYAGcvyY6r/Yxu0BQJ0NMxfRKiq790LIjJBV5xLfPhX+VHiqlq3G9FnWxw5+vu9Y
         qMgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ikd1IfSn;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p91si6286124plb.69.2019.03.04.11.53.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Mar 2019 11:53:54 -0800 (PST)
Received-SPF: pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ikd1IfSn;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [77.138.135.184])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D7FF520657;
	Mon,  4 Mar 2019 19:53:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1551729234;
	bh=giA6uiGuJHeAeWZdu7sapZruLOXqUI5GTktC7GOoboA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=ikd1IfSntVPb0jCcMvR23FsW66mmRPg+Ya5PloGrKhnh5ubKMv9akgFuOcgUavQ5A
	 Gj1XK1+esNYB1ShEAhwM6zDPbgXRkAJ7E30YYkZPtpmh8Cy7xneTjGUuwbKJs0g1w+
	 NkIHa2hCd4BOJKrnwF8Xivzt/ziElTavVoXspJxY=
Date: Mon, 4 Mar 2019 21:53:51 +0200
From: Leon Romanovsky <leon@kernel.org>
To: john.hubbard@gmail.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>,
	Jason Gunthorpe <jgg@ziepe.ca>, Doug Ledford <dledford@redhat.com>,
	linux-rdma@vger.kernel.org
Subject: Re: [PATCH v3] RDMA/umem: minor bug fix in error handling path
Message-ID: <20190304195351.GK15253@mtr-leonro.mtl.com>
References: <20190304194645.10422-1-jhubbard@nvidia.com>
 <20190304194645.10422-2-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="SzQ167Kp6Zo0TWVn"
Content-Disposition: inline
In-Reply-To: <20190304194645.10422-2-jhubbard@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--SzQ167Kp6Zo0TWVn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Mar 04, 2019 at 11:46:45AM -0800, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
>
> 1. Bug fix: fix an off by one error in the code that
> cleans up if it fails to dma-map a page, after having
> done a get_user_pages_remote() on a range of pages.
>
> 2. Refinement: for that same cleanup code, release_pages()
> is better than put_page() in a loop.
>
> Cc: Leon Romanovsky <leon@kernel.org>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Doug Ledford <dledford@redhat.com>
> Cc: linux-rdma@vger.kernel.org
> Cc: linux-mm@kvack.org
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---
>  drivers/infiniband/core/umem_odp.c | 9 ++++++---
>  1 file changed, 6 insertions(+), 3 deletions(-)
>

Thanks,
Acked-by: Leon Romanovsky <leonro@mellanox.com>

--SzQ167Kp6Zo0TWVn
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBAgAGBQJcfYJPAAoJEORje4g2clinTO4P/0fRa+62AVNr9diB7JwN2q00
R/xwy4BeamgibjxK4ajFxNiuOe8kWL4M0xidWvIUIjhsljdVwNtyKUfH6SYi3YdM
chSj9iQeluos07CWbM9VPyGGBHZfQ13aTCy9P4tx/3JD+D03lZDBoP3tm93Mms4L
mxQwjxdBnBaquIpD98cIPZm31XXFUcRR/K7kMnPOBcXp+f2yx6DfJprm3tffb2Ke
9NgfVcIV03ZlfeC/NI2bj/MC17PZgZZBK2XqVTi7Wu0iYcy9J8nRlD2kVjNq/0rG
kxPMZ/O2K65gwnNSWtWPxsL074ekD4P5Mcn9D6Qa0MeFGotoGdDrEH9gJ4hmGFxG
1vgWYZRJ26JCoGASInbPKmPQBjC1bfHyUG83E8qfHHyTDzHj8ytcXXFtW2JMCSOi
nbqqX7ww8sXyAbCW2546yxCQ3AIL93g42gkwgGoxtQioovSkQ0eJoYSOT4cDxYEY
nsECMJGMhey3kqDDQGGvzZ31RZ7byaMQY/p6mc5hewRf8HOKHJEslsA1uTh5DkHq
j4duANKV3tZyw3sWQ+bf4s2NE0/EzH4wqIQWN2x7J6u+GDGM+JM9uLalXA+2tN+e
ks9z1cS4AXflaeIpV4q7p/bdqJf3JfrSsNY9WLFiryjF5q9c/4ejwYIRcsN1wq7D
v4WszJR2m5vaYxbOgMxo
=wIFY
-----END PGP SIGNATURE-----

--SzQ167Kp6Zo0TWVn--

