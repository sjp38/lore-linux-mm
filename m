Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90230C48BD7
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 18:04:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F62520883
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 18:04:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="JxNg8q13"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F62520883
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1D9F6B0006; Tue, 25 Jun 2019 14:04:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DCEBA8E0003; Tue, 25 Jun 2019 14:04:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C6F948E0002; Tue, 25 Jun 2019 14:04:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9E7126B0006
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 14:04:07 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id b4so9499335otf.15
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 11:04:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=v+ZhBSNWMG71/hoVLbHT+wkJMxkbtm8D8gJnUatkLjU=;
        b=t5mfubgVH8qT9F28mkmZOKQOp9tigoHS95eVUSxWruhCmsBmYNtsYY9h2UuNjbp+EP
         D6Q5tHVAe8hulpGyyRjhqykPZuauMtZH6xp+ahegOeDSUBS92t3/A5OqxlobnO9dVfBG
         8wVraiQ2Z2NlYSn4ZYgWvaBvPaxfErp9CHC10dHDyDFswAyHpVC9vZ3eS/6iDf4qmhOm
         ezpRShNs7FcH+56NNp54KcOFgYjvmfUrz2pm9TzJONDi3IlEXQSV/9C959sYEJH7Q/Dz
         7FxKD88R+a1lrTjnRbt0OmGdZ1cSHirM6yKIBlf0H3/aC2HeEtFci4uSwjyJLKItks9U
         4GQg==
X-Gm-Message-State: APjAAAXehtddSW9vwz55TcPXphEI7CcXKtDgOF7CGSEoeO5TRQ9hlSxh
	SlYJ54pEcn1nOl/rdIzFDb3+4/vcuCJuak0ZcUwxkdFXCyUlOJof+OKDrFshl7SACqV0NIrJLdq
	hVv0Ef54Uq9RDdSoClPIxxLdUeEgIeWsdOPI+8yUMSIlwrh5fyoVNfEtpEmvPe7CtLg==
X-Received: by 2002:aca:add8:: with SMTP id w207mr3799293oie.131.1561485847192;
        Tue, 25 Jun 2019 11:04:07 -0700 (PDT)
X-Received: by 2002:aca:add8:: with SMTP id w207mr3799239oie.131.1561485846259;
        Tue, 25 Jun 2019 11:04:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561485846; cv=none;
        d=google.com; s=arc-20160816;
        b=AzW+SS5Slpr9gFJLMwuMGTo8QEE3izPaihvlyYhrSoCJ2z0qoBn4XcSYvk9zFVDZNZ
         DjVRs+tzDEs5FqILB7f+IPQ3hsI54UhX/+IL7jhaaFAILPMjBHsc5SAZuET/YZVafhZC
         uqwIXgdfo2VaScTsQ6E9jqmQSTi9Lwsyxg9YuF09x9NEdoY1NrqqrpE42LodC2uRU3LS
         MOKcUpO9Aul0N1P5TFHZsBBsIlVfZQ2fQZ+/bb/Htlw+kk4zxdQHXxgDtNiLprBmiguU
         Tb8O7a7+8CyMdlA48k9BunjXqFJ2QZEuR1KrWTmQFkrnrR4n+R/dqEH/8xsJ3l7hdHbT
         25IQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=v+ZhBSNWMG71/hoVLbHT+wkJMxkbtm8D8gJnUatkLjU=;
        b=FIMxwJ1Urd/XEDrllraz+qgtBzQEMHDFFwhpS5HFnprWaU+Cwu5nTU4c8yHXqp1hQ5
         NL4Bm/02K5OFzprqgUtY0GlT8FPKewwOwqIIsf9fcSgnN0pTo56tSqhhpFarNm64yd6H
         ZqnvXssMxAPVhyQ/Tl3cCY/Fj3cSG9qCHrhiWUuoZKc+kFY4ohmDpWyZGIG+o6oV38zQ
         LlGZWAVpVlobS2nJEOH5W14ChThQqurQdj5K4IE04SqhRNAWdsmE2qUG6VbBlCDv0LTb
         DB1oUzDBoZgGuTrtrnAJPIToZR0zEUqYQWGXXjxLdQggE7fkFDSiyVkBrPUoaBX9AXy1
         YjyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=JxNg8q13;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o132sor6731560oib.89.2019.06.25.11.04.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Jun 2019 11:04:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=JxNg8q13;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=v+ZhBSNWMG71/hoVLbHT+wkJMxkbtm8D8gJnUatkLjU=;
        b=JxNg8q13dPoy4++bWTLKe91YyHwlNjFnbzSb9Om/uZZjmzDhnDweJK+SXVAHxvQJR0
         312VGhMneNMNXAmSV6hMRZIzT4bIOEkHXQoVC3M4u9DoF+fAlTSvPDyjEiVH1eTZKAv6
         dp2nCpruoX6QC/iIKdTTjv2kOKKIAnLDyxY0m5z6y8S0clG2ID2Kd3dCyQI6rh541kFT
         eDdVfoEDrUI7YN4BuqjchbcpiBzhNte5u19MgaVZHdA1NCRepz4PjjVsuhg3X5n+bs85
         X+HfBTjHRFVQoAtJFMiji2LpwQIjXK1seUAZDPl9j1P4iwnhlcEX3jRF05VVFomoae2Q
         6U5g==
X-Google-Smtp-Source: APXvYqz6T9TVXWGjVm88Qsyic/J7sZ8rY/3bbGIhMBzOCJnst1XOiiw6CA8iBdJBDNkwj6/NRoOe4+QnfOGQ8i6wx08=
X-Received: by 2002:aca:d60c:: with SMTP id n12mr15532591oig.105.1561485845899;
 Tue, 25 Jun 2019 11:04:05 -0700 (PDT)
MIME-Version: 1.0
References: <20190613094326.24093-1-hch@lst.de> <20190613094326.24093-6-hch@lst.de>
 <20190620191733.GH12083@dhcp22.suse.cz> <CAPcyv4h9+Ha4FVrvDAe-YAr1wBOjc4yi7CAzVuASv=JCxPcFaw@mail.gmail.com>
 <20190625072317.GC30350@lst.de> <20190625150053.GJ11400@dhcp22.suse.cz>
In-Reply-To: <20190625150053.GJ11400@dhcp22.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 25 Jun 2019 11:03:53 -0700
Message-ID: <CAPcyv4j1e5dbBHnc+wmtsNUyFbMK_98WxHNwuD_Vxo4dX9Ce=Q@mail.gmail.com>
Subject: Re: [PATCH 05/22] mm: export alloc_pages_vma
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>, Linux MM <linux-mm@kvack.org>, 
	nouveau@lists.freedesktop.org, 
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	linux-pci@vger.kernel.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 25, 2019 at 8:01 AM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Tue 25-06-19 09:23:17, Christoph Hellwig wrote:
> > On Mon, Jun 24, 2019 at 11:24:48AM -0700, Dan Williams wrote:
> > > I asked for this simply because it was not exported historically. In
> > > general I want to establish explicit export-type criteria so the
> > > community can spend less time debating when to use EXPORT_SYMBOL_GPL
> > > [1].
> > >
> > > The thought in this instance is that it is not historically exported
> > > to modules and it is safer from a maintenance perspective to start
> > > with GPL-only for new symbols in case we don't want to maintain that
> > > interface long-term for out-of-tree modules.
> > >
> > > Yes, we always reserve the right to remove / change interfaces
> > > regardless of the export type, but history has shown that external
> > > pressure to keep an interface stable (contrary to
> > > Documentation/process/stable-api-nonsense.rst) tends to be less for
> > > GPL-only exports.
> >
> > Fully agreed.  In the end the decision is with the MM maintainers,
> > though, although I'd prefer to keep it as in this series.
>
> I am sorry but I am not really convinced by the above reasoning wrt. to
> the allocator API and it has been a subject of many changes over time. I
> do not remember a single case where we would be bending the allocator
> API because of external modules and I am pretty sure we will push back
> heavily if that was the case in the future.

This seems to say that you have no direct experience of dealing with
changing symbols that that a prominent out-of-tree module needs? GPU
drivers and the core-mm are on a path to increase their cooperation on
memory management mechanisms over time, and symbol export changes for
out-of-tree GPU drivers have been a significant source of friction in
the past.

> So in this particular case I would go with consistency and export the
> same way we do with other functions. Also we do not want people to
> reinvent this API and screw that like we have seen in other cases when
> external modules try reimplement core functionality themselves.

Consistency is a weak argument when the cost to the upstream community
is negligible. If the same functionality was available via another /
already exported interface *that* would be an argument to maintain the
existing export policy. "Consistency" in and of itself is not a
precedent we can use more widely in default export-type decisions.

Effectively I'm arguing EXPORT_SYMBOL_GPL by default with a later
decision to drop the _GPL. Similar to how we are careful to mark sysfs
interfaces in Documentation/ABI/ that we are not fully committed to
maintaining over time, or are otherwise so new that there is not yet a
good read on whether they can be made permanent.

