Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5539FC43219
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 23:53:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15BD12070B
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 23:53:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="N9BE3PqM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15BD12070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A41676B0003; Fri,  3 May 2019 19:52:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A17A26B0006; Fri,  3 May 2019 19:52:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 907706B0007; Fri,  3 May 2019 19:52:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F29E6B0003
	for <linux-mm@kvack.org>; Fri,  3 May 2019 19:52:59 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id u65so7404139qkd.17
        for <linux-mm@kvack.org>; Fri, 03 May 2019 16:52:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Y9uds37g7f4813/ZqlKEDnGn948IiuDvboVC7bPadlI=;
        b=syLvF4RnWa8cxX+WefmAxhtlauc2rB3mUX/1t+xiv/KXvFLmeEegy79Z+s9MwQLzBo
         DorZ1+Wbgl9ZVjTuUf1uLPeosxfAo5FMHU0fMzdE8N8qy6JJPPASDSmS3el+qd3M4OZZ
         hraQCw7rVfQ4BlbzVt7aXBeOtbGFInGj+i0rph7DxiWkFwwZF9FLgP3P/nzVaCNdFHgg
         9vE39Gi/B0HRowiTpzlZ/GAZeGyqKIiVUvL/RmIh4BsRo5jBVjx/39cz8ooWGmcacRdp
         1ZhOnhctGafS9uhbP2N+vwtRKtD5eROx05IZV9Vz3V4tG23RsXReVx9K7Mgu3kNw/So0
         SiKg==
X-Gm-Message-State: APjAAAWIT4c8cj7/PxB2RV4FF/PmYYZhovyZKH2V3ibb0x4PXDsv6FHK
	2lL3Qh2ZgVagEPODuxv24rtCkcVSMLOkJ4WaYyxguPkA1CB/x83LKMQygocN08KvJxCi5+HDErr
	m23RTPwLhWvyKPh+TWBcI/cmlFoyzaMwqurR3qcVOydrtPmJnhgWjr3PsR7y+Lr0OKw==
X-Received: by 2002:ac8:2b3b:: with SMTP id 56mr10900036qtu.143.1556927579102;
        Fri, 03 May 2019 16:52:59 -0700 (PDT)
X-Received: by 2002:ac8:2b3b:: with SMTP id 56mr10900006qtu.143.1556927578351;
        Fri, 03 May 2019 16:52:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556927578; cv=none;
        d=google.com; s=arc-20160816;
        b=Gfg2zuZJ8+IBUrpYmaMhK/Fu+cD38enAH1lII83ofiiqyEkKPdQhVN5XJRDB6AtZVT
         cGruXWkZu5JYoPhW5h22Vwff9fZl+NZFHTeJ0nNtlF9u7I8Qz900Qke/qnnaU15PadDH
         dZ/Iim+ro3leKD68SrQbZp6jG6/lVolfZjTARsH+leag4hDxIDbO0Uz/zrvExJqMJQeI
         Fb9CyDC2kIqE+wNtCeXmBWNpRdML+XG2fpn9zgwXWOgfwawmTTbHGhuH/1gf1jSpTJbx
         WHZRu/iCKXKUqvqkGCA+XfCIeMT2LdM335HZjvTR58dZrCzN//rbzvsTcw7AuIoERBRy
         NJQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Y9uds37g7f4813/ZqlKEDnGn948IiuDvboVC7bPadlI=;
        b=ck94k9tJiY1CnUWWV0osOG2bH6BXjgL4QiBhSwgSQSVKWenO/aEbhduqI+bOKJs1TK
         JCevD0/sraFwPl9PzGEh1C09PqSaVmVPta+sbJ8VH+fIIRIfp+ZMu5OSNunsMNMelxhF
         5vhG/Cofc0ldrW3S0Gxd3KwPStzNaYnV8tNLXn2mtzuvoDTQ/8HY4bTRKLWzNHhLskWr
         7EYPvzgsRiO4Nh0uKURE/ABvhtsxfn0YEF8tFoTLZDH/+j5qoYfHnC/SnWFcigRe8bgy
         rH87LYDycs4l5AURup7maM0IvgztEhIjEZLLXIJiplkPAAWiNDA6oJxzRXremhfXTaL0
         Mv3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=N9BE3PqM;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d44sor5227070qtd.62.2019.05.03.16.52.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 May 2019 16:52:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=N9BE3PqM;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Y9uds37g7f4813/ZqlKEDnGn948IiuDvboVC7bPadlI=;
        b=N9BE3PqMA0nL0NvpOU63kepSs17NWxuaQGMx7Tupv6wpFQNuRqB6tenh0G/BWpJ1PP
         HEd7ZRYuplIPMrp/i3Cbd8pyLv65lE/Kcn6MATxFD0LAM764ONzAI9CGs51aZh5QkF2i
         IUvMmfzMxlcfJSqngQx2TZEML8ZbCAHWTFmHtqfhFJeQ8JVqaTAgfiqfKRaZhlNd6jZX
         Xiy8j3oAf41/Kg4WEp6FuwvI9DlafHuBxOiRzLclafXL2AMIXhBmFJmJrK5KHtm2pgmi
         Pkc8sfsyJqh6zaTpfCu0T9ewb4rk6AtpL8uJLJA4xZTB0LSOR9blqcrj5s/eIqJuMPaw
         q8oA==
X-Google-Smtp-Source: APXvYqziKdH2wZvx3iC97K6c8A4weeprYaQkrXpo4FxMM1oMFrPSRq/nQcOHMobAnKPDvieS6kD22g==
X-Received: by 2002:ac8:8ad:: with SMTP id v42mr10692638qth.337.1556927577786;
        Fri, 03 May 2019 16:52:57 -0700 (PDT)
Received: from ziepe.ca ([65.119.211.164])
        by smtp.gmail.com with ESMTPSA id r1sm1636491qtp.77.2019.05.03.16.52.56
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 03 May 2019 16:52:56 -0700 (PDT)
Received: from jgg by jggl.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hMhz6-0001lg-BL; Fri, 03 May 2019 20:52:56 -0300
Date: Fri, 3 May 2019 20:52:56 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Leon Romanovsky <leon@kernel.org>,
	Andrey Konovalov <andreyknvl@google.com>,
	Will Deacon <will.deacon@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kees Cook <keescook@chromium.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Yishai Hadas <yishaih@mellanox.com>,
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	linux-arch@vger.kernel.org, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v13 16/20] IB/mlx4, arm64: untag user pointers in
 mlx4_get_umem_mr
Message-ID: <20190503235256.GB6660@ziepe.ca>
References: <cover.1553093420.git.andreyknvl@google.com>
 <1e2824fd77e8eeb351c6c6246f384d0d89fd2d58.1553093421.git.andreyknvl@google.com>
 <20190429180915.GZ6705@mtr-leonro.mtl.com>
 <20190430111625.GD29799@arrakis.emea.arm.com>
 <20190502184442.GA31165@ziepe.ca>
 <20190503162846.GI55449@arrakis.emea.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190503162846.GI55449@arrakis.emea.arm.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 03, 2019 at 05:28:46PM +0100, Catalin Marinas wrote:
> Thanks Jason and Leon for the information.
> 
> On Thu, May 02, 2019 at 03:44:42PM -0300, Jason Gunthorpe wrote:
> > On Tue, Apr 30, 2019 at 12:16:25PM +0100, Catalin Marinas wrote:
> > > > Interesting, the followup question is why mlx4 is only one driver in IB which
> > > > needs such code in umem_mr. I'll take a look on it.
> > > 
> > > I don't know. Just using the light heuristics of find_vma() shows some
> > > other places. For example, ib_umem_odp_get() gets the umem->address via
> > > ib_umem_start(). This was previously set in ib_umem_get() as called from
> > > mlx4_get_umem_mr(). Should the above patch have just untagged "start" on
> > > entry?
> > 
> > I have a feeling that there needs to be something for this in the odp
> > code..
> > 
> > Presumably mmu notifiers and what not also use untagged pointers? Most
> > likely then the umem should also be storing untagged pointers.
> 
> Yes.
> 
> > This probably becomes problematic because we do want the tag in cases
> > talking about the base VA of the MR..
> 
> It depends on whether the tag is relevant to the kernel or not. The only
> useful case so far is for the kernel performing copy_form_user() etc.
> accesses so they'd get checked in the presence of hardware memory
> tagging (MTE; but it's not mandatory, a 0 tag would do as well).
> 
> If we talk about a memory range where the content is relatively opaque
> (or irrelevant) to the kernel code, we don't really need the tag. I'm
> not familiar to RDMA but I presume it would be a device accessing such
> MR but not through the user VA directly. 

RDMA exposes the user VA directly (the IOVA) as part of the wire
protocol, we must preserve the tag in these cases as that is what the
userspace is using for the pointer.

So the ODP stuff will definately need some adjusting when it interacts
with the mmu notifiers and get user pages.

Jason

