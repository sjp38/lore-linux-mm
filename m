Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2CC5C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:06:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9450520B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:06:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9450520B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 48D7A6B0008; Tue,  6 Aug 2019 17:06:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43D216B000A; Tue,  6 Aug 2019 17:06:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 354346B000C; Tue,  6 Aug 2019 17:06:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id F2BD26B0008
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 17:06:26 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id o6so49041111plk.23
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 14:06:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4B9H4lueoxMZf0n3qRcD+eaTs8MtLJT5qdVSzyIfMAk=;
        b=Pbe7kcTxLEy0tb4/I38/Duw0ZpvpDBGZMcqfYhb+IFARaql/FwTZJz7nglYbKmfFA0
         TkLJLCDI4zongJzBH9NmNRvJ3ZKzBdsKKvlne/eDwphqd/JAIzWlBNpiN9nKWXahLMhw
         aB9U9XRPJ0ezRnN/Y1EmgMIYgIOe/2J9fIEFk/Fa+xqFxa7gfDz0ZnFwf7sGE9K+ePXK
         aT8cSX5GkEhlya3HEuIqhYdB8Q+9sZE1UNGCDCO+v6Z+WgUFRWavvHoBQqsyQgmGBabG
         QfZi6Ry/sJndINtREkGX3DplxuEcid6YoRIdLfiZsvFrxVnvPGcRTOY3SE9KUwSl50F7
         ASUw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXt6ZtWNVvmQ3GqZjv+okLTfGqY7cUyuRpLUY2HqoyZztCkoJCI
	3izNuUr5c010TJiYx+dA40BD1uWVFkTnVF1M6HggbJ866KBsoZLQSCD95zZRWRBovJaiF383xmA
	xre6YoqlXyVT7X0ovqpogDsQrZR4uECpaUIL6VaCCtSxgt9VUjyMmNs5f5tEaGGs=
X-Received: by 2002:a17:902:b909:: with SMTP id bf9mr4895865plb.309.1565125586661;
        Tue, 06 Aug 2019 14:06:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwMeHT6rFkBEWL8BP/Z3NkrLLsq4WAffDqUygsnGQ9CVX13z+lNeiCNTgTXS9tx3GSCtAGv
X-Received: by 2002:a17:902:b909:: with SMTP id bf9mr4895801plb.309.1565125585831;
        Tue, 06 Aug 2019 14:06:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565125585; cv=none;
        d=google.com; s=arc-20160816;
        b=pu04GIpSB6hHTLohRXh7MzftspB2wm2Yl6WZv5e1IjulBbq2nXqdNDtbKmh2I0h9ui
         p9DtTz7jW0aa1/OLGGlFXS2Aj1308HEwxSdTmIW10LDeAH9RY6StW6Ss1GIEc4FP3ZOt
         MUmbci8LmZRFVQL5V0EMITv8vJQZaZtZyJ40mQzZxayr9I8oTJ/X3vkggS549KTR1rn0
         9oPlG3N9PZSZtbOU06TLiLBzTN3Vyb1VGZnlFuF08eqFY2AGKQk3K2veEZExyk+ysooC
         AghD+TXopV1QoV/A6IXW/a7k3af0Vi0DtcKGeTNrgZg8UTHigNhlO/n36Kc1Ni1NG3wI
         nL8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4B9H4lueoxMZf0n3qRcD+eaTs8MtLJT5qdVSzyIfMAk=;
        b=fQRzTfhj8ZZOcqwuwVgRjLB1rOmtiR1AjrfoZDjF/jPGMBtAxiKvKgisHXsfkzlacH
         blEwHipBiI0wRAttqzJzErMLk/7iMIMdNAX2iqcDHN58F8YIgSbI3Y6ZxZu56DiR+T8m
         qR5izT5liRayc2NZbZsJMgpSrZPt94SiTJrJDAy2We2UjDXCyn8lkVCinsW6dqU4daZg
         BjGyQMsgB8dGT/qX677Ao/iLdzc0pm4v7ksfUmCRKPukiQhOGflabKdIzzbsRxPCAvyh
         BPdaNEjVtOD4zx+XyAn8U92gvEMIh7zmacBYGLw23UQgXEzwaTUo+UGBtQDXeZzvtD/c
         +NgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id t5si48437165pgr.172.2019.08.06.14.06.25
        for <linux-mm@kvack.org>;
        Tue, 06 Aug 2019 14:06:25 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id B989243CF0A;
	Wed,  7 Aug 2019 07:06:22 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hv6dv-00051f-48; Wed, 07 Aug 2019 07:05:15 +1000
Date: Wed, 7 Aug 2019 07:05:15 +1000
From: Dave Chinner <david@fromorbit.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 12/24] xfs: correctly acount for reclaimable slabs
Message-ID: <20190806210515.GF7777@dread.disaster.area>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190801021752.4986-13-david@fromorbit.com>
 <20190806055249.GB25736@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806055249.GB25736@infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0 cx=a_idp_d
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=20KFwNOVAAAA:8 a=7-415B0cAAAA:8 a=hgB5nrfzdG2RuRxMWyMA:9
	a=CjuIK1q_8ugA:10 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 10:52:49PM -0700, Christoph Hellwig wrote:
> On Thu, Aug 01, 2019 at 12:17:40PM +1000, Dave Chinner wrote:
> > From: Dave Chinner <dchinner@redhat.com>
> > 
> > The XFS inode item slab actually reclaimed by inode shrinker
> > callbacks from the memory reclaim subsystem. These should be marked
> > as reclaimable so the mm subsystem has the full picture of how much
> > memory it can actually reclaim from the XFS slab caches.
> 
> Looks good,
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> 
> Btw, I wonder if we should just kill off our KM_ZONE_* defined.  They
> just make it a little harder to figure out what is actually going on
> without a real benefit.

Yeah, they don't serve much purpose now, it might be worth cleaning
up.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

