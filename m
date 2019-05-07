Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E045EC04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:45:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0E5820675
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:45:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="sY8/+8XQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0E5820675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 549A46B0005; Tue,  7 May 2019 13:45:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F9B16B0006; Tue,  7 May 2019 13:45:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E9726B0007; Tue,  7 May 2019 13:45:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 082AD6B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 13:45:17 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x5so10689314pfi.5
        for <linux-mm@kvack.org>; Tue, 07 May 2019 10:45:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=gQXc2uw0XtfH8tNagUfrK8+RZDnIuDVdBFWQHms/Jbo=;
        b=uJGyZN6o5alIl3eTCzKqIMBB6N9FGbbEIanR7Rkr/YPqM5iG/FfWb4PjeNG1IStZGh
         ieMpDK/nHqKGPRJrCMVw/dPNcergonJfeke87ObFnVx8YeVPXp7OyOz3f/XLa4UUilYf
         YugYKXY5uLuhVTw2DaSyVQvsKjJyePgkspZ+FY/HYrCJIFHCeGyT+D/r0lmwWRZETHwq
         RViQ3IJj0L/6TVf6C44U6j1V0q4isJlnR8ePMuJUCesWDrs54XnALqr18J0qklS2Lc0a
         KAODF3qiwAGqgiEAL69uwzZvcW3FJFvPgr1y5ebsmGrAzdbn16zwMPKPkXhEEnUXXlyK
         YFfw==
X-Gm-Message-State: APjAAAVvCY1g7O3B37d36xzS9DEVI52698Op+M1Zi74FAbMiMkq7tSZB
	wKEJwbN0HXHL+XyEe8u0K2heijRjU2dnt6C2jlm5SSQNYzG/kyC2qlJwlJL2BZYeuDvAOtm1YIH
	65YVpkcwyCMWmglqC33fvNGWj4kzEbC9blpqo6DQwEh9Wgo+iPPInZHVAxp92dzScfg==
X-Received: by 2002:a63:5322:: with SMTP id h34mr41333160pgb.413.1557251116667;
        Tue, 07 May 2019 10:45:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztwNy7MILMA+Q0P5PyNCw1FwWLcdaV/b+r9fwFd2qkczlwSfqatvo3qdDqZgU8PUKsVfc6
X-Received: by 2002:a63:5322:: with SMTP id h34mr41333072pgb.413.1557251116033;
        Tue, 07 May 2019 10:45:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557251116; cv=none;
        d=google.com; s=arc-20160816;
        b=iTnR/XILrkvlSlsLFM8+nM3qT1IUwHK/inG1x67gnMhX2VeEAsf4COv2I7RwmzQ8OI
         rLtrNATVHaCiKlaRo9TpWMAkhcxTsEOfRUJIw0J1KsNIFGvX7v43CzY+1IhFAWWP6pUQ
         lE7HQ9D6mUiJ59segXQFuM1yuLHkZ/bygROv4OvvO5igSyiXMaFKgT6Z8J3zjq7SVcQ8
         3eqAJOy8ub+Qoq/5gelAcF7zQV8sozrCUv1FTok4CbezU6M9He95MTEYSkdqiaM3p0ch
         QXB/66GfPgeks/oQYE6O0j8CV118pX2TZU78izKvFSROcAaWb5hboe97odISajGZyEH1
         pCMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=gQXc2uw0XtfH8tNagUfrK8+RZDnIuDVdBFWQHms/Jbo=;
        b=yX3jYmB/7Jv/QEEa4x0TgoXlo5TLYinR8oOBpgeuHxzZxjTI5djnpadCbM1l9+4Xe5
         /D4M64G6lvVujLpYWZe60vuCG9VFNHSlRQHAmNDHmb8C/NxtyJwAaM09Sx56ImnUAiC2
         63CSivkIg0FHs3bSf38vS1TX0l0HMws8bqZLu+XGKSu4j9VTCpD5wKm1PyeHBwzPPcSV
         Mswz1MrMfGd23jsO2vNfo3jArGrTKVzdZmzAhPrY9L76j1n/mP1Lw/qzDzgZzcO/hZp+
         R2UdFIw1vFGY4SbuA00kDeEboREyeLQeMoCnxnty0AieJymhWnZtgZsjgP+Q/6OTct3E
         aYqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="sY8/+8XQ";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r23si18532126pgv.471.2019.05.07.10.45.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 10:45:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="sY8/+8XQ";
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4D85A205C9;
	Tue,  7 May 2019 17:45:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557251115;
	bh=mE/YighewZji2jdALogvRxl+gKJULhzu19FRdUZqyHQ=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=sY8/+8XQ92ZXJgN8PAqu8UrV/K07qeZA1yYTfgXcoC/e6WoGCQKN8S+/hRLPmUZhS
	 0aJgZ3eezGGEiPFqd+8x7IGAN0cHy4GBimd72MOJC7icpy9MMCykrksZnR+0EeWn0k
	 KT9xDdfYUnnWMNzK2P2eNli9huwC2R6ijAa7gcb4=
Date: Tue, 7 May 2019 13:45:14 -0400
From: Sasha Levin <sashal@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	stable <stable@vger.kernel.org>,
	Mikhail Zaslonko <zaslonko@linux.ibm.com>,
	Gerald Schaefer <gerald.schaefer@de.ibm.com>,
	Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
	Dave Hansen <dave.hansen@intel.com>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Pasha Tatashin <Pavel.Tatashin@microsoft.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Sasha Levin <alexander.levin@microsoft.com>,
	linux-mm <linux-mm@kvack.org>
Subject: Re: [PATCH AUTOSEL 4.14 62/95] mm, memory_hotplug: initialize struct
 pages for the full memory section
Message-ID: <20190507174514.GI1747@sasha-vm>
References: <20190507053826.31622-1-sashal@kernel.org>
 <20190507053826.31622-62-sashal@kernel.org>
 <CAKgT0Uc8ywg8zrqyM9G+Ws==+yOfxbk6FOMHstO8qsizt8mqXA@mail.gmail.com>
 <CAHk-=win03Q09XEpYmk51VTdoQJTitrr8ON9vgajrLxV8QHk2A@mail.gmail.com>
 <20190507170208.GF1747@sasha-vm>
 <CAHk-=wi5M-CC3CUhmQZOvQE2xJgfBgrgyAxp+tE=1n3DaNocSg@mail.gmail.com>
 <20190507171806.GG1747@sasha-vm>
 <20190507173224.GS31017@dhcp22.suse.cz>
 <20190507173655.GA1403@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190507173655.GA1403@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2019 at 10:36:55AM -0700, Matthew Wilcox wrote:
>On Tue, May 07, 2019 at 07:32:24PM +0200, Michal Hocko wrote:
>> On Tue 07-05-19 13:18:06, Sasha Levin wrote:
>> > Michal, is there a testcase I can plug into kselftests to make sure we
>> > got this right (and don't regress)? We care a lot about memory hotplug
>> > working right.
>>
>> As said in other email. The memory hotplug tends to work usually. It
>> takes unexpected memory layouts which trigger corner cases. This makes
>> testing really hard.
>
>Can we do something with qemu?  Is it flexible enough to hotplug memory
>at the right boundaries?

That was my thinking too. qemu should be able to reproduce all these
"unexpected" memory layouts we've had issue with so far and at the very
least make sure we don't regress on those.

We're going to have (quite a) large amount of systems with "weird"
memory layouts that do memory hotplug quite frequently in production, so
this whole "tends to work usually" thing kinda scares me.

--
Thanks,
Sasha

