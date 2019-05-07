Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B47C3C04AAB
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:31:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 84285206A3
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 17:31:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 84285206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10DA66B0006; Tue,  7 May 2019 13:31:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0BE576B0007; Tue,  7 May 2019 13:31:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC8086B0008; Tue,  7 May 2019 13:31:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9FD5A6B0006
	for <linux-mm@kvack.org>; Tue,  7 May 2019 13:31:26 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x16so15003418edm.16
        for <linux-mm@kvack.org>; Tue, 07 May 2019 10:31:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=rBvz/W+UyoMQ2uBOXQc9tEHQ9nTfTe0J1trwJ7QOcRc=;
        b=eCFWeXO073dXikWSduufRDSBhtzvoE4i35E5BgP3pYTsmtjy080fMSx4iavtog+WxN
         YQaYDb/tdvHAC5uD0/7SM8Km8cG5mbjseaDaXCZxmMbpXvz0E8+NiSLC0JNS50/iKtkW
         StBBOiModRaPIjNK+dP8Qt6zLOxSXQDIbDVgiMhfjmTNbEoKJMf2LsPAlrWTczbkv+Vw
         CYbHQCBTkIqen/HmGoTx4joOvpybApY31W9m3s/AYbMlVQ1nioyhqw428DCZ4sDV4hm6
         kSPl//FpBiXXBpVf+xyK6R4d4qSjhluX4N5ufmUqgJEEDNri5rBrm2/G2H3FLSnnczg4
         y3Og==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXgYmkCTGRGCm7rl2WTLXa4sXAnbmZImovWZCQ5D+RvTo+BrPkw
	LBhl4ClZ+uArUOfJiuLFQZYafhV4RXpE2b0j1J2u6wbHgFCDynnYmW6BRolvpCV3+mpXzsjMlEh
	bGeJRjsRFiJ/bQJpk1BHkKY9AQxEG4Es5SRlc2eDInFYpfaqxhSMcxJkBgRMmVvc=
X-Received: by 2002:a17:906:3fc4:: with SMTP id k4mr25663366ejj.166.1557250286177;
        Tue, 07 May 2019 10:31:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwj5VNfWAGAqfaEgiqblOnPxpxV3Sgjuc2KUqWYkc+4+MfzPBylgiyPE+qTZv9cdb82egil
X-Received: by 2002:a17:906:3fc4:: with SMTP id k4mr25663309ejj.166.1557250285384;
        Tue, 07 May 2019 10:31:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557250285; cv=none;
        d=google.com; s=arc-20160816;
        b=Nrkk0P3k5lmxh/wDnuT4R/kcIvpAl4VRuzMDU5Fy7CFCe/wxk3MbcRZg2LhjleIdm+
         Hy7KIeHFeTnbCwHDDkTAmJbpdduk4pRG+K6KW2RNcM7VNF6TDmi4O0rqXaiVRsKxqya4
         KpTIlJVXNOJXcgm3LXo/K68oD2h31OwE8dB2YPuoc321RVaYn8KC0UYokHVUblVWo1qa
         7zx2Z0jcR5fH0Wv2Fb9vOUGst9Hn34nOBg7rcM459ERpzKwjXTthtIrVqPIff9NyXzAo
         92JLmXIS7qxafKCuA6qXaWkLgWWW0qa1/k/9ZLqj2TXIq8HseF690gQhDW6fu0p9SIb7
         ZCIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=rBvz/W+UyoMQ2uBOXQc9tEHQ9nTfTe0J1trwJ7QOcRc=;
        b=zEoXnyLwcUngw/+3I7Oi3TxsYWG2s7lpi5jM10W1G6FO8A+6LfhUfl0f7WhqrF/eWN
         V9yUTcgwV6xhf9Usfz7A13EHmI++N7C0cxRD6rD+v+9x+67evTZh5X7RcYjBgD0+ae0K
         CdhRhAKVs9C/QoV7y9kBe3Hl/oRYzBZfDgbcq2/ECKqB4qk6BvhpvAR+8iicbD4PZIEt
         l0rPhKWNHRk3+J7W/N/z11NX/MUNjdwo6kUxx6jsYXyRdCQxlfJR5ejTALgHUrfhcIOT
         VkXYNnz8MPVKtMgRDvgYxsP5ytbCj0SEuThHmkLK9Vh9PT9u1Poi8VS9JGMqhRQdUVGh
         mDyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a6si8075390edi.217.2019.05.07.10.31.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 10:31:25 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6F20FAEA3;
	Tue,  7 May 2019 17:31:24 +0000 (UTC)
Date: Tue, 7 May 2019 19:31:21 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Sasha Levin <sashal@kernel.org>,
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
Message-ID: <20190507173121.GR31017@dhcp22.suse.cz>
References: <20190507053826.31622-1-sashal@kernel.org>
 <20190507053826.31622-62-sashal@kernel.org>
 <CAKgT0Uc8ywg8zrqyM9G+Ws==+yOfxbk6FOMHstO8qsizt8mqXA@mail.gmail.com>
 <CAHk-=win03Q09XEpYmk51VTdoQJTitrr8ON9vgajrLxV8QHk2A@mail.gmail.com>
 <20190507170208.GF1747@sasha-vm>
 <CAHk-=wi5M-CC3CUhmQZOvQE2xJgfBgrgyAxp+tE=1n3DaNocSg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wi5M-CC3CUhmQZOvQE2xJgfBgrgyAxp+tE=1n3DaNocSg@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 07-05-19 10:15:19, Linus Torvalds wrote:
> On Tue, May 7, 2019 at 10:02 AM Sasha Levin <sashal@kernel.org> wrote:
> >
> > I got it wrong then. I'll fix it up and get efad4e475c31 in instead.

This patch is not marked for stable backports for good reasons.

> 
> Careful. That one had a bug too, and we have 891cb2a72d82 ("mm,
> memory_hotplug: fix off-by-one in is_pageblock_removable").
> 
> All of these were *horribly* and subtly buggy, and might be
> intertwined with other issues. And only trigger on a few specific
> machines where the memory map layout is just right to trigger some
> special case or other, and you have just the right config.

Yes, the code turned out to be much more tricky than we thought. There
were several assumptions about alignment etc. Something that is really
hard to test for because HW breaking those assumptions is rare. So I
would discourage picking up some random patches in the memory hotplug
for stable. Each patch needs a very careful consideration. In any case
we really try hard to keep Fixes: tag accurate so at least those should
be scanned.

-- 
Michal Hocko
SUSE Labs

