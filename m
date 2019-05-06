Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4F468C04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 18:13:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05BD420830
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 18:13:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="iAd6JRjO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05BD420830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8CF4C6B026E; Mon,  6 May 2019 14:13:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 880546B026F; Mon,  6 May 2019 14:13:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 720036B0272; Mon,  6 May 2019 14:13:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2622F6B026E
	for <linux-mm@kvack.org>; Mon,  6 May 2019 14:13:51 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s21so12719551edd.10
        for <linux-mm@kvack.org>; Mon, 06 May 2019 11:13:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=RF+CoYsepNrGbmmwc3BrcU2vzqm7V7BSod886VJiwv0=;
        b=AW7MkRir1VTuF5/NN+PNQzuF4MC6o1iQNmNf9FE1MNY9/6pyeH4Wd/H5bc9Q3H3+48
         +3H9YO/De1SNOnLa/cdGH8OQq6BMUKbgYYyTOsBsaRlZ92EnD9xbOl2d5UkqYTRQGQ7H
         RuNBJdHBRItN/Arte2oHnHLCWZboO9xyTapecUkGcPmEJpLtFDz96iae/PihmKPegi6A
         5mIAwvSYZ0QXF9447AAqgrbcpufnJX7agEO+cD6aUjMmIgOGTifnAsiNAeI3sXE+S/zQ
         iCCV0KGmeEBTbj/MGgRaCMcBTDDaAZE35lwtQ9LpaNUdLuWnOzQ6O4q08cTlYltadlwd
         wdwQ==
X-Gm-Message-State: APjAAAVrb2UE2VR8MetNYrlorM0VpAc+35tTsQ87WHj2enPaVvr/U1jY
	FqRemDI4Q0l0k05w3RMdfMuGguMhu/fKn2Zta9FxGx0RYU+FLs3GjDVlwNbJTJ0+TNURNVCWaiK
	sBSkCHWMEUj4lxTRpQtQMHDv20ufm5n7qi4ZcTAsOnO3j4RkAYSq4pLoU/VShSp3tzg==
X-Received: by 2002:a50:f48d:: with SMTP id s13mr28136932edm.151.1557166430709;
        Mon, 06 May 2019 11:13:50 -0700 (PDT)
X-Received: by 2002:a50:f48d:: with SMTP id s13mr28136876edm.151.1557166430080;
        Mon, 06 May 2019 11:13:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557166430; cv=none;
        d=google.com; s=arc-20160816;
        b=ECwpFyb5CsZVJIwRyT2W2b76kKzwbZ3aoYaFm+IibqE+aZJGgYG/Pcd5/poL/ii6Rp
         I1y5FUCfjejJvL213rmqcoYlFLq3lmmIN3tukyFN1luUaFMQZayY9VHs1ZAsVLs8LUtk
         PBWTakI9ZyOqQ9syvLPhGPI3H7qH5dphY9EKqiCuPX0QU4iFMWF4l0NJqEaWPXwY2nsr
         JP2ietuY6HTvO2ln/zpEu2v1jCBGeToMzy/2ZDkr6GRuRG/5W8ikKvKYvraJybRlFrcI
         48fHoefdPx4z081r9StmiEBT6yEK/cTjp9gMLE1xmrZ9xv43qRS2hlsra735iC+yPuZ8
         SqLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=RF+CoYsepNrGbmmwc3BrcU2vzqm7V7BSod886VJiwv0=;
        b=B5OeDKNTHoVpqTZW/iHWAgkaVTXg9i8amxpQptvd4CqnznoqJtHTvtJiimof1Sdnpc
         jEII8w7OnW6AG2zYnvAGbg5cizysp/VZcXC9sRfy+n6/rqu0Ehf/Cazm8fBAa09bkstv
         4vpAD2BiP1J33XPMG2Npwo34X2/mHxuYNbiQZL8qYDj9vLNQg4aySXXsWJGCAju9w4Km
         ivT5p/s9jLQpaaCCba/h7HN2NF5KO9yRPWxl2rrfS8cet8cRyPyeOGkZRNwV2jHDPhJ2
         oBOBZz6RIR5w9dvJvGfYY0GeOoEOFfPCTHOY7YXZg4I+EeELpDYed7ntWbnJ5gmXnQhI
         XGSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=iAd6JRjO;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q12sor8777388edd.18.2019.05.06.11.13.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 11:13:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=iAd6JRjO;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=RF+CoYsepNrGbmmwc3BrcU2vzqm7V7BSod886VJiwv0=;
        b=iAd6JRjOX6cXS5y0FNW2XJ6WvvRPKYhT/6IvHlZ2418SFSqTjnGNEmEfufAH09uPtF
         49VkxpuxGKXyan9FEqMBuwApcLYmGUGixrOhtESpdlpABUMPZ7N8/UovTdziIhU88upK
         j4WE0SwVaZhfG1gNDqVLDDmhA75SiFdXba4UCXOJGgDdqfP1rS3rfmw/9d7SoRbMsGOM
         PO6LGgs5u/jSx2+y8jIHm9f8s43JUgyO4ndaBY82kSijPJK1XE4OCuAAhpxnGmqOtRBv
         IjlfDhj0TrBziM4BsbBli4RPSM49bmx3HScLhwrnqbvdsDMNlfsUYv5y2TfjyWFjkoIM
         dR8Q==
X-Google-Smtp-Source: APXvYqxFqK4/B5vwBsKri7IYoVOdJaYycRBVOH6nocLuB6+vjdSKCdwCa1fH59QgHqbrELc7DYS3V2Z28fw5LXRcLWU=
X-Received: by 2002:a50:a951:: with SMTP id m17mr26721424edc.79.1557166429629;
 Mon, 06 May 2019 11:13:49 -0700 (PDT)
MIME-Version: 1.0
References: <20190502184337.20538-1-pasha.tatashin@soleen.com>
 <20190502184337.20538-3-pasha.tatashin@soleen.com> <cac721ed-c404-19d1-71d1-37c66df9b2a8@intel.com>
In-Reply-To: <cac721ed-c404-19d1-71d1-37c66df9b2a8@intel.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Mon, 6 May 2019 14:13:38 -0400
Message-ID: <CA+CK2bAeU7LOSBt7EZ3Cverpgg-0KYgOsJfSakD3aR7NWvxBzg@mail.gmail.com>
Subject: Re: [v5 2/3] mm/hotplug: make remove_memory() interface useable
To: Dave Hansen <dave.hansen@intel.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Dan Williams <dan.j.williams@intel.com>, Keith Busch <keith.busch@intel.com>, 
	Vishal L Verma <vishal.l.verma@intel.com>, Dave Jiang <dave.jiang@intel.com>, 
	Ross Zwisler <zwisler@kernel.org>, Tom Lendacky <thomas.lendacky@amd.com>, 
	"Huang, Ying" <ying.huang@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, 
	Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	David Hildenbrand <david@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 6, 2019 at 1:57 PM Dave Hansen <dave.hansen@intel.com> wrote:
>
> > -static inline void remove_memory(int nid, u64 start, u64 size) {}
> > +static inline bool remove_memory(int nid, u64 start, u64 size)
> > +{
> > +     return -EBUSY;
> > +}
>
> This seems like an appropriate place for a WARN_ONCE(), if someone
> manages to call remove_memory() with hotplug disabled.
>
> BTW, I looked and can't think of a better errno, but -EBUSY probably
> isn't the best error code, right?

Same here, I looked and did not find any better then -EBUSY. Also, it
is close to check_cpu_on_node() in the same file.

>
> > -void remove_memory(int nid, u64 start, u64 size)
> > +/**
> > + * remove_memory
> > + * @nid: the node ID
> > + * @start: physical address of the region to remove
> > + * @size: size of the region to remove
> > + *
> > + * NOTE: The caller must call lock_device_hotplug() to serialize hotplug
> > + * and online/offline operations before this call, as required by
> > + * try_offline_node().
> > + */
> > +void __remove_memory(int nid, u64 start, u64 size)
> >  {
> > +
> > +     /*
> > +      * trigger BUG() is some memory is not offlined prior to calling this
> > +      * function
> > +      */
> > +     if (try_remove_memory(nid, start, size))
> > +             BUG();
> > +}
>
> Could we call this remove_offline_memory()?  That way, it makes _some_
> sense why we would BUG() if the memory isn't offline.

Sure, I will rename this function.

Thank you,
Pasha

