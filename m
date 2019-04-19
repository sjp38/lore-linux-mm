Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4207FC282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 08:53:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 051CD217FA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 08:53:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 051CD217FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C26336B0003; Fri, 19 Apr 2019 04:52:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BACBC6B0006; Fri, 19 Apr 2019 04:52:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AED3E6B0007; Fri, 19 Apr 2019 04:52:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 78F156B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 04:52:59 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k56so2581379edb.2
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 01:52:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=SMV27s3E5FT+Q6XDnHJsLcFlh4TxLXdZEgUwd/RuheI=;
        b=DDwCdj9YduFjmC7elK8x4pP6nwZsBZNDIW4dxcySbFhDo/k3t72dayyKpvcBpUUPIB
         Jb16GOfok8g1f5CXpP1BG5e82MZ/1ZiyJ1TJr0eG3AsKrQpsoxn/vbShxhjFTWmNAE21
         TvIbbfmL5s80MzmUANsnkYo3h9xmmRT2vWdoydsnN5s8MRWYCcyJDOWMszIh0qNY7LGC
         aGgkFLQfKhoZNt5SRawlku1Hw4VnZad466Ooj8jxnVmN7FAaYy4co5iZe8kn0yFyYopa
         UGbAn+/CMatVt6Ka6qO+tEsBKXdgVu9XNDzOXVWUt6VB+khxRjTkq7nQ3ybbS0DNs8HX
         JRdg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.232 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAX14rLewqvdIuCw64DrRxDYlel9yidbXF73LzHDBlSTSjrtouL2
	Xjb/UiJhQOqzcdJ3kDCQ6GQG/mJwlz2rJQ6FZBAppqUFrylOOsI8B1FENhJ8aGpeIsnGP0L6r56
	TsoqVuK6hpRbSEUC8ugsRLXC+xxw99nMjSe5jjei1QqJxotDvbZbHo3eGlRcAtb2xfg==
X-Received: by 2002:a50:8fa4:: with SMTP id y33mr1672297edy.197.1555663979091;
        Fri, 19 Apr 2019 01:52:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwuWFnkrE2ubBqUOe2dRsRYLJDVKTZJZJQPD7/nGKzLkdw9q3SFnXs3ug4gTNj3+86W8d2i
X-Received: by 2002:a50:8fa4:: with SMTP id y33mr1672265edy.197.1555663978307;
        Fri, 19 Apr 2019 01:52:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555663978; cv=none;
        d=google.com; s=arc-20160816;
        b=XBG7hbi18u336+ryM00gJ296Vc4KRynaGJ7iLRvz6QTH5tF1/8+kOtSL0UiwSafc00
         fAHwhRAMjFVmqvHtkpg6NFBvTYXeJVfbDHueAkDPzZb4p60RWDU6ku0U2x2xpIpG98rz
         1Jj2s8i3Ns3Dc25Olwayd6i/enJadx6LnPuuzwKvg73hepyJBroTR3LjNIxW2TLEsgNe
         azHOMOOj1G/i8oytYuNymJEAyqQtObNHXozZlLT+YCgTKL3hYuuMdb6Pqi2So8a3z4oB
         1uouCvN1gnrn3StpykJJB53J0QDTZwdmlzn5NEaL1o1NxPw8+8PGHakmvAWAthSoupZu
         hHGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=SMV27s3E5FT+Q6XDnHJsLcFlh4TxLXdZEgUwd/RuheI=;
        b=vnHwFzZ94UPhK6T+lByaEBkSrrjb9me0Je3TYmkN6f3dTAajKvKbgZ3hGNwfqy/J7g
         OHtyvmXMCINUhsLbechn6ki+ap8jdGu/dO41xDAkFWBsNQEj/xzNuSJ87uljFfZiWo/q
         tqGPE3YqDVyl5zeUOnGTgHu9KKgZrMZbh7qVH6j172Y565MMgkhGjbeeqKUNdkOdruSC
         LJG7Fv7HY7Gfs6kNGwMm5EyF9ssnphBYbVh+m39hu9AxQgMlv+97FcJXoylRCZfH0ITM
         tT2GxNnS4hOVJvfkRdYf8gEYNm6irv6gjqJ2fJ7bhRv4h6N3RdKyh9daD08hY1d/jRFM
         bwkw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.232 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp15.blacknight.com (outbound-smtp15.blacknight.com. [46.22.139.232])
        by mx.google.com with ESMTPS id t10si2229256eda.370.2019.04.19.01.52.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 01:52:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.232 as permitted sender) client-ip=46.22.139.232;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.232 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (unknown [81.17.255.152])
	by outbound-smtp15.blacknight.com (Postfix) with ESMTPS id DBF661C3699
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 09:52:57 +0100 (IST)
Received: (qmail 4634 invoked from network); 19 Apr 2019 08:52:57 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 19 Apr 2019 08:52:57 -0000
Date: Fri, 19 Apr 2019 09:52:56 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Li Wang <liwang@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>,
	linux-mm <linux-mm@kvack.org>
Subject: Re: v5.1-rc5 s390x WARNING
Message-ID: <20190419085256.GI18914@techsingularity.net>
References: <CAEemH2fh2goOS7WuRUaVBEN2SSBX0LOv=+LGZwkpjAebS6MFuQ@mail.gmail.com>
 <73fbe83d-97d8-c05f-38fa-5e1a0eec3c10@suse.cz>
 <20190418135452.GF18914@techsingularity.net>
 <CAEemH2eN55Nuvqngvpr1=1LU16KTbPAKo0-ZZW3Da6YX1S3kZw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAEemH2eN55Nuvqngvpr1=1LU16KTbPAKo0-ZZW3Da6YX1S3kZw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 19, 2019 at 04:41:24PM +0800, Li Wang wrote:
> > Avoiding the scenario is pointless because it's not wrong. The check was
> > initially meant to catch serious programming errors such as using a
> > stale page pointer so I think the right patch is below. Li Wang, how
> > reproducible is this and would you be willing to test it?
> >
> 
> It's not easy to reproduce that again. I just saw only once during the OOM
> phase that occurred on my s390x platform.
> 
> Sure, I run the stress test against a new kernel(build with this patch
> applied) for many rounds, so far so good.
> 

I think the patch is safe enough and have sent it on to Andrew. Thanks
for reporting and testing this, it's appreciated.

-- 
Mel Gorman
SUSE Labs

