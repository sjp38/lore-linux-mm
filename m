Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C24D2C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 14:11:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 827702087C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 14:11:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="t+FrO7/W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 827702087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 186FC8E0004; Tue, 12 Mar 2019 10:11:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1365D8E0002; Tue, 12 Mar 2019 10:11:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F40D88E0004; Tue, 12 Mar 2019 10:11:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id C97B98E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 10:11:25 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id e1so1849609iod.23
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 07:11:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=h7plJKK7CMAfrjjVhJmorscumrWINpd8NhhS/I9a1N4=;
        b=GTstgUVLFXGgufX1aGYAlMj7JdZEPJNbTLCfzNCtITZVyYO1a/DUjKSmxmIuZ2/N4W
         btwo5PA1rkYy4IR1eBuo9xSUrFz2UJmIl5RuZ/a4dHr3XGFYTB60CEvk0QIA/cb0NMtp
         Glft1mZQS+QDPSqbgXHIiJyjQCgV8nxNcNHtNci7rJDm3mXpBCKyEPZS28ZIBS3JeaNE
         S+p5HIGxMfNboBW07N176OUnLPg6cozJaa+Oq3PCDgwaIoGIiH+A2QjKqpys4lJ/xH6N
         75l8/nt51eQRkOU7mzY8tTzufvU3DdEsYs8GFC2PctOghrAj+SVarwsiEyCI7mHHPCF1
         OfVw==
X-Gm-Message-State: APjAAAWUPjzseqmtMxjvT1BtgddGV3chd/UsMXo59C5jeUVbbor9p7Cd
	Ak1oAAgBVXcjbQGmjeoaEUCvUblTwxbZ4WTOTHxmHdM11r/MJruS5gngKQ2TvUQ9qzdGmjxno2i
	7XzAUPR0l42gmYpZhGybG/0AMiMNLzTwYs/DJHJDVZJLLhxnHmdxkgHJW5vpynf/cDVPGtmvVCL
	CmNWqwRa2c0mbdXUUbrOqSBqkuVnBD2y/HxmzHLOuyvSLfZgEPbX6A/rAIjgt+lce9CVBV6ADLx
	9goeFDChBmGtHY++anUcju658qt1GS0VtmRdvemeAkJMG6KMIUcCVgXDX+7DEwTPBTkyLDhK0cv
	V59FdPEvefC1QMcfDpS6aEniuP6D8Ga2Y8FGXhl5jteojBnepQv/EqVUK3636LTbcjr4uxu9aIt
	k
X-Received: by 2002:a5e:c742:: with SMTP id g2mr5086780iop.56.1552399885585;
        Tue, 12 Mar 2019 07:11:25 -0700 (PDT)
X-Received: by 2002:a5e:c742:: with SMTP id g2mr5086726iop.56.1552399884705;
        Tue, 12 Mar 2019 07:11:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552399884; cv=none;
        d=google.com; s=arc-20160816;
        b=l69gLZ370E3yjic69f0f2xair3sTSjWJ6qOxZiWdnnfyUis4/NKp7R25OCqcTfCSRa
         Ke/dGJRRMaVby+QxYnIXCgY94THGaTuwuR++RuR3KPlgrTsBdgFMF0q30H2+xJSzpoZV
         NhvnSnCVvy9WqAKYIVeNmxgMFFAGKwPIFe2PoJ24WjwTCrq0nfoLF4x3oJ2kHWpa9ySF
         0fzjGpuWLxYLoKVSX63G5QL3w+YAqhvdRx+u7Z5OGxdFJdowpZf+gWFWDH1Uy5/iXeIv
         pbzI/NtKKZDljUnu6LhwvqcdSxyxqVWUrKPNKaJroa+0eTxYEUpxfwazPPXPV/FNSFi9
         Cd2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=h7plJKK7CMAfrjjVhJmorscumrWINpd8NhhS/I9a1N4=;
        b=NgZjaWdAhaTudNOYByWyXcs7IcHH01ti24PGXw44bx/OFSAk6hrEPwzgwYNGM63o0M
         K/PtXeKvYMORtUdTIHdRtxS5zNccpaGKlAe3XOM0nPmGg9Xv0S++6ReYKtoEvrozfamE
         UMPaYeyltCEe6ofs9fezhGC4M1pY00n8VZ1GO1KrFe2wQE0/XWB8xXgnxeyKNAyqYC7p
         Alh0C1tzbljnCuOMqAA6MCrHCpQac+3UWdhqXMBJuQ98J72QK5kE4VQpeKHxXc5va2AY
         axKccUJxRqzIoCTjhEQAtQ9lyRZwklB+aO5ek3FBTJPqp8Qbs+cLwNZ5pUlUIi8TZMiW
         CW9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="t+FrO7/W";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 139sor3961687ita.18.2019.03.12.07.11.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 07:11:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="t+FrO7/W";
       spf=pass (google.com: domain of laoar.shao@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=laoar.shao@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=h7plJKK7CMAfrjjVhJmorscumrWINpd8NhhS/I9a1N4=;
        b=t+FrO7/WFFNvRRbG9RKQnGKwO5ptegBmevRSjLlq+7PjEMRUwdPgKwe0hXNEUb/Cn6
         jim3QVCnCg4R4TWqZE5xvDaRi/dP5AQucB8wpSTpdV0uixu82PlOea9Fh1LFNSRiIn/Z
         aUPbsFd77rzjjGO1imhp385V1WblN5P7JFu/JJYZaydEkyyu2xHwbR9MwWds/aUQzGlb
         XGRmm/h38oXpONofHzxTvmxIn93AP8gLorGkTYJR+johXKhADDfK82ATA7PvFnFJh/D+
         4+wiqAhl7pDA7pvC/FhzCdGhoW7P5Sg92OIjPZ205JWeZaj/0gvhpJTqle+0Ff7CHNhR
         E5Gg==
X-Google-Smtp-Source: APXvYqymm3PEvBUzrEOe9DRQXJEMkaeITUai5JGJMbusc/VPi1OO4e9F1mdeyLn9p3ChVrjpKIjFtfyySdpQPkE10Ow=
X-Received: by 2002:a24:ee89:: with SMTP id b131mr348404iti.97.1552399884412;
 Tue, 12 Mar 2019 07:11:24 -0700 (PDT)
MIME-Version: 1.0
References: <1551425934-28068-1-git-send-email-laoar.shao@gmail.com>
 <20190311084743.GX5232@dhcp22.suse.cz> <CALOAHbDHM1mJ3X9x3vFpDagd81T+hrb7_xdqM12x6JQXuHqwxA@mail.gmail.com>
 <20190312133816.GR5721@dhcp22.suse.cz>
In-Reply-To: <20190312133816.GR5721@dhcp22.suse.cz>
From: Yafang Shao <laoar.shao@gmail.com>
Date: Tue, 12 Mar 2019 22:10:48 +0800
Message-ID: <CALOAHbA6FG97tkKLJQSYocmgYRYJGa=5ULV1AK92+dw=MtKZJA@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: show zone type in kswapd tracepoints
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Souptick Joarder <jrdr.linux@gmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, 
	LKML <linux-kernel@vger.kernel.org>, shaoyafang@didiglobal.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 12, 2019 at 9:38 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 12-03-19 19:04:43, Yafang Shao wrote:
> > On Mon, Mar 11, 2019 at 4:47 PM Michal Hocko <mhocko@kernel.org> wrote:
> > >
> > > On Fri 01-03-19 15:38:54, Yafang Shao wrote:
> > > > If we want to know the zone type, we have to check whether
> > > > CONFIG_ZONE_DMA, CONFIG_ZONE_DMA32 and CONFIG_HIGHMEM are set or not,
> > > > that's not so convenient.
> > > >
> > > > We'd better show the zone type directly.
> > >
> > > I do agree that zone number is quite PITA to process in general but do
> > > we really need this information in the first place? Why do we even care?
> > >
> >
> > Sometimes we want to know this event occurs in which zone, then we can
> > get the information of this zone,
> > for example via /proc/zoneinfo.
> > It could give us more information for debugging.
>
> Could you be more specific please?
>

Honestly speaking,  this one hasn't help us fix the real issue yet.

> > > Zones are an MM internal implementation details and the more we export
> > > to the userspace the more we are going to argue about breaking userspace
> > > when touching them. So I would rather not export that information unless
> > > it is terribly useful.
> > >
> >
> > I 'm not sure whether zone type is  terribly useful or not, but the
> > 'zid' is useless at all.
> >
> > I don't agree that Zones are MM internal.
> > We can get the zone type in many ways, for example /proc/zoneinfo.
> >
> > If we show this event occurs in which zone, we'd better show the zone type,
> > or we should drop this 'zid'.
>
> Yes, I am suggesting the later. If somebody really needs it then I would
> like to see a _specific_ usecase. Then we can add the proper name.

This 'zid' always seems like a noise currently.
I will send a patch to drop this one.

Thanks
Yafang

