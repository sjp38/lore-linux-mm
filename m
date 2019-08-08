Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A0DBC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 21:56:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E5AB2089E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 21:56:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E5AB2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEA616B0003; Thu,  8 Aug 2019 17:56:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9B8D6B0006; Thu,  8 Aug 2019 17:56:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 963CD6B0007; Thu,  8 Aug 2019 17:56:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 47FE16B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 17:56:36 -0400 (EDT)
Received: by mail-wm1-f71.google.com with SMTP id b67so2144169wmd.0
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 14:56:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8sSKvOsFMFew+39sGyYzLjwKOktC5EY6pFQBV7T0DcY=;
        b=FjhRx+yPSvAhvfTjySFNRL5UBEbJpwPshOr7kuAO+fnhHdfAWBmngx0UUpj7mXR/Tw
         vgfj6eeIAbI6QG2JIZkzOth1r7vzdGPkhiVXOZfPPmI2otuxMrKRy+O2NKGbJu9g2KtQ
         jWt4QskiAJCXm6R9LcejKdUj6z9VzwkMcH76bHSDqw6MDTlWk6aB9cgJVIz3px/GW1Gb
         u683jk4+Rpb3NzDNHHo68mxlf5Ck9hMSZRyBitHeVIqwkanOYJBcu08LG4c8SeAcPlL+
         KHixN2Yt/K8ePqoUqZpnnhTqi5waN95gNYgvgpytGmk94BgZZI6eK5My+TFLWumfQvDt
         1kPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVJGOpKuS+Ul4FRi2dfCakWcUOSmfaIBD9rxYII3GD0yYHLtn2C
	pkHWRrQlRjL7YcNz/nHwQanEPEMIqOz9hWyhbzeEP7sLyjbTWXGIuV9y9RqqJ2wfO+H/Jh1K1o6
	zzT8y5NdNG80Sb642S4N8XTD4qTXqc25HothhlkVXTUoUhfZG2bgX4ZCz5Mh0W63LTQ==
X-Received: by 2002:adf:ee87:: with SMTP id b7mr8136889wro.61.1565301395789;
        Thu, 08 Aug 2019 14:56:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRByowjtw95FXq4utZZb1WfajKZAKYPHG4DRYjvdEKvxn+6eJ+F88QZL3u6RGLI2ZtGbuU
X-Received: by 2002:adf:ee87:: with SMTP id b7mr8136867wro.61.1565301395119;
        Thu, 08 Aug 2019 14:56:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565301395; cv=none;
        d=google.com; s=arc-20160816;
        b=UF198GOh0e8cZG0G7k7LMyNfWQ4dAsfErRIT5uQ4kuNa7o+jYP2oUxlN6iMUBNGIfz
         8+Z0M/SRrk/01NLKJPf7FnClNqbHDAS+SzDuZNz+Lanz7kvJsbfmygHN475LIZN1erVz
         pCCWN72vJ955zhWztnv4g3OqziX+30MSlWQSwHn5irxUVz11UY2CC35SBrksFShwAj+h
         Azzp665+gRlISoFBWvENWHH7I/8DNTjJiEmXJuByFx1Be2lxEHCXF4Y5LSmJ8agVnlW7
         0fhBd66+NL9UL/6kw6lVdpcmBlcWlVNNC0sqhfY8rNwcigMKO1AFOAAk5NY2qv+DSBgL
         5q9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8sSKvOsFMFew+39sGyYzLjwKOktC5EY6pFQBV7T0DcY=;
        b=vnsDvZm3HsJ7Fl2niW7c+Vbrwmxi6KFMrjUadOv102Mm1olIrhluyb6oaBOS8h15Ze
         N7blhB4gaEm+ZYBGcNSubefEexdudUhF8xh9GSXMT1g/Qde1nijcNQIfmlWaryDTB0Ri
         5gGIiKkV0BRmnHLd5NIOpn+ahMWSpbWjRaBDG/QJJbO6ieJ0nPzDtwqYXCXh+SZt4D5d
         JTCM+GNM4toxkAk+xEgOldDUR5WVK/G5+TMzJV0iNNp+NbbQ8B3ZNrJ1P2tQ2EmjDTKt
         9L9ydiuBYM4amC2HrEJAO3Oo3I+TVU8NKdCJG3UzmdPf0U1qi1J9mLgQyD6RUQP1nIBk
         k4lw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id p17si82099717wrw.42.2019.08.08.14.56.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 14:56:35 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 7D1DE68B02; Thu,  8 Aug 2019 23:56:32 +0200 (CEST)
Date: Thu, 8 Aug 2019 23:56:32 +0200
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Thomas =?iso-8859-1?Q?Hellstr=F6m?= <thomas@shipmail.org>,
	Jerome Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Steven Price <steven.price@arm.com>, Linux-MM <linux-mm@kvack.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>
Subject: Re: cleanup the walk_page_range interface
Message-ID: <20190808215632.GA12773@lst.de>
References: <20190808154240.9384-1-hch@lst.de> <CAHk-=wh3jZnD3zaYJpW276WL=N0Vgo4KGW8M2pcFymHthwf0Vg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHk-=wh3jZnD3zaYJpW276WL=N0Vgo4KGW8M2pcFymHthwf0Vg@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 08, 2019 at 10:50:37AM -0700, Linus Torvalds wrote:
> > Note that both Thomas and Steven have series touching this area pending,
> > and there are a couple consumer in flux too - the hmm tree already
> > conflicts with this series, and I have potential dma changes on top of
> > the consumers in Thomas and Steven's series, so we'll probably need a
> > git tree similar to the hmm one to synchronize these updates.
> 
> I'd be willing to just merge this now, if that helps. The conversion
> is mechanical, and my only slight worry would be that at least for my
> original patch I didn't build-test the (few) non-x86
> architecture-specific cases. But I did end up looking at them fairly
> closely  (basically using some grep/sed scripts to see that the
> conversions I did matched the same patterns). And your changes look
> like obvious improvements too where any mistake would have been caught
> by the compiler.

I did cross compile the s390 and powerpc bits, but I do not have an
openrisc compiler.

> So I'm not all that worried from a functionality standpoint, and if
> this will help the next merge window, I'll happily pull now.

That would help with this series vs the others, but not with the other
series vs each other.

