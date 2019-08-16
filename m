Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C90CEC3A59E
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 14:38:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8F12E21721
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 14:38:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="e6kKMZwV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8F12E21721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 242676B0005; Fri, 16 Aug 2019 10:38:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1CC8B6B0006; Fri, 16 Aug 2019 10:38:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0455A6B0007; Fri, 16 Aug 2019 10:38:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0113.hostedemail.com [216.40.44.113])
	by kanga.kvack.org (Postfix) with ESMTP id D20E46B0005
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 10:38:21 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 826388248AD7
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 14:38:21 +0000 (UTC)
X-FDA: 75828546402.30.waste89_2bcd80cb69e05
X-HE-Tag: waste89_2bcd80cb69e05
X-Filterd-Recvd-Size: 5327
Received: from mail-qt1-f194.google.com (mail-qt1-f194.google.com [209.85.160.194])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 14:38:20 +0000 (UTC)
Received: by mail-qt1-f194.google.com with SMTP id z4so6332564qtc.3
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 07:38:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=MS7ajLYKprAI3MhxmX/5qsDZrA6uiLpBaWLcIAnB0Lc=;
        b=e6kKMZwV4O+Kvfn4npy8P0jfNJrkRu5lQs/FFTJRnQrl5xmV0X39jhnFU/IsAoxvwH
         P6DR5NGW3aTKbm7N4If5x9JQENieb1V/Lilmuo5rM7sTLS9nLnxEuwjWWeFqSjhUTh4s
         BreQymkmDdDoKKfFSagL9nElLDythD+DNAXerEQl/4Mg0SUlGRuKtHuHN64CgLpRbdh7
         9cEiq+OjxTyuC3ETIUPKtAosvo2RxGNiaf3KJxInDCigqVuPBuu8nnC62J1n2oXSz00z
         CI41znMtbUNGAF8K5oF0XH26emRHSKZBPu5rb9XfdSp91cdspY84BohKD2Qxxec+/k98
         vgEA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=MS7ajLYKprAI3MhxmX/5qsDZrA6uiLpBaWLcIAnB0Lc=;
        b=s12PYt3ciXPlnjCh9ag6jvDecut3ZmOywW1twMqJGtxe/CVGz/KY4c1iVTIF9GESF8
         X2D25K45UDOendElGuWnp6AbGLwr902YLCxHAh8FbVEpDUptQmX99ElPVDkVYOxSCQZX
         7MDX1avBMnep+xMPAthsUkzUNswCInmtS8kPgown4jl4l5P81LipoVFstlEPSfcNLCP8
         U+7BHRr71nkBGnDmoO1+Zjl7GCBQjmbGE0tdCvnc5vZNMfIdcn1/vdRLQNY3Sby0VtHH
         Kl76iztvVGcxbcffL9LUcWErZ/RX0z2sAxWDZ8E5VrX+++SJl4N1/XBVpxTFqSo7u9dN
         8hEw==
X-Gm-Message-State: APjAAAUZk3F30AxtW7H2qOkDD9D1Yb9xOjfmyZ3/VDwAKw9CQKtCu4x+
	Z9o3jpNIyWlPJLx/IdG9UEwQCw==
X-Google-Smtp-Source: APXvYqwYNXHDUKQmfXFxyCkbseiiOK3Viv9fJl48UIauzpwNOIbibM0ZWbjQ/KNdDlBkdoYp4JQ5mg==
X-Received: by 2002:ac8:c86:: with SMTP id n6mr8777114qti.345.1565966300391;
        Fri, 16 Aug 2019 07:38:20 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id 125sm3190521qkl.36.2019.08.16.07.38.19
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 16 Aug 2019 07:38:19 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hydMx-0003Hq-9g; Fri, 16 Aug 2019 11:38:19 -0300
Date: Fri, 16 Aug 2019 11:38:19 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Daniel Vetter <daniel@ffwll.ch>
Cc: Michal Hocko <mhocko@kernel.org>, Feng Tang <feng.tang@intel.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Kees Cook <keescook@chromium.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Jann Horn <jannh@google.com>, LKML <linux-kernel@vger.kernel.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Linux MM <linux-mm@kvack.org>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ingo Molnar <mingo@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Rientjes <rientjes@google.com>, Wei Wang <wvw@google.com>,
	Daniel Vetter <daniel.vetter@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>
Subject: Re: [Intel-gfx] [PATCH 2/5] kernel.h: Add non_block_start/end()
Message-ID: <20190816143819.GE5398@ziepe.ca>
References: <20190815190525.GS9477@dhcp22.suse.cz>
 <20190815191810.GR21596@ziepe.ca>
 <20190815193526.GT9477@dhcp22.suse.cz>
 <CAKMK7uH42EgdxL18yce-7yay=x=Gb21nBs3nY7RA92Nsd-HCNA@mail.gmail.com>
 <20190815202721.GV21596@ziepe.ca>
 <CAKMK7uER0u1TqeJBXarKakphnyZTHOmedOfXXqLGVDE2mE-mAQ@mail.gmail.com>
 <20190816010036.GA9915@ziepe.ca>
 <CAKMK7uH0oa10LoCiEbj1NqAfWitbdOa-jQm9hM=iNL-=8gH9nw@mail.gmail.com>
 <20190816121243.GB5398@ziepe.ca>
 <CAKMK7uHk03OD+N-anPf-ADPzvQJ_NbQXFh5WsVUo-Ewv9vcOAw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKMK7uHk03OD+N-anPf-ADPzvQJ_NbQXFh5WsVUo-Ewv9vcOAw@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 04:11:34PM +0200, Daniel Vetter wrote:
> Also, aside from this patch (which is prep for the next) and some
> simple reordering conflicts they're all independent. So if there's no
> way to paint this bikeshed here (technicolor perhaps?) then I'd like
> to get at least the others considered.

Sure, I think for conflict avoidance reasons I'm probably taking
mmu_notifier stuff via hmm.git, so:

- Andrew had a minor remark on #1, I am ambivalent and would take it
  as-is. Your decision if you want to respin.
- #2/#3 is this issue, I would stand by the preempt_disable/etc path
  Our situation matches yours, debug tests run lockdep/etc.
- #4 I like a lot, except the map should enclose range_end too,
  this can be done after the mm_has_notifiers inside the
  __mmu_notifier function
  Can you respin?
  I will propose preloading the map in another patch
- #5 is already applied in -rc

Jason

