Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 25308C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 10:48:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2B0E208CA
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 10:48:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ea1jZnIt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2B0E208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7BC4D6B026E; Thu, 13 Jun 2019 06:48:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 76E136B026F; Thu, 13 Jun 2019 06:48:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65B1D6B0270; Thu, 13 Jun 2019 06:48:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 41F7A6B026E
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 06:48:27 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id v11so14568914iop.7
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 03:48:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=r080oZfzTGw4PlNPynE57ID3Ar9Ahtv7iL/o1sb0dx0=;
        b=dhKddthVU+wWUhAlm5gbuiYiTexQqOqLNie4qhaUgQEXcW39UIr7CuihbbqM+LdRxr
         rH+UFedsMyxy96jMyHeSR3f8/uiYGNam379bNMZYi6DdP3QLmXvYAt+Q251mIanyq3//
         I0dmiU2lcKXt/aL2XoVb28WOxHA+rJCZcF4ES8e0TsaSfGufLTTkDj5jAQlZ83u8zzW/
         PEaanFeYOIQDkYhYJzAX0eONRFkIaZE27BJE2mFEqTY3VsAXfSG+HKm4QPj26uZ10H02
         OLSCFICAJUmTL/eiiKSOOnJGXrTfrNH7ZvYpuQ1I9AqrLJe+Wf9Qy/qVALQGRAprmdEa
         kEyw==
X-Gm-Message-State: APjAAAV2HW/phGD4ALAnMCre2uJCNW17wMx/H4DGfoj3Gn2ExRMIu6H+
	To/uAx3HbdXx8p9HHFFbvRRSyuGf0/0KK9YL/AnuNcQSvu0L1zqYYthHG9d+/mI5SaqyhUMf2c1
	ATcHueOjdCrmu8Tg/uGj6NtIKrju5CjPFng+QHwq2+8Nx8ZYQ7ebJlLDJ7AdAKrG3sA==
X-Received: by 2002:a6b:e00b:: with SMTP id z11mr36034207iog.27.1560422906973;
        Thu, 13 Jun 2019 03:48:26 -0700 (PDT)
X-Received: by 2002:a6b:e00b:: with SMTP id z11mr36034171iog.27.1560422906322;
        Thu, 13 Jun 2019 03:48:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560422906; cv=none;
        d=google.com; s=arc-20160816;
        b=Br4QQK4HF+gqKxv5jA+PgwmwjeQVTfwvlV1Ds68B+R1U+m6exNUDEgh343hiphO9jq
         mItbtWpHxsvT40CVaKGom4lMYKdgFV9e/OtcElm9tDaRvMCOT67QFm1Y+nwYbhCqVOq/
         fQRAhkLFwnczwS2GGNKeEnh/5qRBaUnxvqYoUNC/VakHNqIHLqV9aFvSUdTymY6y7wS4
         Aj0IBCpZq4xD3jQzDZpT4PVmSezGjcGo/oGbEQDS/F9WgojF4L5ApKBc23lL+Krvjv2e
         SCHP7hpehYoN3f1R4+m5mG8laOnbP2RSr9u5v5isL+BnVgUo+Tq7RysGxC2v7QCXM78+
         ToXQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=r080oZfzTGw4PlNPynE57ID3Ar9Ahtv7iL/o1sb0dx0=;
        b=h5tVS3Ic0ByGJ+WXlke5I0nifo6u82mXqQAfngp5xudMELslEBxjga9kzKzccexB0r
         mk6WzVjpDS3N2MB8Ur+qbCHLCDkfMZVBQMsRCD5YJNwKTBMHMD7QLzIXoxITpzfLvMUd
         qVPrhYGRd6Jpu5d0gIV2054wbeMYRlIHQ9cjMHfw96zoMeEQcPN7UeN/jb/IVmTjjuWo
         Pqfn3nQXO1CgNz4tV9Esj38m4qkDfBvO6Q3XlU0ooc0utgCo72ybdD7Ram9NE1pEVGTi
         nI4RtgLQU0XyWdqXMydD+bvFWOFMSH1TAw4FbWPsZG6xcSkKzOjDIbldEV/QEeyTlZLf
         y2vA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ea1jZnIt;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l63sor1398524iof.27.2019.06.13.03.48.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Jun 2019 03:48:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ea1jZnIt;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=r080oZfzTGw4PlNPynE57ID3Ar9Ahtv7iL/o1sb0dx0=;
        b=ea1jZnItELWGPu6bHxAH/mmHocHpLmDlCmmIL2DjSC0Sx7VqH0Ol3gF4IcXRnmg9yM
         aWTdWeTpwVEK5N9uUKAIwBKzkS7fWKmfEIRb4V668/k38X++IMjsYMDuE8rpvMNrJuD9
         SClkbjfnhXP8mup6eWm/jU0ElYl3JLd+TbWXANcbeoSguFsZy3w4qGPngJy267Wcejx5
         187akwnOcJwaH/eSOVrX0sKBU0vjA0jroIvFe1D6BMipVWVj5sRIyhYESsYCEq6n5n0J
         xj2uKE6W4zMuksq/Co6nd2kNVQRx/U0czve+f4jvbuPoLaM87hVgS5WovV2HN3YRdQqk
         RO4Q==
X-Google-Smtp-Source: APXvYqzwF3HmOhVDJq8nYtvL9kM9vETJJiWfoMI/eBiNbY/jmRS0SgwDC9W3GIwckpCQG/bo7cqE02EF1cqQIUlZ06A=
X-Received: by 2002:a6b:4107:: with SMTP id n7mr10681260ioa.12.1560422905974;
 Thu, 13 Jun 2019 03:48:25 -0700 (PDT)
MIME-Version: 1.0
References: <1559725820-26138-1-git-send-email-kernelfans@gmail.com>
 <87tvcwhzdo.fsf@linux.ibm.com> <2807E5FD2F6FDA4886F6618EAC48510E79D8D79B@CRSMSX101.amr.corp.intel.com>
 <20190612135458.GA19916@dhcp-128-55.nay.redhat.com> <20190612235031.GF14336@iweiny-DESK2.sc.intel.com>
In-Reply-To: <20190612235031.GF14336@iweiny-DESK2.sc.intel.com>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Thu, 13 Jun 2019 18:48:14 +0800
Message-ID: <CAFgQCTsO-C=Fy6im+VQnNwvyp74tV2dZ-0Pa8QfFyFrBX8Ohvg@mail.gmail.com>
Subject: Re: [PATCHv3 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in get_user_pages_fast()
To: Ira Weiny <ira.weiny@intel.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.ibm.com>, 
	"Williams, Dan J" <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, 
	John Hubbard <jhubbard@nvidia.com>, "Busch, Keith" <keith.busch@intel.com>, 
	Christoph Hellwig <hch@infradead.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 7:49 AM Ira Weiny <ira.weiny@intel.com> wrote:
>
> On Wed, Jun 12, 2019 at 09:54:58PM +0800, Pingfan Liu wrote:
> > On Tue, Jun 11, 2019 at 04:29:11PM +0000, Weiny, Ira wrote:
> > > > Pingfan Liu <kernelfans@gmail.com> writes:
> > > >
> > > > > As for FOLL_LONGTERM, it is checked in the slow path
> > > > > __gup_longterm_unlocked(). But it is not checked in the fast path=
,
> > > > > which means a possible leak of CMA page to longterm pinned requir=
ement
> > > > > through this crack.
> > > >
> > > > Shouldn't we disallow FOLL_LONGTERM with get_user_pages fastpath? W=
.r.t
> > > > dax check we need vma to ensure whether a long term pin is allowed =
or not.
> > > > If FOLL_LONGTERM is specified we should fallback to slow path.
> > >
> > > Yes, the fastpath bails to the slowpath if FOLL_LONGTERM _and_ DAX.  =
But it does this while walking the page tables.  I missed the CMA case and =
Pingfan's patch fixes this.  We could check for CMA pages while walking the=
 page tables but most agreed that it was not worth it.  For DAX we already =
had checks for *_devmap() so it was easier to put the FOLL_LONGTERM checks =
there.
> > >
> > Then for CMA pages, are you suggesting something like:
>
> I'm not suggesting this.
OK, then I send out v4.
>
> Sorry I wrote this prior to seeing the numbers in your other email.  Give=
n
> the numbers it looks like performing the check whilst walking the tables =
is
> worth the extra complexity.  I was just trying to summarize the thread.  =
I
> don't think we should disallow FOLL_LONGTERM because it only affects CMA =
and
> DAX.  Other pages will be fine with FOLL_LONGTERM.  Why penalize every ca=
ll if
> we don't have to.  Also in the case of DAX the use of vma will be going
> away...[1]  Eventually...  ;-)
A good feature. Trying to catch up.

Thanks,
Pingfan

