Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DE37C43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 21:44:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 492D720652
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 21:44:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="WvrRJZck"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 492D720652
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CAE5C8E0003; Wed, 16 Jan 2019 16:44:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5CCA8E0002; Wed, 16 Jan 2019 16:44:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B25F88E0003; Wed, 16 Jan 2019 16:44:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5709E8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 16:44:38 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id f6so1926591wmj.5
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 13:44:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=amyYQ0mfOwL3n6qC0TXaw+DPRTwqAe3I4F6HyJ5F61I=;
        b=YBbX3+FwPp231Iu0XqUL0MAc+lSdkdO2rE1XyRdnCNiHMLwBIewIdRRtAVX41lQyCp
         ku6aQ/soWODoynHC6ktbk86OQfRRQ9IcBgI4rnRQb+d+pmO108l4Go6ctxT9lD/cIcXR
         qpWQDbbNlixeIHcaq9KgjObuoM9EfwapP2ZiR4EWETF5f30EWr93WM5pT36mNdygU9nd
         pzmTPbHnkm6GD47G8rHiYNCl895G0fBKpV08Tl5zZcvAanjMyNS+nq1/D7cOiW786Lop
         e3eXOb5U2x3hufZoG/FSb5w/F/Hf5pclvYDbjhYg6T3PCLw9yJRg+0LiFudxz7BKV1tK
         50NQ==
X-Gm-Message-State: AJcUuke0Vgomf5soI0m/1k7StgYwGgvexLxkQ5U8Xp8zqy02rDCKsanS
	BfSaddcgRf/KXFhbqwWqukjT2c50dIazvZpl1j4R2r+3ND0RIaN+IZJnzq5R+4P3Xy7PILvBwB2
	7lxM1Ljx+zlAf1ktLPMGEAvPbthdbc7shtEfikskG777NgGgC9jrQwQHUCWj0QQeCTf4hItJ92x
	Bdzr028NIvEAuEG5yYMCCmh9ocZFLRpUu+6Sj3emHeACxNpVhfJr6vR5XMiAS1YfRVJH4lXWfxB
	f67qjQvwcobVke5hiHhHxePCJTRnnoDa7mdPbw79SpK6SrHAEgoKhh92CLr6BQLFLGbrUPSm70o
	0FdweaJs7wRpLWnBocNgKgYpbu3D7fyqi7qPQ5FynDQ2BJHv2DndoSvmJGvwZlTfaeta4KtwVW4
	W
X-Received: by 2002:a1c:2902:: with SMTP id p2mr9037415wmp.19.1547675077917;
        Wed, 16 Jan 2019 13:44:37 -0800 (PST)
X-Received: by 2002:a1c:2902:: with SMTP id p2mr9037385wmp.19.1547675077045;
        Wed, 16 Jan 2019 13:44:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547675077; cv=none;
        d=google.com; s=arc-20160816;
        b=ba1AQxvoVReW7/CHzb69M0PTDFFtkyPSnk0zdiO2HyNZ77YwrqSv8gawj2xiKj5Ud4
         Wb1F7c8+t2vOrm4rYEwkft9m6JDxq4LbizeOddm5/H2MkpL+YFl/YBcK6WGzB1fBwVqo
         3jYz/KbFL01CUqoEUwUG2UdjR3Sh7mMzUQcqef0eE4xjOEzvErA5C7/YcU/nxMIupI8d
         vDV6CnmGTjBJyMfFit3LV+NAMsFPIvH6/Z6mbDpz289azufxi9Lua4CLcgSUBfa7do0l
         oNBlhAm8rtKOpt1AjVcuUWxCLrkw9r9bv9eRh/85p6S7s3+Md00j8JuNaoBZ2Y8uHz0k
         9diA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=amyYQ0mfOwL3n6qC0TXaw+DPRTwqAe3I4F6HyJ5F61I=;
        b=0ZcKOrxPwOrkYFX7cRCjGn5g0G7F1lYdprnQAZy97S+ThW45cdVMvw+W5ZOKbAv1zX
         xkJ/hoWROFChyj6gw1yInLrDfMqyaG0KKv95pdy+iBAPycj5fyr5iWWDeAQAl1ZhTvkN
         eMtHMktm90kr4v6ri5OuUVsuMovcB+aSrEr/a27fYkd7iG3E03TcrrH1fcSFSMfS2cS+
         8AZeT0sb8MsyQGa7E84PDRchlAWLisQwx9imJbJwiVxKG8iel4DzIGO/Yi2qGKhuINph
         WlSWqq7Tso27wOGWZEWAAP8vVvZSGbo2Xh38+oW7RdSwy15xAfJuoSLuxngfpq0Km4ZT
         6p5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WvrRJZck;
       spf=pass (google.com: domain of bhelgaas@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhelgaas@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r4sor21202567wmr.10.2019.01.16.13.44.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 13:44:37 -0800 (PST)
Received-SPF: pass (google.com: domain of bhelgaas@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WvrRJZck;
       spf=pass (google.com: domain of bhelgaas@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bhelgaas@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=amyYQ0mfOwL3n6qC0TXaw+DPRTwqAe3I4F6HyJ5F61I=;
        b=WvrRJZckgwYnrL8o7H1BhdjbnhUOYZ5cIpiQdXpURKsYQUjBW2kOU4fugchO1Cl4cG
         I/S6SqE+nOQTxvbLPDMfKOPzbnDzFkZhooeD8XGQ0EnzNKKCEgkkxvJALkT0CMe6Kywr
         ZwpQ7x9EkJMHlUql89jGO5p0M7ATjqCAxzwGzychKyRuj536GlWdmov6D4A5G48RGA97
         yEP1BQ9JK95B5AA8idfBRF6opo+UmIX1Yk1OQs2uZg0aUdP7Anmr3dK8UbeQ4ymZS/yC
         qAIv2cbK03txqy/MH7MrDZL0H6nUWVgBTCVY28kOU8wgJ15IeorgnSEIIvrhQrC3iIS/
         Szxw==
X-Google-Smtp-Source: ALg8bN4aRs8NjUoaYnVv6BJ5a7G4g1K/+JOsgkZQhu8PJhsiMXYYgLxhSUX8+eErltERHwUCx6l/99SRc8QVR567Q/A=
X-Received: by 2002:a1c:5984:: with SMTP id n126mr8815661wmb.62.1547675076484;
 Wed, 16 Jan 2019 13:44:36 -0800 (PST)
MIME-Version: 1.0
References: <20190116181859.D1504459@viggo.jf.intel.com> <20190116181905.12E102B4@viggo.jf.intel.com>
 <CAErSpo55j7odYf-B-KSoogabD9Qqt605oUGYe6td9wZdYNq_Hg@mail.gmail.com> <98ab9bc8-8a17-297c-da7c-2e6b5a03ef24@intel.com>
In-Reply-To: <98ab9bc8-8a17-297c-da7c-2e6b5a03ef24@intel.com>
From: Bjorn Helgaas <bhelgaas@google.com>
Date: Wed, 16 Jan 2019 15:44:24 -0600
Message-ID:
 <CAErSpo6ipXF1P=tHif_ezksD_ka54LYqsc1B11Ddfksm2hp6Jg@mail.gmail.com>
Subject: Re: [PATCH 4/4] dax: "Hotplug" persistent memory for use like normal RAM
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Dave Hansen <dave@sr71.net>, 
	Dan Williams <dan.j.williams@intel.com>, Dave Jiang <dave.jiang@intel.com>, zwisler@kernel.org, 
	vishal.l.verma@intel.com, thomas.lendacky@amd.com, 
	Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, linux-nvdimm@lists.01.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 
	Huang Ying <ying.huang@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, 
	Borislav Petkov <bp@suse.de>, baiyaowei@cmss.chinamobile.com, Takashi Iwai <tiwai@suse.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116214424.bKyo-l8XBWwilauWDQ_I0FcWv0Zw7QfxjtjlU1y5RF4@z>

On Wed, Jan 16, 2019 at 3:40 PM Dave Hansen <dave.hansen@intel.com> wrote:
> On 1/16/19 1:16 PM, Bjorn Helgaas wrote:
> > On Wed, Jan 16, 2019 at 12:25 PM Dave Hansen
> > <dave.hansen@linux.intel.com> wrote:
> >> From: Dave Hansen <dave.hansen@linux.intel.com>
> >> Currently, a persistent memory region is "owned" by a device driver,
> >> either the "Direct DAX" or "Filesystem DAX" drivers.  These drivers
> >> allow applications to explicitly use persistent memory, generally
> >> by being modified to use special, new libraries.
> >
> > Is there any documentation about exactly what persistent memory is?
> > In Documentation/, I see references to pstore and pmem, which sound
> > sort of similar, but maybe not quite the same?
>
> One instance of persistent memory is nonvolatile DIMMS.  They're
> described in great detail here: Documentation/nvdimm/nvdimm.txt

Thanks!  Some bread crumbs in the changelog to lead there would be great.

Bjorn

