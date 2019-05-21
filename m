Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20E02C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 10:53:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6EA121773
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 10:53:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kqar2URp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6EA121773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 544306B0003; Tue, 21 May 2019 06:53:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F4F46B0005; Tue, 21 May 2019 06:53:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 397AB6B0006; Tue, 21 May 2019 06:53:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id EFD376B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 06:53:03 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id l16so12059579pfb.23
        for <linux-mm@kvack.org>; Tue, 21 May 2019 03:53:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=2Sic2O7wb52L5CR9NZn4I8czhdSoXaChDb/juZvSzjk=;
        b=O1zJF2f50c74qCt+GUQYrXXcVKeM8izhe+3LKCiZj8BWYeV9s0itWHkGZPiCIMiLpO
         LU4TjULZvjt+98V+eDF1cwtXpoS/deLuhMU9AgTdVJpjDvqZXaG4t4unIM/n0xtvxlC7
         GNopU/ueqyGjYGoz17G0/BCfbFwS/kLw1T2K6LuH+9qt/gD7Umqu9RhV1AfrkTqFYgpr
         N4KMYpfzaRnrRm4iDXK+GXkEWLnp7u6CTtoQS6GVBJ+hmHm7VxZtrzT1PwzazOzz9UzK
         oKEMbh/grLA/aTLPCCHPPRO/I8zr9bqjYXtumgIhya4WUlXYy1UFn750OsHsxOvvyNvf
         GL7A==
X-Gm-Message-State: APjAAAX9NioDfNGHRwtoU/7lGdRNI+tgnS56df1UjfNv6X7eChr4nPVH
	1qkdE0Tk8x5nhy3X0caFDc8XcDolcp1bcRs+EKqpwBa6RxnksJrke+9SHsfJqXxu5pzih8ixUuq
	EHchU9UCX4HV1IiOgju9KBvHrXaZlG/9yqA+jKozd44/koCexpaFTFWO0ZjKPaFc=
X-Received: by 2002:a17:902:2d:: with SMTP id 42mr82890448pla.34.1558435983648;
        Tue, 21 May 2019 03:53:03 -0700 (PDT)
X-Received: by 2002:a17:902:2d:: with SMTP id 42mr82890400pla.34.1558435983032;
        Tue, 21 May 2019 03:53:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558435983; cv=none;
        d=google.com; s=arc-20160816;
        b=i5n4MvXOHNb71DDx4ZxuSsrlz7DCfcxeLfE/55Qf0eCVJpK3ifF5EAFzB1tv8bAkGk
         E9BZycAiq3ZTFUAd3TbjKxHgXTYhwDksXNSmCGPpVxj0DuqRsTDCVaUC2O9o3N6LDpB9
         HUDnmyfMEHGcv8zHQP4UqvhihQZVS9e5ONoivbG4NrbvRSPNxICjx5MRFaS8OUbP3Wru
         7koBhNP9DQ9XvspWKuC57iqfavcwO7KpLpDS4fPCKVbRi49SMonENkmm7ns6Wz8HEmeK
         YMvwSi0nvh9PX88D6Rt0CnWWF5eKebyoNbSfz9l2HkjWN4Ll12e4775qrOddo3PvNpxX
         dFOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=2Sic2O7wb52L5CR9NZn4I8czhdSoXaChDb/juZvSzjk=;
        b=Edtpe8aJhTzkN23zPSxhW06QY4JO/xr21CRdgKRMKczVSlg5/Q0TUeL2/DQFYZGxed
         aqHjEzplUuOrbcbUyl4CnJeq52cSQYq3zkdhkP7CE0nIOUBtmKS7LngbzophWVb5qIv3
         9s1NaMW8HXAupIYDDrerCW8mhD8+B1oh7wMDdBrvkXki5YyfAmGZaiyLVa0DnrTsHdXL
         +m8m+1KnJhPtjohGewTbEVPaK1twuPtER9YN9VMuMMe8V3nb3sp+xAQjwRWjSBeyCcB5
         YtdtemmaGqlspDYQQlSk+MRGtU8ndVaWqw73Gm5T9OktZnTzWncLhx/6wqFkrr34/qm7
         sfQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kqar2URp;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i21sor20924698pgl.11.2019.05.21.03.53.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 03:53:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kqar2URp;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=2Sic2O7wb52L5CR9NZn4I8czhdSoXaChDb/juZvSzjk=;
        b=kqar2URpzHjwHZxhz9FhJySyjNcvp48Yvzwkmxf2VubqeURESj6Vff0i/jsIthS7y9
         fPRjulw8tqg5W/oB23bfQ6UFnd8nscb2aa5s8AAzR6x2gUQbSsbmCcBbB7K1Uh/hzbiv
         ZeoxCNKSzYQ80A1lxxKgGkbjkN61+GLe0vQUUtixqAl/tDRPbShOiB0e1oWE/ejNmBFv
         dqBUvs9CRSKIAN4+yxm1aYazKW+oNgGlzkPpuhdWb4Z3w7wGKiYDfQlj3WlYFi/as9VJ
         VFMSyRQc0lXkd32xUqS1qV7HC6vxnJFGeLEI1qV1TDkfxSHCiLUZ0ohK/bMC56iKFykQ
         9XTA==
X-Google-Smtp-Source: APXvYqzWwsWL/43VXabxfdXeVLd95/lm6etnN5YVFlIWX66F8XbYX0NSYXLCPcewwlk31OvvzN3rhw==
X-Received: by 2002:a63:ba5a:: with SMTP id l26mr80865856pgu.183.1558435982668;
        Tue, 21 May 2019 03:53:02 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id j64sm37602676pfb.126.2019.05.21.03.52.58
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 21 May 2019 03:53:01 -0700 (PDT)
Date: Tue, 21 May 2019 19:52:56 +0900
From: Minchan Kim <minchan@kernel.org>
To: Oleksandr Natalenko <oleksandr@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 4/7] mm: factor out madvise's core functionality
Message-ID: <20190521105256.GF219653@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-5-minchan@kernel.org>
 <20190520142633.x5d27gk454qruc4o@butterfly.localdomain>
 <20190521012649.GE10039@google.com>
 <20190521063628.x2npirvs75jxjilx@butterfly.localdomain>
 <20190521065000.GH32329@dhcp22.suse.cz>
 <20190521070638.yhn3w4lpohwcqbl3@butterfly.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521070638.yhn3w4lpohwcqbl3@butterfly.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 09:06:38AM +0200, Oleksandr Natalenko wrote:
> Hi.
> 
> On Tue, May 21, 2019 at 08:50:00AM +0200, Michal Hocko wrote:
> > On Tue 21-05-19 08:36:28, Oleksandr Natalenko wrote:
> > [...]
> > > Regarding restricting the hints, I'm definitely interested in having
> > > remote MADV_MERGEABLE/MADV_UNMERGEABLE. But, OTOH, doing it via remote
> > > madvise() introduces another issue with traversing remote VMAs reliably.
> > > IIUC, one can do this via userspace by parsing [s]maps file only, which
> > > is not very consistent, and once some range is parsed, and then it is
> > > immediately gone, a wrong hint will be sent.
> > > 
> > > Isn't this a problem we should worry about?
> > 
> > See http://lkml.kernel.org/r/20190520091829.GY6836@dhcp22.suse.cz
> 
> Oh, thanks for the pointer.
> 
> Indeed, for my specific task with remote KSM I'd go with map_files
> instead. This doesn't solve the task completely in case of traversal
> through all the VMAs in one pass, but makes it easier comparing to a
> remote syscall.

I'm wondering how map_files can solve your concern exactly if you have
a concern about the race of vma unmap/remap even there are anonymous
vma which map_files doesn't support.

> 
> -- 
>   Best regards,
>     Oleksandr Natalenko (post-factum)
>     Senior Software Maintenance Engineer

