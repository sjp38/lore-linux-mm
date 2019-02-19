Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F616C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 18:21:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 398B52089F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 18:21:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="XqdOb1Hp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 398B52089F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C839F8E0003; Tue, 19 Feb 2019 13:21:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C32748E0002; Tue, 19 Feb 2019 13:21:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B215A8E0003; Tue, 19 Feb 2019 13:21:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 893F78E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 13:21:30 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id e1so4395560qth.23
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 10:21:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=p6lqVzmk8BbYgpS5Fe6dhIFelOTXP4KvzWcleogBENs=;
        b=Ltygkc6uTd3mH0uRsOWWiwamMD7Cy++DoI79wVR69ajgcDLbQcXCmVnbwwnIuKExKv
         AJBQEgXberEUkWwvRqYAgfhN6VWXARt3uOHv3dHwj5rW3cGPCQHt0UE81PlDQN35uuZl
         mK8FGGRJcBQK6bqmj06qFhvWSvJ3T/D5/g23Y0S9+AzNr9HkzEbyXmZWHSmmEm/HHFhH
         MSPYujIMbkHNpnhgjrYSxaWnkNu9C9KA6BrqQLhwIF1BNgZblTOgLuyETTucAWw06cOf
         Ze/csUSAHSXzPjOM/5HbOSsb9ORvQ6tWBzSGOHZjlkhnVHSXA2ldu1WjMtkd40w9zbV1
         A/AQ==
X-Gm-Message-State: AHQUAuZsmOnpKF+wDcqimpva21KGbeEXeJmoAds83Ea4nyXiWSiJbaRj
	A2wFlwBZNJ6PvcZNfwRyQrgySojEpl+jJxLJ+LQXbt+bz9rQLGD6QGBkmHoYEJ4n9o4+sJGbd2t
	YYH6WHT+4Q/+LTO0sokxVTcMV4/uorb9BxN8jZ/UlvaNltQmTRVvv7desxJvZ/lE=
X-Received: by 2002:ac8:fb0:: with SMTP id b45mr24425396qtk.146.1550600490271;
        Tue, 19 Feb 2019 10:21:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaWnMaWxUApm6t+OK4z7gOwINGGb5lmVsPWLikQXXDhDGPxICQqHHZZ9euh7qwG0EpxsSDI
X-Received: by 2002:ac8:fb0:: with SMTP id b45mr24425347qtk.146.1550600489459;
        Tue, 19 Feb 2019 10:21:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550600489; cv=none;
        d=google.com; s=arc-20160816;
        b=doKIwZauBXQ/oX1/jraC3tiTvs2sPO3EOptPZGepmcCzt7XuYfZhosPQx6lGPpDABb
         ZLyrKIZdUE+BE2Y/RDgMdwUtPio0XSM0UakXz7rafmX2SNHH9LD6cuDHIo9cE+mxqnTd
         GCHn4qRVzFuonShv9IAFtLuC6RzQfDmKEESuXpv5PuSZw3nZab0ExHBGOXmd5ZY/parr
         M4Imsf9q47loNG+aTz+gB7+L3gxOVKRo713OVBUrgvmY+l6FbJL+m3TvpTUFX6RMKClH
         8HfizFT42xWo7LsbpNQYLQlyUOQOJ9+IZAaZ6rM1De4GakAtOSEZI+pEh2x/NFLAH9do
         32BQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=p6lqVzmk8BbYgpS5Fe6dhIFelOTXP4KvzWcleogBENs=;
        b=o2v8NMTa17BrokVBBNVIw6pO55vEfyVvWnB7ESJeqbG3IRs2AKA/LRDlRfv5UUS5Ew
         nbl06FMMLLoMuRZ3OmG/9D7VdfMXx5WGwUgNSwIOoLRWrFXVNj7ODrflYZi5Ol/pJ5VU
         7arNjh1FXDmE3fst1+UH88YTTybYcoHdQMoBl7ctGBcCwFR9+lniZmjSjfRwi5AcCyQQ
         QZmYU/4EXsJmlV/ua7V1xwz+ku4cjJkpSwmyX03HHvrfsNv3e1JRnQ7SR/xsjQvROckn
         9rRSvZPGHP+ngOrjuuV6Gum/L/6iYgw1mCwDFKHcB8NrFBCb2dRTGZc+9BLnuaHpIm4I
         K7FA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=XqdOb1Hp;
       spf=pass (google.com: domain of 0100016906fdc80b-4471de43-3f22-45ec-8f77-f2ff1b76d9fe-000000@amazonses.com designates 54.240.9.31 as permitted sender) smtp.mailfrom=0100016906fdc80b-4471de43-3f22-45ec-8f77-f2ff1b76d9fe-000000@amazonses.com
Received: from a9-31.smtp-out.amazonses.com (a9-31.smtp-out.amazonses.com. [54.240.9.31])
        by mx.google.com with ESMTPS id z186si6309806qkd.68.2019.02.19.10.21.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 19 Feb 2019 10:21:29 -0800 (PST)
Received-SPF: pass (google.com: domain of 0100016906fdc80b-4471de43-3f22-45ec-8f77-f2ff1b76d9fe-000000@amazonses.com designates 54.240.9.31 as permitted sender) client-ip=54.240.9.31;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=XqdOb1Hp;
       spf=pass (google.com: domain of 0100016906fdc80b-4471de43-3f22-45ec-8f77-f2ff1b76d9fe-000000@amazonses.com designates 54.240.9.31 as permitted sender) smtp.mailfrom=0100016906fdc80b-4471de43-3f22-45ec-8f77-f2ff1b76d9fe-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1550600489;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=p6lqVzmk8BbYgpS5Fe6dhIFelOTXP4KvzWcleogBENs=;
	b=XqdOb1HpyInkoL7vX/SzQFu5Hry9FtDDWuKnY7KQaXCkn5pVhDcALB+lq1WMllIU
	gaMcjGNQjc+IkP+i+eFfS0gSjncai6x57qnFhRHiqPqxTej9GiZKCTQmBZ0gUmOyjx2
	Qd5kHTAmilu/cHK4u07AMvPqEodw0FETOLEoneto=
Date: Tue, 19 Feb 2019 18:21:29 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Michal Hocko <mhocko@kernel.org>
cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Subject: Re: Memory management facing a 400Gpbs network link
In-Reply-To: <20190219173622.GQ4525@dhcp22.suse.cz>
Message-ID: <0100016906fdc80b-4471de43-3f22-45ec-8f77-f2ff1b76d9fe-000000@email.amazonses.com>
References: <01000168e2f54113-485312aa-7e08-4963-af92-803f8c7d21e6-000000@email.amazonses.com> <20190219122609.GN4525@dhcp22.suse.cz> <01000169062262ea-777bfd38-e0f9-4e9c-806f-1c64e507ea2c-000000@email.amazonses.com> <20190219173622.GQ4525@dhcp22.suse.cz>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.19-54.240.9.31
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000023, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Feb 2019, Michal Hocko wrote:

> > Well the hardware is one problem. The problem that a single core cannot
> > handle the full memory bandwidth can be solved by spreading the
> > processing of the data to multiple processors. So I think the memory
> > subsystem could be aware of that? How do we load balance between cores so
> > that we can handle the full bandwidth?
>
> Isn't that something that poeple already do from userspace?

Yes. We can certainly do a lot from userspace manually but this is hard
and involves working around memory management to some extend. The higher
the I/O bandwidth become the more memory management becomes not that
useful anymore.

Can we improve the situation? A 2M VM was repeatedly discussed f.e.

Or some kind of memory management extension that allows working with large
contiguous blocks of memory? Which are problematic in their own
because large contiguous blocks may not be obtainable due to
fragmentation. Therefore the need to reboot the system if the
load changes.

> > The other is that the memory needs to be pinned and all sorts of special
> > measures and tuning needs to be done to make this actually work. Is there
> > any way to simplify this?
> >
> > Also the need for page pinning becomes a problem since the majority of the
> > memory of a system would need to be pinned. Actually the application seems
> > to be doing the memory management then?
>
> I am sorry but this still sounds too vague. There are certainly
> possibilities to handle part the MM functionality in the userspace.
> But why should we discuss that at the MM track. Do you envision any
> in kernel changes that would be needed?

Without adapting to these trends memory management may become just a
part of the system that is mainly useful for running executables, handling
configuration files etc but not for handling the data going through the
system.

We end up with data fully bypassing the kernel. Its difficult to handle
that way.

Sorry this is fuzzy. I wonder if there are other solutions than those
that I know of for these issues. The solutions mostly mean going directly
to hardware because the performance is just not available if the kernel is
involved. If that is unavoidable then we need clean APIs to be able to
carve out memory for these needs.

I can make this more concrete by listing some of the approaches that I am
seeing?

F.e.

A 400G NIC has the ability to route traffic to certain endpoints on
specific cores. Thus traffic volume can be segmented into multiple
streams that are able to be handled by single cores. However, many
data streams (video, audio) have implicit ordering constraints between
packets.


