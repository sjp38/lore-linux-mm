Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 987FBC04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:54:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A2592054F
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:54:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A2592054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 14A6E6B0005; Tue,  7 May 2019 13:54:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FCAE6B0006; Tue,  7 May 2019 13:54:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EDEA26B0007; Tue,  7 May 2019 13:54:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9F48D6B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 13:54:22 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f41so15088182ede.1
        for <linux-mm@kvack.org>; Tue, 07 May 2019 10:54:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=oJngI/SCMilkTxmUq7QJeC6lCLdhJT1aJfL3LdlyrqU=;
        b=b2hHjwcQxldQnehDZkHa5LAtrPoCdsTG3MwWVUeHctaHIxNtbEuI5SAIk++K1rnMBO
         UeS4RQsJbfFowsexF2d9BdIHOPxQrwCcMO9zSoiKw++zZ3YjBnnGRIk0fu+VFc3N4AvA
         Q8InlER36lumQgVywVuc9XnkKeF+lDbFYs9ktNbGJEYyooxJffcTg4qM3miBQ40FNkkW
         m5BPVhSYjvmgC6T99qVvVKduZcyFnu0GhYZGFLaNypuae7XzeqZsKR9F/h8QeJ4IUr0p
         ozWYueSDd68QFOwgUCHERHyhWIVKXqQFPL1N/uZPO9JExY3Na5DJld4dUQAY//VAti97
         FA6w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXeIKNCPyi0NfI50Top0/QLEd2K/9NxlqdpgtR+3kxGybV/XZzk
	j4Od1SOqYlHTLMujMlR3H8/TEvO6PHVY153nWic2qXihQ4gXYqKY4eSZjXwWFgf+isBQIDUyXoS
	FTaZdRKMSPsyTc5ccjXk20FtPZIEmKujlvVdU59/5UT/Je03a+K9UE4IJCpKOlv4=
X-Received: by 2002:a50:8ec7:: with SMTP id x7mr34505046edx.175.1557251662235;
        Tue, 07 May 2019 10:54:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqze1kQKvEzWgQP35mLeWMWqln4DXlTuSknIqFSkpKTFAzEQwD8b7YdgTIUUkHKsuy//Par2
X-Received: by 2002:a50:8ec7:: with SMTP id x7mr34504993edx.175.1557251661578;
        Tue, 07 May 2019 10:54:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557251661; cv=none;
        d=google.com; s=arc-20160816;
        b=Rai9Yup/mjnGvUwAkpZy/tdsQ6UfY4CwBeWycAo/u/NlguMWvApordJ7m7iVoS2ftD
         jm6Zecr+Tu902cGXieTFQbwV68B+pKaaNrxrEsxEjR36kqetnOSYQ6c7lrVan+HbGaRH
         TdPzFVghUgInd0XjlM04QQwtEPOVRFwzzhfBYjzH+h4koD5kTuHLllBqGqXEfShbUsJ7
         NURz1tgtCda415PxchP4+hiWhPQ0L7i80csuXeJFFynd5G6ewWLVzjq+tXkrCPN5D8p9
         gQbHpvD1BqdN38dCLjRHnfI+tQwu5KjacTa5g5j08gcuE6VFkD2Yp917Vu5vCymqf6Ye
         4xVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=oJngI/SCMilkTxmUq7QJeC6lCLdhJT1aJfL3LdlyrqU=;
        b=Vsa+5na2ArbZv/NRtz+3QwotqehBytn4UFPPBJkQZjOb0ergeU0R3OZndjZskMCGsJ
         NrSUGuG3b6l2QPKqW8ZOAOiCBbo0kIvapXbUY0o55Z7RLqPWHELP2HnoDVC4W6AXquRP
         rgR1Am34UzFgxFuYVuOvd5Ioji8UPTkNgqztn8EpnFJqwArQAg/UsHaXZfN4AdSRCoye
         JnrqL5fCO9yrjaDBE7HFjqDCZImB2IQ/E7pQiCot+FcKlQa68RzvUuiwtdJ9kP0ti1F6
         6y58sESqltXGIEdEMAzboCjDogx61fxfm0C6zJIMTeK72M7qce/tl5Dw6zMydn5Pftzc
         JAgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f17si2478073ejt.214.2019.05.07.10.54.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 10:54:21 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B223CAB91;
	Tue,  7 May 2019 17:54:20 +0000 (UTC)
Date: Tue, 7 May 2019 19:54:19 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Sasha Levin <sashal@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>,
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
Message-ID: <20190507175419.GW31017@dhcp22.suse.cz>
References: <20190507053826.31622-1-sashal@kernel.org>
 <20190507053826.31622-62-sashal@kernel.org>
 <CAKgT0Uc8ywg8zrqyM9G+Ws==+yOfxbk6FOMHstO8qsizt8mqXA@mail.gmail.com>
 <CAHk-=win03Q09XEpYmk51VTdoQJTitrr8ON9vgajrLxV8QHk2A@mail.gmail.com>
 <20190507170208.GF1747@sasha-vm>
 <CAHk-=wi5M-CC3CUhmQZOvQE2xJgfBgrgyAxp+tE=1n3DaNocSg@mail.gmail.com>
 <20190507171806.GG1747@sasha-vm>
 <20190507173224.GS31017@dhcp22.suse.cz>
 <20190507173655.GA1403@bombadil.infradead.org>
 <20190507174514.GI1747@sasha-vm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190507174514.GI1747@sasha-vm>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 07-05-19 13:45:14, Sasha Levin wrote:
[...]
> We're going to have (quite a) large amount of systems with "weird"
> memory layouts that do memory hotplug quite frequently in production, so
> this whole "tends to work usually" thing kinda scares me.

Memory hotplug is simply not production ready for those cases,
unfortunately. It tends to work just fine with properly section
aligned systems with memory being in the movable zones or for zone
device. Everything beyond that is kinda long way to get there...
-- 
Michal Hocko
SUSE Labs

