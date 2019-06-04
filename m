Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3770FC28D18
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 13:02:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6324248EC
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 13:02:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Yjg83FKm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6324248EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83BF36B026B; Tue,  4 Jun 2019 09:02:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 812D46B026C; Tue,  4 Jun 2019 09:02:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 701D86B026E; Tue,  4 Jun 2019 09:02:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 45B376B026B
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 09:02:10 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id v4so3490242qkj.10
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 06:02:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ROjiC3s0siagx/fi+MGJXNVgc6kDjODdOY/lcLdmBIY=;
        b=qLoKpX/QMAsb5wHA7bs+BQrkjV9R7c7mNQGWihki5p4LDDvWZ65yfLHD61PxXCw2xa
         6xeJz0vGktRJGqbuezjXxM5r8mSIWvbFqNILvXwUFioAj1tl/gt0+wvwhb5rIclZs2Q0
         daFayaBlJcR74vU74SyO77nB/lHyRDPDnqDraIehuuKjZX40t2ppOfRiofE5h9JNrM6E
         eRjWtPXRZ8Q9FBe5MJbeYicj54CLHg/yBhPnTeOM0As1CeuPBXFqAJjn8SX9O2V6VA50
         6vWwHpouAxSDXnE06fNGIqRM1vRVCBr3HksDcA3fnmGOt1V49A6oUACIRQgjCoEtjqNe
         nLpw==
X-Gm-Message-State: APjAAAW6FgCklL5UC8/H4VKXKf06bfPJW5QxVFkrJ3WwbK9TzEVbeyWI
	4S+8cmh96+ZGmrp/ukcaAxcdS70T99hLErK8QJwm190THZz0ex+nEUZQKmQATmhn/xm4x9uvCFU
	xYdbGohDItTKJzjMGCdBfyzFN1SxSPXhecmBjvix2npDWFTJg+C9xqdmIBhWc7ly8eA==
X-Received: by 2002:a37:9d50:: with SMTP id g77mr26996793qke.311.1559653329975;
        Tue, 04 Jun 2019 06:02:09 -0700 (PDT)
X-Received: by 2002:a37:9d50:: with SMTP id g77mr26996723qke.311.1559653329248;
        Tue, 04 Jun 2019 06:02:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559653329; cv=none;
        d=google.com; s=arc-20160816;
        b=E3Q9MKwho1EZdx9Mc8aJECtqbNztLyxUZdUGfR8ObNnr80luylxhQnrlqEhGvDDQEB
         pU9bdj+pULKrbNObBkdnbzK6zK3Oct5M0WvIbmBQJa/TrdG6XsRLV8pfh4jAswmd4NRY
         5mwOCCVnoeMxk2FHf2kuTHma2Te/pz/ObHB82NYbdmnYvZDc4jPGmCHQ1Egwn4tKX7Bf
         LAKoY2dk7Ass+E5zic4rG7cMcWql1ESAKioHwXXZuxSY6ZvN8V8rgq3u5oZ4bRtmqL2q
         EFVv+iwVP8/ClCWMOR2DZWHhDMvGF33WeQ+iK4gRPbTLpusIPtilx2F7PH57+0Unk7J+
         XPaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ROjiC3s0siagx/fi+MGJXNVgc6kDjODdOY/lcLdmBIY=;
        b=PgFysFqq5KStPy3JZA9LRpunii4+WwhIlAGlcr/zeQqkXLfTho84wUm+mukQJ0EQ3e
         zbFYnHHy4BzkXzYri2KJwQ6Lz7bzaw2JZtZBooes3mfMWTNdgImQjJ54uhndhxc1v2cs
         ondEomc1O2bJcYCPRUaYNh6WRQvJCgEbDTUq+XxBdNYhYmT/WMnOInSyIUW7Gqu1NtAJ
         9LbShyfyCExrqRNoJhlw51wdqTHVI9rJM8TEx7E5Q8T+ewkFUbLl33l4TtKDWziZngo0
         GesNbJz1pSYXgWrLuov/SjVVKolJMt0Y2UnUPWIq0PWKjaFguc9xGgy1b864/pSC+3XU
         7KEw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Yjg83FKm;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v31sor3654715qvf.50.2019.06.04.06.02.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 06:02:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Yjg83FKm;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=ROjiC3s0siagx/fi+MGJXNVgc6kDjODdOY/lcLdmBIY=;
        b=Yjg83FKmLcCoTK1qNZRWt/34Ia4Vlgl4OzEswRBoqTA1q96rWHjxDfVIh6O7xWTGYS
         eTwCJcntFH46Tx+/cfSa7gWeHuAwOuGBn+X1jMdn5S6DRrFvNPM6afZ9JtFGwDFoFWKd
         IItwYcOZFv/0waUdBmD+9vX5g+lauIFC8gWQwZqeWZqiLI8MWTWgKqH10ZguaFNyDwaJ
         a6BouIbR+z5GvWPUxO/910/OPmm0It1HqckTeip+hRX/UhVQAxatTT7lXUHm0zw2yFJW
         DkwJjMsTV0HME+BgheyUHlaQClPbcE8mHooI7fCmf534f4AYixHfdR0GOmoGClDBYuEf
         l/5g==
X-Google-Smtp-Source: APXvYqz5RimUEjNtxNzzaaY0SoKGmFHRAnKhf0PPTePbHdJhsA1MCZNciExOvF95WwVoO+r2X/Sqlw==
X-Received: by 2002:a0c:c94d:: with SMTP id v13mr706065qvj.211.1559653328976;
        Tue, 04 Jun 2019 06:02:08 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id m5sm10984580qke.25.2019.06.04.06.02.08
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Jun 2019 06:02:08 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hY94p-0004U3-JD; Tue, 04 Jun 2019 10:02:07 -0300
Date: Tue, 4 Jun 2019 10:02:07 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-media@vger.kernel.org, kvm@vger.kernel.org,
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Yishai Hadas <yishaih@mellanox.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Alexander Deucher <Alexander.Deucher@amd.com>,
	Christian Koenig <Christian.Koenig@amd.com>,
	Mauro Carvalho Chehab <mchehab@kernel.org>,
	Jens Wiklander <jens.wiklander@linaro.org>,
	Alex Williamson <alex.williamson@redhat.com>,
	Leon Romanovsky <leon@kernel.org>,
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>,
	Dave Martin <Dave.Martin@arm.com>,
	Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>,
	Christoph Hellwig <hch@infradead.org>,
	Dmitry Vyukov <dvyukov@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>,
	Lee Smith <Lee.Smith@arm.com>,
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>,
	Jacob Bramley <Jacob.Bramley@arm.com>,
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Kevin Brodsky <kevin.brodsky@arm.com>,
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Subject: Re: [PATCH v16 12/16] IB, arm64: untag user pointers in
 ib_uverbs_(re)reg_mr()
Message-ID: <20190604130207.GD15385@ziepe.ca>
References: <cover.1559580831.git.andreyknvl@google.com>
 <c829f93b19ad6af1b13be8935ce29baa8e58518f.1559580831.git.andreyknvl@google.com>
 <20190603174619.GC11474@ziepe.ca>
 <CAAeHK+xy-dx4dLDLLj9dRzRNSVG9H5nDPPnjpYF38qKZNNCh_g@mail.gmail.com>
 <20190604122714.GA15385@ziepe.ca>
 <CAAeHK+xyqwuJyviGhvU7L1wPZQF7Mf9g2vgKSsYmML3fV6NrXg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+xyqwuJyviGhvU7L1wPZQF7Mf9g2vgKSsYmML3fV6NrXg@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 02:45:32PM +0200, Andrey Konovalov wrote:
> On Tue, Jun 4, 2019 at 2:27 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> >
> > On Tue, Jun 04, 2019 at 02:18:19PM +0200, Andrey Konovalov wrote:
> > > On Mon, Jun 3, 2019 at 7:46 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > > >
> > > > On Mon, Jun 03, 2019 at 06:55:14PM +0200, Andrey Konovalov wrote:
> > > > > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > > > > pass tagged user pointers (with the top byte set to something else other
> > > > > than 0x00) as syscall arguments.
> > > > >
> > > > > ib_uverbs_(re)reg_mr() use provided user pointers for vma lookups (through
> > > > > e.g. mlx4_get_umem_mr()), which can only by done with untagged pointers.
> > > > >
> > > > > Untag user pointers in these functions.
> > > > >
> > > > > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > > > >  drivers/infiniband/core/uverbs_cmd.c | 4 ++++
> > > > >  1 file changed, 4 insertions(+)
> > > > >
> > > > > diff --git a/drivers/infiniband/core/uverbs_cmd.c b/drivers/infiniband/core/uverbs_cmd.c
> > > > > index 5a3a1780ceea..f88ee733e617 100644
> > > > > +++ b/drivers/infiniband/core/uverbs_cmd.c
> > > > > @@ -709,6 +709,8 @@ static int ib_uverbs_reg_mr(struct uverbs_attr_bundle *attrs)
> > > > >       if (ret)
> > > > >               return ret;
> > > > >
> > > > > +     cmd.start = untagged_addr(cmd.start);
> > > > > +
> > > > >       if ((cmd.start & ~PAGE_MASK) != (cmd.hca_va & ~PAGE_MASK))
> > > > >               return -EINVAL;
> > > >
> > > > I feel like we shouldn't thave to do this here, surely the cmd.start
> > > > should flow unmodified to get_user_pages, and gup should untag it?
> > > >
> > > > ie, this sort of direction for the IB code (this would be a giant
> > > > patch, so I didn't have time to write it all, but I think it is much
> > > > saner):
> > >
> > > Hi Jason,
> > >
> > > ib_uverbs_reg_mr() passes cmd.start to mlx4_get_umem_mr(), which calls
> > > find_vma(), which only accepts untagged addresses. Could you explain
> > > how your patch helps?
> >
> > That mlx4 is just a 'weird duck', it is not the normal flow, and I
> > don't think the core code should be making special consideration for
> > it.
> 
> How do you think we should do untagging (or something else) to deal
> with this 'weird duck' case?

mlx4 should handle it around the call to find_vma like other patches
do, ideally as part of the cast from a void __user * to the unsigned
long that find_vma needs

Jason

