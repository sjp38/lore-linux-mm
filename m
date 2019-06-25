Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4383C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 17:01:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 369CD2080C
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 17:01:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ocl1bNLr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 369CD2080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 796EF6B0005; Tue, 25 Jun 2019 13:01:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 747A28E0003; Tue, 25 Jun 2019 13:01:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 635D78E0002; Tue, 25 Jun 2019 13:01:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 436366B0005
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 13:01:05 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id f22so27097484ioj.9
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 10:01:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=4nh5j4XcTvP6By9QhoNnt2Wmf1hC1P4k60SdPp76T0k=;
        b=rQwH+vgkP6DuQwhnR5DX83gQM2hTuE53bi7Gp3ecZO/OrGA+PKdPPm1z4ON7HaEAWK
         GSc1KmX7MCbSw3IbmPFUqPQQKPDLT5XIo2BngK8gian0FyGVMDRDCmN/ST95LW1YxW7D
         KKD+AvCeHVkswhQ+kBuk04NWky9NRr7OlXw+5pSaExw1vgi9o0PHtgBtDO7zS1G2J/P8
         6L6nSk442mfniBSZiXXyedO1Ji9kCV9rIY9zTIattO0nQeGK5sW0nEidYACUbV2GkdOv
         0sx4UTT1uRlQEL5moZDGKQYGZnZXdjdlLUKJt/GlOfhGfwsGWkQLB5osUSu0gsRi00q1
         6gsQ==
X-Gm-Message-State: APjAAAWdp6O7N6oacSwK3Lw183sleGo5uzrXn28an3ctcBXsktpuziee
	LR5m/JNvGBgeMcv6stDDLDRD2aaS5uIyc1OCCbwFhyUGJWQ6RmR6dCPy7jUKwoFxIelKTZBP6Iq
	YmFFJd3a+YhgfeYzGShlsAYJcaUEXsbyKX9QLly89c8PTOLjuuLYForMNpbM2PMxT+w==
X-Received: by 2002:a5d:87da:: with SMTP id q26mr46602981ios.193.1561482064940;
        Tue, 25 Jun 2019 10:01:04 -0700 (PDT)
X-Received: by 2002:a5d:87da:: with SMTP id q26mr46602860ios.193.1561482063810;
        Tue, 25 Jun 2019 10:01:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561482063; cv=none;
        d=google.com; s=arc-20160816;
        b=YnvxBNmarudBy7TpD4cDWM5T0YaauSy0Dg+E5r2NfT2waIg8B/obUqNK8iiO1XjKn8
         frAKhtfzJoq0xWlcbi7/F48njnHl7PdlLYFmugQFFIQdoPLW3cWLVxReNLWlkQPF5ibj
         NTxjoQ3uUhvRimuBG5selyBj0PCOvrE7ovXCoIWsD5VmW60sI9ErVkQKfjG4Nq4XDjwK
         4Xqc7SS9RMAW+RcebF6cLoXLfhUIgJ5jLQxgcfMGyYePXCOGE84YAiXvovioO7pE6y0E
         HWKBeoyvopvrCRXC63E/VV7x0ZWL3llfnOCQal0Tb6KCRar9k3p9npuDQNeHw8h2yQF9
         EdVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=4nh5j4XcTvP6By9QhoNnt2Wmf1hC1P4k60SdPp76T0k=;
        b=RaaScK7IZUqKw38IJFaI2ypZBx6GNEkEhGT+NfOnz/gN9HGVyA6i+7E6gzO/HFTIPR
         A7zI2rM9pOr3AmZQd5t69GbVTei6mUhwsvZmvhbkNA9rptwUy/1lpLUpVRwVPsB4JeHs
         iWGrpTuSqheH59lJDK0nPUTD2PqK8ll/VmskVQOte6wVVr2sF3Un4KV4qannj2r/H4VG
         bs0UXZcGonSZCP6AU7AQGXYHMh8JbnyRNCj1oigL15qtcT9rMwG3RK94fMgsdI8c9q+t
         7q5I+X0reehreIa17o96bOLlQePzTeIPXtL0lPctjE2iDyz5ih396cBezD/xfKAGfz9i
         hlkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ocl1bNLr;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h13sor10596635iom.138.2019.06.25.10.01.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 10:01:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ocl1bNLr;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=4nh5j4XcTvP6By9QhoNnt2Wmf1hC1P4k60SdPp76T0k=;
        b=Ocl1bNLr8OYzeu9TD1azuErTT8IzFHOcI287iJQWs6IMZ/x2MG20iUj2WdhhmYvmAv
         Zk5lyLTO6h+MThMdU2/+IIXgapLAdfy2/NzsZHUjjaHkdyR8SzJzifePWoWbt2Wk3V+V
         nAbOwcLUJ9Hzk/CkONjV89hTvByIB7QPw8pEzrfdP7W/CK2CUge/r97cvhG3Gy4B7CI6
         YHfgMuJdDTDFbHKdRWU1tXveDuOZHRJ5jeZpZQvhhX3oU5ZlvAibv+TUloulaHhRuw39
         FkQ4i8MfMB6AuCUZwqXTORgKRnBx9uEKm2Qe6caTvo6JaiEm28MA9JxSpIIvZ8onjSa3
         FiUw==
X-Google-Smtp-Source: APXvYqzlYWj2ApUnurVtHQQxOd0ZImZSLCuMNUPe0E/UsQDrF+TtQT0+vIgxTiOE1J5+2kko7cJoekjiCl+Pxhleo7k=
X-Received: by 2002:a6b:5106:: with SMTP id f6mr17350556iob.15.1561482063168;
 Tue, 25 Jun 2019 10:01:03 -0700 (PDT)
MIME-Version: 1.0
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
 <ff133df4-6291-bece-3d8d-dc3f12f398cf@redhat.com> <8fea71ba-2464-ead8-3802-2241805283cc@intel.com>
In-Reply-To: <8fea71ba-2464-ead8-3802-2241805283cc@intel.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Tue, 25 Jun 2019 10:00:51 -0700
Message-ID: <CAKgT0UdAj4Kq8qHKkaiB3z08gCQh-jovNpos45VcGHa_v5aFGg@mail.gmail.com>
Subject: Re: [PATCH v1 0/6] mm / virtio: Provide support for paravirtual waste
 page treatment
To: Dave Hansen <dave.hansen@intel.com>
Cc: David Hildenbrand <david@redhat.com>, Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>, 
	"Michael S. Tsirkin" <mst@redhat.com>, LKML <linux-kernel@vger.kernel.org>, 
	linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com, 
	Rik van Riel <riel@surriel.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com, 
	wei.w.wang@intel.com, Andrea Arcangeli <aarcange@redhat.com>, 
	Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 7:10 AM Dave Hansen <dave.hansen@intel.com> wrote:
>
> On 6/25/19 12:42 AM, David Hildenbrand wrote:
> > On 20.06.19 00:32, Alexander Duyck wrote:
> > I still *detest* the terminology, sorry. Can't you come up with a
> > simpler terminology that makes more sense in the context of operating
> > systems and pages we want to hint to the hypervisor? (that is the only
> > use case you are using it for so far)
>
> It's a wee bit too cute for my taste as well.  I could probably live
> with it in the data structures, but having it show up out in places like
> Kconfig and filenames goes too far.
>
> For instance, someone seeing memory_aeration.c will have no concept
> what's in the file.  Could we call it something like memory_paravirt.c?
>  Or even mm/paravirt.c.

Well I couldn't come up with a better explanation of what this was
doing, also I wanted to avoid mentioning hinting specifically because
there have already been a few series that have been committed upstream
that reference this for slightly different purposes such as the one by
Wei Wang that was doing free memory tracking for migration purposes,
https://lkml.org/lkml/2018/7/10/211.

Basically what we are doing is inflating the memory size we can report
by inserting voids into the free memory areas. In my mind that matches
up very well with what "aeration" is. It is similar to balloon in
functionality, however instead of inflating the balloon we are
inflating the free_list for higher order free areas by creating voids
where the madvised pages were.

> Could you talk for a minute about why the straightforward naming like
> "hinted/unhinted" wasn't used?  Is there something else we could ever
> use this infrastructure for that is not related to paravirtualized free
> page hinting?

I was hoping there might be something in the future that could use the
infrastructure if it needed to go through and sort out used versus
unused memory. The way things are designed right now for instance
there is only really a define that is limiting the lowest order pages
that are processed. So if we wanted to use this for another purpose we
could replace the AERATOR_MIN_ORDER define with something that is
specific to that use case.

