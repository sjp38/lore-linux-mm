Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15F12C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 10:04:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D5E2420B1F
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 10:04:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5E2420B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 689258E0002; Thu, 31 Jan 2019 05:04:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 637F98E0001; Thu, 31 Jan 2019 05:04:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FF508E0002; Thu, 31 Jan 2019 05:04:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id ED6FA8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 05:04:02 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id v4so1069394edm.18
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 02:04:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=84KpOcjnDTcRuqZg06HUC2WxK5TFCS8JxISUrYomBOg=;
        b=p8hhx8Slue0umNJXKVLF4nLkaB8e2ResgA6fOEPPoEKXuOIwTcCohmRIzeqVxFCjn8
         5/3Gm5fHGw46ZNedWi+uDHB3feiaTEBc+HRi1A7KT1K5BF72jl9WOsiCJlFzE/wQvBfJ
         1gE+Ic5LpsfGqV3t/Vdt/nO52aqJKAxfzOg9EfRpBOzt0Ku6HDMizXdvuNEvSTmcYN7I
         T8lYd5eivGg5ui3NyiZv4wffluP42aD8udiYAOY25ZpWMgdTdWdKPzrcFLCefaf2idCT
         DDTSY+Pg0ZXuZHN73Gj0wLcl9AzE04SIvV8GQ9OKemIyWNrwtRSplPW4fDGx2dtSKuaH
         p0nw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AJcUukeySCQ0NtnEgJlXEODJ7moSZcCaVdZxF61Iy0F+ODuMBTEBKTXa
	vVCAqzprm83+QLypmrAyDo1cbZSszvz6KTK//VW0hK7Q3AkIBLuHSEI2hI2tMWBbF3hvJr5hgIv
	qoYXZED0onEoxewLZXMjBIlWFwTncU0GAC/e7TWmKC9O7al64eKne3uZZK++gm2uWXw==
X-Received: by 2002:a17:906:914a:: with SMTP id y10mr30671068ejw.124.1548929042490;
        Thu, 31 Jan 2019 02:04:02 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7j8HP2xeDMWUmdAs7zXGvBrTmBBOgoLNsykMzWtVcKEy+OGPFZeHCAW0LMPpWJmLM5FEuc
X-Received: by 2002:a17:906:914a:: with SMTP id y10mr30671015ejw.124.1548929041575;
        Thu, 31 Jan 2019 02:04:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548929041; cv=none;
        d=google.com; s=arc-20160816;
        b=vcMiO7c+gQrfPBVQL6mIMo66GdGHScGwsOEoGmVPQvwxQE7CdEt6PDMKaV5DPW0AHE
         sKnlmTGx+Ktc5RsJ9mjbiY/CKEFB1QRgnJTicyOnrV6VhM3Z6AP3NNtGd1L4vnetJqVe
         s06FiXyputL88plR4SlONOxXK4dC+eTjQnER3O4uW7Ls6b1xl1AZJbfYy1FGBu3LFNfW
         ewuDye/zX/xjI1Xo4+GT0YffgA2MhhxyJX8qf6Vbbz+8nGZOWtANKS8Aesa/xiGxmTNA
         fk1KceX4Fm1GOZqM+kdee02yQgsXyhR0/dAkUh59X6cfWFxrZMuVO272HMWTm1r+lEc6
         qBCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=84KpOcjnDTcRuqZg06HUC2WxK5TFCS8JxISUrYomBOg=;
        b=jU+G9K6t+8kHndJ2yYIUqOYpGP3wJ5ZulEepSGoy6V1QKTq9sYu7SES/ekrCOMe+p1
         zqRUpmAAmr/LqFhMl0BZT/p3IxFDaCr6jwAytiP/1FAdTSFXqWjjVSJp+KCeY1fUw86V
         ofUY2YFxbNb8XVnIpBRCn/ZKcF5Nw5+rbIvOEQyILnGBXZJ4ur05o1iO7LxCDgzGB34Q
         zjz3QlOH5EirlJmtRlAE7RDseo3OipfFSOV5hvhnwfWU5ro8wPIqNaq/NTkWJPXia6wL
         YFf/xX+Ldqm5p5XEIl4ErZGarqmv5qxcWgrhxMefyGYQfiKUfHoeeM/IkmPpddOeIRkn
         tFZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e10-v6si1996111eji.18.2019.01.31.02.04.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 02:04:01 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id C4BCBADA2;
	Thu, 31 Jan 2019 10:04:00 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 5E9CB1E3FFD; Thu, 31 Jan 2019 11:04:00 +0100 (CET)
Date: Thu, 31 Jan 2019 11:04:00 +0100
From: Jan Kara <jack@suse.cz>
To: "Weiny, Ira" <ira.weiny@intel.com>
Cc: 'Jason Gunthorpe' <jgg@ziepe.ca>, Davidlohr Bueso <dave@stgolabs.net>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"dledford@redhat.com" <dledford@redhat.com>,
	"jack@suse.de" <jack@suse.de>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Dalessandro, Dennis" <dennis.dalessandro@intel.com>,
	"Marciniszyn, Mike" <mike.marciniszyn@intel.com>,
	Davidlohr Bueso <dbueso@suse.de>
Subject: Re: [PATCH 3/6] drivers/IB,qib: do not use mmap_sem
Message-ID: <20190131100400.GC19222@quack2.suse.cz>
References: <20190121174220.10583-1-dave@stgolabs.net>
 <20190121174220.10583-4-dave@stgolabs.net>
 <20190128233140.GA12530@ziepe.ca>
 <20190129044607.GL25106@ziepe.ca>
 <20190129185005.GC10129@iweiny-DESK2.sc.intel.com>
 <20190129231903.GA5352@ziepe.ca>
 <2807E5FD2F6FDA4886F6618EAC48510E79BA6A27@CRSMSX101.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2807E5FD2F6FDA4886F6618EAC48510E79BA6A27@CRSMSX101.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 30-01-19 18:01:33, Weiny, Ira wrote:
> > 
> > On Tue, Jan 29, 2019 at 10:50:05AM -0800, Ira Weiny wrote:
> > > > .. and I'm looking at some of the other conversions here.. *most
> > > > likely* any caller that is manipulating rlimit for get_user_pages
> > > > should really be calling get_user_pages_longterm, so they should not
> > > > be converted to use _fast?
> > >
> > > Is this a question?  I'm not sure I understand the meaning here?
> > 
> > More an invitation to disprove the statement
> 
> Generally I agree.  But would be best if we could get fast GUP for
> performance.  I have not worked out if that will be possible with the
> final "longterm" solutions.

Initially probably not, longer-term it might be added if there are
performance data supporting that (i.e., showing real workload that would
benefit). In principle there's nothing that would prevent gup_fast like
functionality for long-term pins but I expect there will be always
additional overhead (compared to plain gup_fast()) of establishing
something like leases to identify long-term pins. But we haven't figured
out the details yet. For now we concentrate on fixing short-term pins and
issues with those.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

