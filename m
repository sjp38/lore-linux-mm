Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F52AC04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 06:24:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59B502173C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 06:24:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59B502173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D36966B0003; Tue, 21 May 2019 02:24:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE68D6B0005; Tue, 21 May 2019 02:24:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BAEA16B0006; Tue, 21 May 2019 02:24:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2C96B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 02:24:24 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e21so29017754edr.18
        for <linux-mm@kvack.org>; Mon, 20 May 2019 23:24:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7S+m/0w/OIwZtpEu7FM/EH68sz/cLVQnHarba+KH5Y4=;
        b=iPYfXcQ84/zcFKLIcERsesiVXJtumsX5Tm3L6pDkKDDoUVflnjq9lDrRqneObp+kPr
         DEZKtl1sjSaO9dnDon0QyEmFbLU0sogk9Ebpq2hFJQP3AmqeLaAhOOXqSndqANaaf7ER
         io6g/MSOdu3bGy/TrkojX/AgWUhevKJ7q0yNj5mzZBCrmtAZ8todS+iHhyv5EWLPAR0x
         Jt4BctrUtXLx3qkpTTc8uMM6fpwdHcsyqpQcSrd5GbmzMR9r0FTyPW/LhzRJA3FdmbUa
         NVbAaI5Zsh+L9lsTYM3EWgnCe7pilPrCM1gU8V4bNBXaXZAL2vkCzvNA6Ets26S+uaJt
         ymnw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAW4wEqIw2szbMqj+H3Ppx3B48lrxGoIzazVdsGyPwMZYtqWH4Os
	V3XNYKP5yBNk7ET6qyjE7eK8U6/lpCcIwF/ZX2SOqSL0yYFH5yqGDSf6wIbQs+o5GnZ6N04aMmS
	EBL3ZrsBaiUhj9SfE05vFH2vWbLqj7zhS0QrIOohAO5emRGT+Y6vxWOS5CARXSB8=
X-Received: by 2002:aa7:d04e:: with SMTP id n14mr51031302edo.205.1558419864038;
        Mon, 20 May 2019 23:24:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBR0CwbIoEhAXsCuZSNt03RxD/0OcJDiTrh5pAA7+gULOR4evK1UObQqAmc8s9ImiV8Ra2
X-Received: by 2002:aa7:d04e:: with SMTP id n14mr51031239edo.205.1558419863247;
        Mon, 20 May 2019 23:24:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558419863; cv=none;
        d=google.com; s=arc-20160816;
        b=kmOj6jGsiPtpxS541l05PB9UrbKrm26kVIhxPgg/HDIekmfbWAazUDuGw7+z5ANn5k
         6/+LK/DTjitXaczZN2BFX/30jFpKIAnRxlMYBwcxOM38gnMcuto6OhF1Esxx4V1gv9+m
         Est7npZj8neOXi/0vlZosDX3wE5cr3PYk7Lx/4SAWYusCRc6DmR/dE6LhZSk3Sg3h5o3
         t+2F8mVmQMdxfAtp0IRzHHWJuzjh97C10fvtFbmic08C2ZJKgFQ7c4NmZWLbMAMV4PTm
         5lhWly6fV0/+ZuY5alYfjbei+0zIjEsyNbGgvXaWtTV/Tt0VBTMJirUH07SmeBSnK2dI
         Xgiw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7S+m/0w/OIwZtpEu7FM/EH68sz/cLVQnHarba+KH5Y4=;
        b=WA5wnH/kkIg286gt5ldvuS41JfH+NMpiq/+o0k/tVgxLKbgE8NTdsuL5mK0Yu4xQZ1
         OMCsO/QWCMNZnkPJrKBH6h+4hTVwek+y8JykBxg3Z3Me3vV6LM0e3K1jKclVGmNzxp+4
         1uwqhz9DwNWruPkMyMX2NOqqC2BSn4Z+byJcTyAaIvk8+1lrBTw97xx+8wmPqADCemWB
         JEvziP+Z4jRSd1MeeQbqJuOwD4Y98mp+PUwBNMjw0L2hhfkaww7Wu+AVnKZWyFQm65wy
         zOWqgiX4WbuCvSIdUgaYpyLI/JuKryig+LaOChHtOVvMtRDCVzXVbmdbq6HZCUFX5ffb
         bxGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d5si928107ejc.307.2019.05.20.23.24.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 23:24:23 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7F1A5AD12;
	Tue, 21 May 2019 06:24:22 +0000 (UTC)
Date: Tue, 21 May 2019 08:24:21 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>, linux-api@vger.kernel.org
Subject: Re: [RFC 6/7] mm: extend process_madvise syscall to support vector
 arrary
Message-ID: <20190521062421.GD32329@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-7-minchan@kernel.org>
 <20190520092258.GZ6836@dhcp22.suse.cz>
 <20190521024820.GG10039@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521024820.GG10039@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 21-05-19 11:48:20, Minchan Kim wrote:
> On Mon, May 20, 2019 at 11:22:58AM +0200, Michal Hocko wrote:
> > [Cc linux-api]
> > 
> > On Mon 20-05-19 12:52:53, Minchan Kim wrote:
> > > Currently, process_madvise syscall works for only one address range
> > > so user should call the syscall several times to give hints to
> > > multiple address range.
> > 
> > Is that a problem? How big of a problem? Any numbers?
> 
> We easily have 2000+ vma so it's not trivial overhead. I will come up
> with number in the description at respin.

Does this really have to be a fast operation? I would expect the monitor
is by no means a fast path. The system call overhead is not what it used
to be, sigh, but still for something that is not a hot path it should be
tolerable, especially when the whole operation is quite expensive on its
own (wrt. the syscall entry/exit).

I am not saying we do not need a multiplexing API, I am just not sure
we need it right away. Btw. there was some demand for other MM syscalls
to provide a multiplexing API (e.g. mprotect), maybe it would be better
to handle those in one go?
-- 
Michal Hocko
SUSE Labs

