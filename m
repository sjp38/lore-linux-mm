Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3E7EC04AA6
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 19:42:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9FAA5215EA
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 19:42:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9FAA5215EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 371A96B0007; Mon, 29 Apr 2019 15:42:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3225B6B0008; Mon, 29 Apr 2019 15:42:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 238BE6B000A; Mon, 29 Apr 2019 15:42:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id E02A36B0007
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 15:42:45 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id j22so13804126wre.12
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 12:42:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3mWqs689q5s2h3GKsVpaMU6tsEgwPUSgTgrUXYA6dlk=;
        b=nUD0LBXaL75QALUQ5caR1Nx7GTIEvxS4JfC+OYHt11ZUmSmGrwSX7htT87nKYBtGdN
         9g3RTsLDQ0+5UPseaZUNM0vUQRO5HFW7c4K3eOlcg7fXiZ6DGlU0YxDIEzvtvtJ9MtE/
         u+jTac+F/a3WK3w+FwzpAhEhdcJrsus8+hsPePYZn/ulgCOpoeSGJaUibsL2pgnWgn0q
         HtVReP/WFVFX+LThUm93/zVWUnDBldezvAKnGxpHg1Ck+S2b7/dC4hj9VrSH7si20PmU
         vTaVjrd7AsvSwKFxb/P4iK9pbwOUJ+F422C9/uDSJ5GwT68DSQEXXRrUaADecP18hJNz
         EgoA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAX+aYwwIISY8ttXBPHLlVyyhI/qxBIjTwe7XiVAiTIgMwaOeMHu
	hn5Xqk+erPUu/YsFSwX/BcD0bZmiD9Q5upKNORtYZ938uXHFBkkPjuE0s0v/dPd1hXzrKD/SNG/
	mP8ZN8KpX85qdTUbUps9MML3nLEwIXx4I1/oul9K05QD/QbN06/TMiz8pzJ2ljXBvIA==
X-Received: by 2002:adf:f8cb:: with SMTP id f11mr1599545wrq.171.1556566965431;
        Mon, 29 Apr 2019 12:42:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYgEj+TVtPh0KLSd9d8Uxsf5JFrwJBvJ2UahQo7SyY2hULi8sLuvGbkELKapRpyUufsgaq
X-Received: by 2002:adf:f8cb:: with SMTP id f11mr1599509wrq.171.1556566964576;
        Mon, 29 Apr 2019 12:42:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556566964; cv=none;
        d=google.com; s=arc-20160816;
        b=RhUyxrKCUS2TYM8mIatNL0A+588hpfgzRfKAzDkg6mEcHwPhoVrVcgw9+lbFJWUj0D
         RXUdOgU6t1/GDG3veXWH43wSFwyESaBGTzvwuoP+pxtQlIX+8k3PsxK2WtnfRToqdpvR
         Sv3pgB4vvT4/iOU76iH6qcfHXluR5FiiW72GgxpORQBIiAJ7gewJs4S5kKrge1WS+VK/
         ajJrb5vFIXA3CucWjG6Ib9oAtyt50vqmXmQt4pxvgiuUgJoKT7+mQVTHLc816tCaZolp
         jbVhVreXNFrCHyO14NxasMoK2c8o4STdLwPKVVh13LzyfjXnK3xsAeen/DWqhaHtecFM
         ZctQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3mWqs689q5s2h3GKsVpaMU6tsEgwPUSgTgrUXYA6dlk=;
        b=teW9dhsR0czPrXjRipAA0Wl0Uf0kXm6tUbC7Nxm9JxZQvz53yMkNpVM4l4+Z+QNQEM
         JEAR61BytNWpEJ8zLKeA/QU06JKPBQC3kzInLgp0aWGaUKq+j787UUnEdmxPukKIzL3n
         gnhm/fsv34h7GEbRiSwSvmh74kN+PNL661noK8WRe6hLt1716v7jloUninueJMHsu/9/
         MEf038DJQys0W8Cb/uRgbQ09mIek4KC+H0lDJ10D/X/uy/MdnOE1p6WsBBQPFKOeQcwI
         0uatVAqWqAB2i+9nByh86eurhd5sMRGeGaUYEp5dRaLnuzkQ+14eIY/xKDtcpCqgJ6a8
         mSOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id o5si251772wmf.4.2019.04.29.12.42.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 12:42:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 2E5FB68AFE; Mon, 29 Apr 2019 21:42:28 +0200 (CEST)
Date: Mon, 29 Apr 2019 21:42:27 +0200
From: Christoph Hellwig <hch@lst.de>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: cluster-devel <cluster-devel@redhat.com>,
	Christoph Hellwig <hch@lst.de>, Bob Peterson <rpeterso@redhat.com>,
	Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>,
	Mark Syms <Mark.Syms@citrix.com>,
	Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org
Subject: Re: [PATCH v6 1/4] iomap: Clean up __generic_write_end calling
Message-ID: <20190429194227.GA6138@lst.de>
References: <20190429163239.4874-1-agruenba@redhat.com> <CAHc6FU5jgGGsHS9xRDMmssOH3rzDWoRYvrnDM5mHK1ASKc60yA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHc6FU5jgGGsHS9xRDMmssOH3rzDWoRYvrnDM5mHK1ASKc60yA@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 29, 2019 at 07:46:29PM +0200, Andreas Gruenbacher wrote:
> On Mon, 29 Apr 2019 at 18:32, Andreas Gruenbacher <agruenba@redhat.com> wrote:
> > From: Christoph Hellwig <hch@lst.de>
> >
> > Move the call to __generic_write_end into iomap_write_end instead of
> > duplicating it in each of the three branches.  This requires open coding
> > the generic_write_end for the buffer_head case.
> 
> Wouldn't it make sense to turn __generic_write_end into a void
> function? Right now, it just oddly return its copied argument.

Yes, we could remove the return value.  That should be a separate patch
after this one, though.

