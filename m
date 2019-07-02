Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1764C5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 06:42:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6C2C620881
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 06:42:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rqVQAYL0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6C2C620881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC42D8E0005; Tue,  2 Jul 2019 02:42:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B72EC8E0002; Tue,  2 Jul 2019 02:42:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A61EB8E0005; Tue,  2 Jul 2019 02:42:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7259A8E0002
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 02:42:43 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x18so10303280pfj.4
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 23:42:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=87XbSGKa5QHQCeUtgWcK1lHAubdPYIITDtUYO85ViuI=;
        b=Yd7hVcnBlmDHOcHpWKIoyDVEyRpJ4nkB63Por/GrhbHW+QGz0IRUBkMTsOspGi0xdE
         phqwAL8QmCv+cwU6hdSLyY14apVysFh61TSQ437ICnpXpI9074BW46kZbvkLFPq7gYfi
         PeBnZMM8IzW7qvECHBu4nQ6UgttOYz+VRY2K4bp0uxjG6XJxrpn/tXxoLJHoNH2+djBu
         8/er3yyEcXGZAS0BMxvXVImBEmpngcIGDRvX2viVJiOQuxyW2QeSaiJVUv4kHAoJkWNc
         aqpx+8ibSnR5yy+egsMANh1NXrc1bfpDuajqrAf2inxTvl2ct/smNMe29/mN1cj3GjI6
         Px2Q==
X-Gm-Message-State: APjAAAXAc6pLnn1Ib5zU9b3TuI2ARO98riXZ6FsQ4xMoy4dd3ykPke4d
	3huA86Q/YmvWlUmyzxwibUwGhP9S9ucgNhfrIfNWIWwu9IypOecbtVg1RwCjbpLGMm+roZ/LX5r
	p82LWazaGnEd8MXSCigU+eraSbVAG43JZaYrOWKVjac6UyyWAVTxOpcOnNMzjvMF79Q==
X-Received: by 2002:a17:902:29c3:: with SMTP id h61mr33065141plb.37.1562049763084;
        Mon, 01 Jul 2019 23:42:43 -0700 (PDT)
X-Received: by 2002:a17:902:29c3:: with SMTP id h61mr33065090plb.37.1562049762187;
        Mon, 01 Jul 2019 23:42:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562049762; cv=none;
        d=google.com; s=arc-20160816;
        b=m+Vo3Fp9BlYflCae9PQWudlzGNeHwA9dhLE0ohRY1snYe9rlDFuKACfoicpJxKFslQ
         2d+9lind1JgimIXivJP8H9htFp845GOGkGnu1NhS52nxokgVHDKeuGyOvlWiGXCV0teh
         jJfrWraG/man9x0WoUILv6V+PYQNJNpvcqKDQZO5FuMHJGnQ2Arzn0mHHTvuLwDd5HSc
         PnO2MfFRAF8tyqeAeAmg6WVru6RkUsczfLoZVaWKGysFam4NojGwJeg+hOfxAXWQWk4S
         WIlk7Ky+0XDq6gYg9XmJja3XYSpD4BdUVhGLohKWtYwa1dIlFMgwcZrzzXNzcBrBCbS1
         XHtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id:dkim-signature;
        bh=87XbSGKa5QHQCeUtgWcK1lHAubdPYIITDtUYO85ViuI=;
        b=EVmqSlp3/eCGtm6mf/BcTxfYpBxa463R5EuR/GsCFRQz8zgC+wSRJZyV5kfqSdHPez
         uoOF8mNOgf9LvwQJf0Bj+kxpMRx6bao/UCRg5dPUR3JJ5d3c34QqYQdsyb6NHUksJYWW
         ss8BEoF6q49HO8tKdRfobukoGVv9jv0zxYmIlbE+eQ4bdgAOx5lcL+H0jZb7bUt6pBhE
         VaU3+EJuk/fpXAkfJJsUZK4F+eIFvfFDV4/aFr2pr4ZHdBk8PlKZ3zeCCBjCLEfc01p6
         gyF3f8RcUFs5FbXt210CRJdENWXU9ULIWd/xsXmI8sXQVksGwBS8tjHK3DmtQ1RjSCUo
         iuvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rqVQAYL0;
       spf=pass (google.com: domain of rashmica.g@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rashmica.g@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j8sor2189539pjz.15.2019.07.01.23.42.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 01 Jul 2019 23:42:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of rashmica.g@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rqVQAYL0;
       spf=pass (google.com: domain of rashmica.g@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rashmica.g@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=87XbSGKa5QHQCeUtgWcK1lHAubdPYIITDtUYO85ViuI=;
        b=rqVQAYL03KWvM3yxtAzULV9ROj+5qv4RNm51K8dCwptmKyKYqkznX13vIUUrtbtd7X
         6i10foW4JDXh3XDnOmEpSSpVWxS7vQI3opSg3vJMYbD2t2aBKXwDpM843lvsWW3sYDOR
         4PZJCddPZUysCuNNRugCHitmMheStFtavdtokHk0u1nOMaXV0/75dyg1QJxscd0UsGQA
         36CzpCLMA7v1ZPa2LFdKZa0GvuOtoSHAsnNMLCbWGaXNCGhtqm7qdZ2MPqHFDV4CqS6S
         r06dYUammP+ccOXWNgAzrJZzTRv5OEoJtBXV3tekmbBI5tBjmC31rih/CQxkQ79CmhWj
         75QQ==
X-Google-Smtp-Source: APXvYqx5opPoUVZnjJcNKkQE1Fn7/SKTQBxHrlZeRIrzSEiR5Nhjg0pGDvNnHaiwpg4kRbNXgzTrIg==
X-Received: by 2002:a17:90a:bc0c:: with SMTP id w12mr3530135pjr.111.1562049761805;
        Mon, 01 Jul 2019 23:42:41 -0700 (PDT)
Received: from rashmica.ozlabs.ibm.com ([122.99.82.10])
        by smtp.googlemail.com with ESMTPSA id w65sm12975112pfw.168.2019.07.01.23.42.37
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 01 Jul 2019 23:42:41 -0700 (PDT)
Message-ID: <9143f64391d11aa0f1988e78be9de7ff56e4b30b.camel@gmail.com>
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
From: Rashmica Gupta <rashmica.g@gmail.com>
To: David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com, 
	pasha.tatashin@soleen.com, Jonathan.Cameron@huawei.com, 
	anshuman.khandual@arm.com, vbabka@suse.cz, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org
Date: Tue, 02 Jul 2019 16:42:34 +1000
In-Reply-To: <887b902e-063d-a857-d472-f6f69d954378@redhat.com>
References: <20190625075227.15193-1-osalvador@suse.de>
	 <2ebfbd36-11bd-9576-e373-2964c458185b@redhat.com>
	 <20190626080249.GA30863@linux>
	 <2750c11a-524d-b248-060c-49e6b3eb8975@redhat.com>
	 <20190626081516.GC30863@linux>
	 <887b902e-063d-a857-d472-f6f69d954378@redhat.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi David,

Sorry for the late reply.

On Wed, 2019-06-26 at 10:28 +0200, David Hildenbrand wrote:
> On 26.06.19 10:15, Oscar Salvador wrote:
> > On Wed, Jun 26, 2019 at 10:11:06AM +0200, David Hildenbrand wrote:
> > > Back then, I already mentioned that we might have some users that
> > > remove_memory() they never added in a granularity it wasn't
> > > added. My
> > > concerns back then were never fully sorted out.
> > > 
> > > arch/powerpc/platforms/powernv/memtrace.c
> > > 
> > > - Will remove memory in memory block size chunks it never added
> > > - What if that memory resides on a DIMM added via
> > > MHP_MEMMAP_DEVICE?
> > > 
> > > Will it at least bail out? Or simply break?
> > > 
> > > IOW: I am not yet 100% convinced that MHP_MEMMAP_DEVICE is save
> > > to be
> > > introduced.
> > 
> > Uhm, I will take a closer look and see if I can clear your
> > concerns.
> > TBH, I did not try to use arch/powerpc/platforms/powernv/memtrace.c
> > yet.
> > 
> > I will get back to you once I tried it out.
> > 
> 
> BTW, I consider the code in arch/powerpc/platforms/powernv/memtrace.c
> very ugly and dangerous.

Yes it would be nice to clean this up.

> We should never allow to manually
> offline/online pages / hack into memory block states.
> 
> What I would want to see here is rather:
> 
> 1. User space offlines the blocks to be used
> 2. memtrace installs a hotplug notifier and hinders the blocks it
> wants
> to use from getting onlined.
> 3. memory is not added/removed/onlined/offlined in memtrace code.
>

I remember looking into doing it a similar way. I can't recall the
details but my issue was probably 'how does userspace indicate to
the kernel that this memory being offlined should be removed'?

I don't know the mm code nor how the notifiers work very well so I
can't quite see how the above would work. I'm assuming memtrace would
register a hotplug notifier and when memory is offlined from userspace,
the callback func in memtrace would be called if the priority was high
enough? But how do we know that the memory being offlined is intended
for usto touch? Is there a way to offline memory from userspace not
using sysfs or have I missed something in the sysfs interface?

On a second read, perhaps you are assuming that memtrace is used after
adding new memory at runtime? If so, that is not the case. If not, then
would you be able to clarify what I'm not seeing?

Thanks.

> CCing the DEVs.
> 

