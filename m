Return-Path: <SRS0=Pe7y=QC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F27FCC282C0
	for <linux-mm@archiver.kernel.org>; Sat, 26 Jan 2019 02:58:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93EF0218F0
	for <linux-mm@archiver.kernel.org>; Sat, 26 Jan 2019 02:58:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="Hp59EcXb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93EF0218F0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0C9BF8E00F8; Fri, 25 Jan 2019 21:58:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 079748E00F6; Fri, 25 Jan 2019 21:58:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA94F8E00F8; Fri, 25 Jan 2019 21:58:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id B74D08E00F6
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 21:58:18 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id x64so6094734ywc.6
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 18:58:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=uD+xbZtFCxl/EbX0cOF2Pe8a8lrRkz3suI1QjhUidtg=;
        b=DjJyVVxCzipvvGnYGIy/cWMoPh41l39M1KaOxUeGgIKnPps6nYKuv1+OvVixb+o+d/
         fzG70CEiUdNmJkgeldnVqGO4TEMOdc//FdctMkFdb2jAfE9E4x2sVQaBXGeKjOimz0gW
         DFaDPwYbcNGU0ngALu79tilf4H9cdqnC84onLKxrKsrfc+/Gu78ovkiIyL0pNYVM8Wst
         xKc42T/hL9e5JG4ymRN+6clK8wQv6tB3UQHfqMpaGdnq4xTEMYNabeSLxLoREGyRa79Q
         pUunjqrn4my5iXVHDU2DONUIiPRS89TFkq+egmgsdCbNS8nHPLtWOb9Zp6+d50xc4T48
         GGrg==
X-Gm-Message-State: AJcUukdgpdfUB75furr8WukGPcZaljK5celBMSPdwtlx6DVE82sdrL7h
	YGVg6p/+puBkO/vBAk/sxgpDcak8WNblFnCa0KQSJjXLqUBTz+lm4YfyyPt0e655hQlrKbKlGYw
	oMeb8FOWPtFKuxKQAHcA8rU7kadP9eIRgZTJZJaLKN1tzgXvcPmUaz0nOMaSh2T/3jA==
X-Received: by 2002:a0d:e156:: with SMTP id k83mr13423202ywe.219.1548471498346;
        Fri, 25 Jan 2019 18:58:18 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7JE2puqxdX5L0hqbV+4RGdFNciBmRX9M8/8Du6tvgPGPquxeIClDnzksiBpblWCke9ZD0F
X-Received: by 2002:a0d:e156:: with SMTP id k83mr13423179ywe.219.1548471497713;
        Fri, 25 Jan 2019 18:58:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548471497; cv=none;
        d=google.com; s=arc-20160816;
        b=aGlvbv6iy8+xHk9WzRSxWhv/6OvLsXap7Be3lQf/v+iD8gw8lrf4ZpnVmUk9wS1B/j
         ZsXtpLMRfM8cV/ABgS0NOf+q26S6fzUdHvxNjgywmCUkhAJjkxBaJiycD8xIPZK9mEyE
         b7fSO+gjncsJbPznwYCAvL/fytDvuq8B4ch+XdLvjSD3DaTv6beB2PrhTf7WT7sqTgTT
         OLORyH6xczC+okX3F9XF4yXvaR/5LA4cZIhC7/GWBLsDttH1nydbavs6q93EuZ3MF/UX
         6G7CeEJsyJIFK/Aj3aPOB8gwJatQBoDsrIBovR7aDlPzp70/HTV3qc3etnZEPbfinm4a
         fK0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=uD+xbZtFCxl/EbX0cOF2Pe8a8lrRkz3suI1QjhUidtg=;
        b=YW/equDd766pnYqR7K0NYPJKrFt+liq04gI02SU1mGt1ekit+JIaEa7PzmetoA1NA/
         VQ/ColQjOXhYeFgVdThg5xRbC6O9GoJ+euRUYjhz6oZcegT798K7B6CHH8btihWdbdr1
         Z6j3M4KZE1Q4WTZicFeAAbt4TGwmY3VynrEulcoB7vxLEBnvXbv8ZOA38J1UgDOHk++z
         tWstowAQC0JCUgOqH5+ZfSRzyL65jt4rYbjTG5K5QuUMvGc/nGcEDt6cRpuNU40pho6u
         IxcwBktX6+R7Gb3yQGVMIBXzoUE1fFBtq6MBsjkl/pHPUCHTiVSxFfyZT8UHSz6YwiUB
         +NAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Hp59EcXb;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id 62si15554948ybi.491.2019.01.25.18.58.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 18:58:17 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=Hp59EcXb;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c4bccc80000>; Fri, 25 Jan 2019 18:58:16 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 25 Jan 2019 18:58:16 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 25 Jan 2019 18:58:16 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Sat, 26 Jan
 2019 02:58:16 +0000
Subject: Re: [LSF/MM TOPIC] get_user_pages() pins in file mappings
To: Jan Kara <jack@suse.cz>, <lsf-pc@lists.linux-foundation.org>
CC: <linux-fsdevel@vger.kernel.org>, <linux-mm@kvack.org>, Dan Williams
	<dan.j.williams@intel.com>, Jerome Glisse <jglisse@redhat.com>
References: <20190124090400.GE12184@quack2.suse.cz>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <041368e5-7bca-4093-47da-13f1608b0692@nvidia.com>
Date: Fri, 25 Jan 2019 18:58:15 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190124090400.GE12184@quack2.suse.cz>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1548471496; bh=uD+xbZtFCxl/EbX0cOF2Pe8a8lrRkz3suI1QjhUidtg=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=Hp59EcXbiUb6mG3i1HemSvsw687q09VRtca1+hRD6ZlxFYc90RvcG01S2nT80qXsM
	 xwxY8Etl85hCeBqthKQ4tIM6Hohu3eFYPGzvmz17TAsQM0JL6H3gYUPADYpmrPT+sN
	 lVXnJbLJ82xiyx73H0Fw2MzRYObt8BazRVH6CFiVaSuspAh2xGdW7ntjCQmvyL+HWt
	 q05VQ+LzWf625RTYwC7QrtJ7mUfqPVI+27gJSzR4wHFfN+lDPfn3O4Cxs3XGIeHHmW
	 dEcpuw+n17kEiBJpToh0KwMAuFt11AAqH1SEM8HvA53gVLuDZ5I8pvqig1i1jzsQxI
	 u5Jn+o3CvWuQA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190126025815.S_uHE26aBeO2xz-hKn5zTyYDYIvZhjjBgPxU9Xt79Tw@z>

On 1/24/19 1:04 AM, Jan Kara wrote:
> This is a joint proposal with Dan Williams, John Hubbard, and J=C3=A9r=C3=
=B4me
> Glisse.
>=20
> Last year we've talked with Dan about issues we have with filesystems and
> GUP [1]. The crux of the problem lies in the fact that there is no
> coordination (or even awareness) between filesystem working on a page (su=
ch
> as doing writeback) and GUP user modifying page contents and setting it
> dirty. This can (and we have user reports of this) lead to data corruptio=
n,
> kernel crashes, and other fun.
>=20
> Since last year we have worked together on solving these problems and we
> have explored couple dead ends as well as hopefully found solutions to so=
me
> of the partial problems. So I'd like to give some overview of where we
> stand and what remains to be solved and get thoughts from wider community
> about proposed solutions / problems to be solved.
>=20
> In particular we hope to have reasonably robust mechanism of identifying
> pages pinned by GUP (patches will be posted soon) - I'd like to run that =
by
> MM folks (unless discussion happens on mailing lists before LSF/MM). We
> also have ideas how filesystems should react to pinned page in their
> writepages methods - there will be some changes needed in some filesystem=
s
> to bounce the page if they need stable page contents. So I'd like to
> explain why we chose to do bouncing to fs people (i.e., why we cannot jus=
t
> wait, skip the page, do something else etc.) to save us from the same
> discussion with each fs separately and also hash out what the API for
> filesystems to do this should look like. Finally we plan to keep pinned
> page permanently dirty - again something I'd like to explain why we do th=
is
> and gather input from other people.
>=20
> This should be ideally shared MM + FS session.
>=20
> [1] https://lwn.net/Articles/753027/
>=20

Yes! I'd like to attend and discuss this, for sure.=20

Meanwhile, as usual, I'm a bit late on posting an updated RFC for the page
identification part, but that's coming very soon.


thanks,
--=20
John Hubbard
NVIDIA

