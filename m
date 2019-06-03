Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 354AAC46470
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:05:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C18D620828
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 04:05:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RmVKplRe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C18D620828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 246C16B000A; Mon,  3 Jun 2019 00:05:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D01D6B000C; Mon,  3 Jun 2019 00:05:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 06F946B000D; Mon,  3 Jun 2019 00:05:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id DB43C6B000A
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 00:05:23 -0400 (EDT)
Received: by mail-it1-f199.google.com with SMTP id o128so14119748ita.0
        for <linux-mm@kvack.org>; Sun, 02 Jun 2019 21:05:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=bSsDlepu/Gv2h+jW37zv087KL7ej7kJEQqTYULWSEk0=;
        b=R7nJyfnhcuQEPcyBnieZ9EQLXwJ6G8AT6jOudaOLhtf+nhsQqEuGDxJRpJx43TyZ1Z
         YB0/W3tSy7L5fXYpTcPEfPcTr7W+65A5xj4ofhUi5q8DqrP9c1YFIdGyFbaIOKq6qfWA
         JcbfXlcm2d/neTFYIOJlgpG6yAUn1GhH4A/46LqVnGMkdhVg2avrN3REM3O5VT0tJp4Y
         uVa0SqhS3xYljEmF6s443+EluTDBzQJ8e9OUhGipYSIjsfM/Px6PRtuhEHxapKsFqLtv
         RrLQhdDldcwlfPh+hYhKlgvM46xpp9lz5Bab0YXOZeYWhn6Y8dIuK/XUftgSuhQF4s2p
         cZtQ==
X-Gm-Message-State: APjAAAWuSx3QkvvLhIHAc8NM7JgPSThHndlGsOcJIw1B3t1jnWbPtjn+
	OUVqf/ut301Cvq+AlJTmYk3yN1uXZh1VB5zVZoz2nAoT/Xx5W2CBY6ffh8m88oG0vVe+asZVLXp
	/Z4DMt0NfCe+/ditWmlufOQYYOxJBDMXmD+NTyySi6tr+6npaqelwTPQWqCd+5yJyCA==
X-Received: by 2002:a02:ccb8:: with SMTP id t24mr15830460jap.59.1559534723653;
        Sun, 02 Jun 2019 21:05:23 -0700 (PDT)
X-Received: by 2002:a02:ccb8:: with SMTP id t24mr15830439jap.59.1559534723038;
        Sun, 02 Jun 2019 21:05:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559534723; cv=none;
        d=google.com; s=arc-20160816;
        b=eEzTYMWsfRaQapCGrXpYPFZ+n7kbfPuiyw3mb+UR+64AwJ5x3I9ZLoBRIQ7k6zNNAw
         ALWaGxrwgSfM9cgu681uHdo0b0gLLqEV4Zqu5lfSuMGj10TtbFkRU+hoMNJgWar9txcs
         f8LIdmc4lRnbgTfZsIwlDkMPU3uvkrPq8EuDlG3xzQfMxbszT+/1Y5qiGwlA+ExPSN/t
         zKUIbyx6hbI6VqQE0JDpWoITkW1gwmJP9uO2Kn4swVO6EIcTCJqyQ22Mw1FMfYqecvVJ
         euFzh7DvuYlPNlWj4zmaqlhcLmQ3Rn681HRxRy0MBvk7Yoo3KghEoyMhtr43KpYrfgrP
         /EsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=bSsDlepu/Gv2h+jW37zv087KL7ej7kJEQqTYULWSEk0=;
        b=YGOgaJnt1gjPntAMyeI7gshR0qKFkFWRnY9UeiCx/vU8KzjpCD5s/34VTRs2rEFeBy
         DD6DP1cmahpat59fWKDxguz7qEbepdEXLXSHxVskCRQHzX0e3CGoXpayC6BvyGvgeVOz
         Ly5TWg2HO0ebbyq4DEz8/M3I5BjQhQhqlhSLAiVwGgTjVd643nmLIosCYMYJW4pI2zl1
         9ZrjviSJTUkECp7ZPcYv/EJN3U63RES3xrvGy6F+E4ESfAS945adPHDYqFpQ/X0G/An8
         sQuWYgC2c4+DG130+ukI+ra0auFWNr/qn9emrlXfktQjhYV6x05yQ9ZKaCmS8Wi+g3hU
         BKjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RmVKplRe;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d18sor333980ion.88.2019.06.02.21.05.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 02 Jun 2019 21:05:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RmVKplRe;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=bSsDlepu/Gv2h+jW37zv087KL7ej7kJEQqTYULWSEk0=;
        b=RmVKplReHg0sL2j2EUBICn8EXrzONwvrUn2mMxUBdCYefsBuBJKkosK4yAGfCiGUcx
         9aHC80EcMn0EeE3jSkwaIPZsxZg4dPeStRsG1pYO3VB7iM/nnwdfl3Zl0YtR8pnEMvO5
         X5uGwpChIw8jwNCQP8KOaV5bkWiOb7tPNiq5Y/l+ANODYt62XJbL5Wb2C9YU2ZlLL94L
         jWj/p4FoYnq75s2xSMMcAvVRw9X3UdxaDw2iojoAm9Lmahc3mgvn9qTOLXRl0ClqLgkG
         posT3/22lEQqVXi13RGA4YzRiswNmBNj9bVK50RNQbAxKL1Dpp1FkTYuFn2/pHxdNXzy
         4Jqg==
X-Google-Smtp-Source: APXvYqxmU/Kryj20Rs1ffPcWzCCAZzKVb0we2q0TWbrrO4z5swArh/gIW5kqLqMWArYz4SlyKxpfhGgArRMXe0deVpo=
X-Received: by 2002:a5e:d70c:: with SMTP id v12mr13169113iom.12.1559534722712;
 Sun, 02 Jun 2019 21:05:22 -0700 (PDT)
MIME-Version: 1.0
References: <1559170444-3304-1-git-send-email-kernelfans@gmail.com>
 <20190530214726.GA14000@iweiny-DESK2.sc.intel.com> <1497636a-8658-d3ff-f7cd-05230fdead19@nvidia.com>
 <CAFgQCTtVcmLUdua_nFwif_TbzeX5wp31GfTpL6CWmXXviYYLyw@mail.gmail.com> <20190531171336.GA30649@iweiny-DESK2.sc.intel.com>
In-Reply-To: <20190531171336.GA30649@iweiny-DESK2.sc.intel.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Mon, 3 Jun 2019 12:05:11 +0800
Message-ID: <CAFgQCTsWN6g__pF71qo1VAviT+98LEX6d9WLx2Lk7QktcciPqA@mail.gmail.com>
Subject: Re: [PATCH] mm/gup: fix omission of check on FOLL_LONGTERM in get_user_pages_fast()
To: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>, linux-mm@kvack.org, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.ibm.com>, 
	Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Keith Busch <keith.busch@intel.com>, 
	LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Jun 1, 2019 at 1:12 AM Ira Weiny <ira.weiny@intel.com> wrote:
>
> On Fri, May 31, 2019 at 07:05:27PM +0800, Pingfan Liu wrote:
> > On Fri, May 31, 2019 at 7:21 AM John Hubbard <jhubbard@nvidia.com> wrote:
> > >
> > >
> > > Rather lightly tested...I've compile-tested with CONFIG_CMA and !CONFIG_CMA,
> > > and boot tested with CONFIG_CMA, but could use a second set of eyes on whether
> > > I've added any off-by-one errors, or worse. :)
> > >
> > Do you mind I send V2 based on your above patch? Anyway, it is a simple bug fix.
>
> FWIW please split out the nr_pinned change to a separate patch.
>
OK.

Thanks,
  Pingfan

