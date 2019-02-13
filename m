Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E43F7C10F00
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 23:07:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0546222A4
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 23:07:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="JpZ8ZbCo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0546222A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 58E7A8E0016; Wed, 13 Feb 2019 18:07:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53C698E0012; Wed, 13 Feb 2019 18:07:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42B9A8E0016; Wed, 13 Feb 2019 18:07:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 009B18E0012
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 18:07:30 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id o9so2766849pgv.19
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 15:07:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ycGZ/lql/XedLXMhQw613j8q5/nW7HtOXu0fJma7tbU=;
        b=kkV0QExES7lJ70L7uQ9Hk0PqeAVsqTtZul+5s8yQqWKsAxLgp2Ny9biGmWofH52+vM
         kZbd0ppUMyclm+ogDPy+dcdKw8BoiVGZCSglpze20W3is4SJ2xdzhX7D146I9wrzS8ah
         jpQ8aOpKv9f/7nNXlC83/iUKFdvp0FeswENBaIKRZh8ICOFyssrodl0EtR5Bjdcf1NIP
         tm4gkfp/jlSkvqKi2akhq3mYHQiyoGoU8o4i2+n+g5kawKfUxJ0bSm5RsHHy6QXjJ4Db
         f9iekdZYKev71J371uj1WByWvXacIJ9+5E/1KgghCAx/t8CXymvkjaF+pGScW0ykChg2
         YB+w==
X-Gm-Message-State: AHQUAua1fd6kEsAGbT0A6KTL5w8MndygopKjwPAArs2I1as7utwQckda
	hreX63Bq4Co0bzVHdn84YT4bnw2BkWMqmrry0AwFobn69XFEp/dN1hMQ4LrshXjk/ZtQl6yDbpX
	c51X5M1BJASbTt3iIvWUeMC27a7ii6ChaLH3JZHJDXUBt58lEeS0MeX4qxPYUoWPq00YM1kxoiK
	aB+IAuL/Fulv5YTIDaIQ4yWVeE9WmEJ1E+A4xuEpZKsKMwncy5e/8H42MHp/tXENiGoNHd87AQY
	SfN1AtV0ZwjWfJr2XnEYYhDpsrihImTPR6n2Y1SdhES9CSr2cP9ckJoWa+kVYUgiLHrYeguZeMY
	V0Tn1YEiN9dm/jN11uUQIjs/0T6ykbzi2o2RJiCNL0pXUe/fJEEaRqmML5SBTz2XgjGrSilJxyC
	T
X-Received: by 2002:a17:902:28aa:: with SMTP id f39mr651480plb.297.1550099250584;
        Wed, 13 Feb 2019 15:07:30 -0800 (PST)
X-Received: by 2002:a17:902:28aa:: with SMTP id f39mr651428plb.297.1550099249940;
        Wed, 13 Feb 2019 15:07:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550099249; cv=none;
        d=google.com; s=arc-20160816;
        b=vKuN6HI61iyjqXDMRoT0clClixR3myFvCxS7UM/U1sL5jXiiGMyJPAX3MtvWnGvDAI
         kYn71/s1Urie2UTbD6wo8yv8PbNJiHxQz0OOex0YnqPea/Ef9liFUU5L1dnazBxdHbFR
         TK3tiJAP9WM4Gfa5v6Yj3EaEa67BJV1VrU9CJ74JSu9fe20+c7C6BqIhq06IEKulJHoE
         vmvY6S/5chINGdlo1x8d1Div3191Q9G2n+DZsL/BCpvFOFJhoe8EpL4DzgPiDfAHlIFw
         s9xAtw/stksEqudohyViI5Ce8EyQqSFp37yZrPmnwCJ+h/z3Y6vrSYOXlYLamqSn0q80
         9trQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ycGZ/lql/XedLXMhQw613j8q5/nW7HtOXu0fJma7tbU=;
        b=s9pdqtvqerKsFD4TFYq8hVhvA3LOhAndMlHObnC23NldWaPEb7ZJLh80YbzfMKW23k
         uJEjDKDFT/A5bDA065qhw3B+IraPVoAAL8WqAoNKeO3Wz/2QnlfIMYOPX71/n8nbjQoz
         VYx1ZZGu3t0viuNDit0jORiLsmYQfjUeLCJY+6Jr0oY9wyLVa84vM2WW5scOPh/3YilF
         HoMxqudWPTqhNXE1DSIs28onp7yRzdYX1u889b6Jukv6moNywtUpHysLURVw/LxXzVga
         nUTGqM55YPV/5Hx8k3i07SCH8+OoxwtJ+cQ/GFl3PhrooXMjgWBxr8xF0qSe8HsIZQ0s
         5Iuw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=JpZ8ZbCo;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1sor946346pls.72.2019.02.13.15.07.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 15:07:29 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=JpZ8ZbCo;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ycGZ/lql/XedLXMhQw613j8q5/nW7HtOXu0fJma7tbU=;
        b=JpZ8ZbCoGmgsStGrD7Ces+eiaAcEBDwP2MwHm1odgXkmFHZ61NwFL4leS20cW9WLfo
         FGa7uTtaOlqE4a7hhtN87sFCdcCrbr3+9j+g8Zt/SEDaGmT1DL6reEqmJ+sl9zPfB/ZL
         sIvXBaZIjR95Sae1LORKUqxDVbVAdr+AtYHnQl+AMJJuZk44ObCM+ljD1a66/KrTAs1u
         uQuAyBu/AGqV21vCZmuyQyTqyTcG+0nfpmGMLnXNosPfVrazfmWI/04pmdJ2OPq1avXF
         +ffFBzKHBjoz5yrs/5QRZCMudXVQUio/NrXOJ/xwNF8mKZP97g59R7MdV+4bD0TjA6yW
         JyaQ==
X-Google-Smtp-Source: AHgI3IbZxmz9Cji7ywEHkD4zdpRd9ZWq16bVDbDKyOfZsY/wyvM5SVUNTc9mXDq5Bsx5HN2KKJx0pw==
X-Received: by 2002:a17:902:b489:: with SMTP id y9mr666527plr.193.1550099249465;
        Wed, 13 Feb 2019 15:07:29 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id k71sm454104pga.44.2019.02.13.15.07.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 15:07:28 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gu3cl-0001KE-SJ; Wed, 13 Feb 2019 16:07:27 -0700
Date: Wed, 13 Feb 2019 16:07:27 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Alex Williamson <alex.williamson@redhat.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org,
	dave@stgolabs.net, jack@suse.cz, cl@linux.com, linux-mm@kvack.org,
	kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
	linux-kernel@vger.kernel.org, paulus@ozlabs.org,
	benh@kernel.crashing.org, mpe@ellerman.id.au, hao.wu@intel.com,
	atull@kernel.org, mdf@kernel.org, aik@ozlabs.ru,
	peterz@infradead.org
Subject: Re: [PATCH 1/5] vfio/type1: use pinned_vm instead of locked_vm to
 account pinned pages
Message-ID: <20190213230727.GC24692@ziepe.ca>
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
 <20190211224437.25267-2-daniel.m.jordan@oracle.com>
 <20190211225620.GO24692@ziepe.ca>
 <20190211231152.qflff6g2asmkb6hr@ca-dmjordan1.us.oracle.com>
 <20190212114110.17bc8a14@w520.home>
 <20190213002650.kav7xc4r2xs5f3ef@ca-dmjordan1.us.oracle.com>
 <20190213130330.76ef1987@w520.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190213130330.76ef1987@w520.home>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 01:03:30PM -0700, Alex Williamson wrote:
> > PeterZ posted an RFC that addresses this point[1].  It kept pinned_vm and
> > locked_vm accounting separate, but allowed the two to be added safely to be
> > compared against RLIMIT_MEMLOCK.
> 
> Unless I'm incorrect in the concerns above, I don't see how we can
> convert vfio before this occurs.

RDMA was converted to this pinned_vm scheme a long time ago, arguably
it is a mistake that VFIO did something different... This was to fix
some other bug where reporting of pages was wrong.

You are not wrong that this approach doesn't entirely make sense
though. :)

Jason

