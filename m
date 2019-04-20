Return-Path: <SRS0=t1VS=SW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42E04C282DD
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 23:19:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3AB820821
	for <linux-mm@archiver.kernel.org>; Sat, 20 Apr 2019 23:19:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="L6bjxaxQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3AB820821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F5A26B0003; Sat, 20 Apr 2019 19:19:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A6AF6B0006; Sat, 20 Apr 2019 19:19:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E89486B0007; Sat, 20 Apr 2019 19:19:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id B7EDC6B0003
	for <linux-mm@kvack.org>; Sat, 20 Apr 2019 19:19:38 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id j20so4952876otr.0
        for <linux-mm@kvack.org>; Sat, 20 Apr 2019 16:19:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Nnv3nFKnHwdfb1tQUBBdChAgSYqjmcWYJ4x8yIvqqBk=;
        b=so7Lwe28I29w6I1fKXQkAjrxArVZ35rrG3Z2+C1Aiot6Wmd8oBbH9NGcQsrDUIMX/3
         /W3IMPMNNFT9ZEiKIGUbtvyno3SrzHuz09i5pHqDP3QPzxj/P4SLA8Eqft7LUuajEQRv
         BxYY0u6Z6IWWaVnF9xBOVmNr/1O67eEJWy1R2Sf/oFuU+mhflyuMtNu9Jgte3kuMD4Mx
         Iy7XnuhQ8MQ56j59/KOJwsMl6WqpntV3z4ZWDm/KiPGod8WwOvIM5BeIU1xb4pl7lz05
         7zmdODlV3PTgh0MDZ/lR74kgiBiYTEUNusKMY+XUH3c7BKaYn6Y5YskslxJxAeqepdMF
         ZsFQ==
X-Gm-Message-State: APjAAAXgtArOhqjSZAjRUupN7fZkal/z0CpbNErp4Xd3BgAsNhhF/mks
	3ZjSQr/12+tu7/OWSjZmC6VkHLcbbf7JrIBgs09RrFlZ2v7SQbykSnCKx4WN9BG69OIU219EZ3V
	3G+r/TI/GzdufTXwENC6y887rUpRzZtLIXFVNvHNwB5v+l+HyvNKgwpUmZ7DqUqnPZw==
X-Received: by 2002:aca:abce:: with SMTP id u197mr6203403oie.67.1555802378190;
        Sat, 20 Apr 2019 16:19:38 -0700 (PDT)
X-Received: by 2002:aca:abce:: with SMTP id u197mr6203381oie.67.1555802377406;
        Sat, 20 Apr 2019 16:19:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555802377; cv=none;
        d=google.com; s=arc-20160816;
        b=zZQToO+Bd87/TezMqFo6j3O0MykrBUNRdGzIRsZfkNUftHFAs02Oho27vC+tcyYubV
         B/g2KHOJYNdR7mLUml+1YfRBSEEn+D6EnIeGOFJgGDLDbFBEaOfgJDhpCvEh5ujd54xG
         442OpCNI1L5ggfvLzRXoOaYd/MaU4NGLPv1/va6uE79fUUd7Wu3Z6HeyQV/GfL19roVx
         LFNW/2OQOWz/qxUj1xebdeu8Otq3qcc8egbKenck57Ps5p5+DmnmKgAqHajFAsaIfCTG
         r6Ws6zJlOa9+FzAWeT4UQ+3oaoixGIswcdwlJc2E/fvcUW3Uzd/TOyreKSIkc2x3hnne
         bF7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Nnv3nFKnHwdfb1tQUBBdChAgSYqjmcWYJ4x8yIvqqBk=;
        b=vs62TUuFeH03kkvyDHqkhs8EkOl1arJEt4DdGCrg7qtrFb969lOK0zLhz/m54ckcd5
         dUvnxdDehVHpwhfVT4k+y+QHrkUySa/S+5JicEqANXh1pPz1LzZgtqE3jznZP05gPP8B
         DFJjcGrtScCwKIzfjpKEsT/U/YSNircuHUyB52a0uERm6BSzVd47DYInF4cmqFDoJQ4I
         1l98ZfzBJUWN1a/4ktJFnG7obB07CP7OYB0NMTlPMYGxfGrMQgLqbBtVdjz9NyOdp0eM
         YkDz4kB7wFMAwwBR+nJVJoGo93XCMORch8H8lJrMYz1bznlO4zofoMwBrJrcOKgYZiCm
         Ca3g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=L6bjxaxQ;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r83sor3822728oia.30.2019.04.20.16.19.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Apr 2019 16:19:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=L6bjxaxQ;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Nnv3nFKnHwdfb1tQUBBdChAgSYqjmcWYJ4x8yIvqqBk=;
        b=L6bjxaxQljUFK9wvHH6ANy4kjjAuOH79E7XwtzfGFJ0b6UKLFYtcFZRpHIEvK81bsi
         OVAlVKUsU/0IiCPbD57ovHV6jVz0Ywx6QSrRZBDkuiskj1qNyAsKh32LZdVjX9nFF5Tw
         2s3CK4FqmzH4cKjeGtzCqo+7xFCmWzAxlSsx+l3i0HqZZ0qUkofNSvIgkgTsvoh4UqpF
         48ZdTHmg3QwyfUzAtCImu8LNhk7SQtzQe0kfkNyfzDEGRd+gShRISNr4RYogxdj6xpoU
         mU2fdJUOn6etaYH3VuqF1GHcsMXadvThGI+yzEBsZsFAaJnk37eYkH2IY2NpJnzh8a6L
         PzGQ==
X-Google-Smtp-Source: APXvYqzxeewGoMHfjWesxJnv2BsUMO5Z+mG7JRGSsX09T0mBiWN2H+7ua0kGSQ8bbN3T9n9QOFSL8pMp71DkNHXugzM=
X-Received: by 2002:aca:f581:: with SMTP id t123mr6399074oih.0.1555802376510;
 Sat, 20 Apr 2019 16:19:36 -0700 (PDT)
MIME-Version: 1.0
References: <20190420153148.21548-1-pasha.tatashin@soleen.com>
 <20190420153148.21548-3-pasha.tatashin@soleen.com> <CAPcyv4j9sG6Wy3EfTuPb0uZ2qp=gr9UgUhpnXQA_g6Ko9KFmLA@mail.gmail.com>
 <CA+CK2bA2QTzZtFvGRMaG10_TretDr6CGgZc4Hyi_1pku4ECqXw@mail.gmail.com>
 <CAPcyv4jrxMNEEeUZZG3=CdkYSyX7OtJLv_ZQ1gbML7bscePiQA@mail.gmail.com>
 <CA+CK2bA-wDwRT5Gv2p9Nm1Vr8LNg84rQdE6=s2m2hQLYqj5Rog@mail.gmail.com>
 <CAPcyv4gBu5QhgRQ+maJs108JwBrcCa9U1e9wgO8FP6Q3qwy69g@mail.gmail.com> <CA+CK2bBFqq0tNOE9gh7JAhjw8XLW_pMpVQtUwbm6JwW=LWt_iQ@mail.gmail.com>
In-Reply-To: <CA+CK2bBFqq0tNOE9gh7JAhjw8XLW_pMpVQtUwbm6JwW=LWt_iQ@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 20 Apr 2019 16:19:25 -0700
Message-ID: <CAPcyv4in0N9yHzXBWTBTyeYcLgxKBkjj2UBPLpkBuyP2kUY22w@mail.gmail.com>
Subject: Re: [v1 2/2] device-dax: "Hotremove" persistent memory that is used
 like normal RAM
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Keith Busch <keith.busch@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, 
	Dave Jiang <dave.jiang@intel.com>, Ross Zwisler <zwisler@kernel.org>, 
	Tom Lendacky <thomas.lendacky@amd.com>, "Huang, Ying" <ying.huang@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Apr 20, 2019 at 3:04 PM Pavel Tatashin
<pasha.tatashin@soleen.com> wrote:
>
> On Sat, Apr 20, 2019 at 5:02 PM Dan Williams <dan.j.williams@intel.com> wrote:
> >
> > On Sat, Apr 20, 2019 at 10:02 AM Pavel Tatashin
> > <pasha.tatashin@soleen.com> wrote:
> > >
> > > > > Thank you for looking at this.  Are you saying, that if drv.remove()
> > > > > returns a failure it is simply ignored, and unbind proceeds?
> > > >
> > > > Yeah, that's the problem. I've looked at making unbind able to fail,
> > > > but that can lead to general bad behavior in device-drivers. I.e. why
> > > > spend time unwinding allocated resources when the driver can simply
> > > > fail unbind? About the best a driver can do is make unbind wait on
> > > > some event, but any return results in device-unbind.
> > >
> > > Hm, just tested, and it is indeed so.
> > >
> > > I see the following options:
> > >
> > > 1. Move hot remove code to some other interface, that can fail. Not
> > > sure what that would be, but outside of unbind/remove_id. Any
> > > suggestion?
> > > 2. Option two is don't attept to offline memory in unbind. Do
> > > hot-remove memory in unbind if every section is already offlined.
> > > Basically, do a walk through memblocks, and if every section is
> > > offlined, also do the cleanup.
> >
> > I think something like option-2 could work just as long as the user is
> > ok with failure and prepared to handle it. It's already the case that
> > the request_region() in kmem permanently prevents the memory range
> > from being reused by any other driver. So if the hot-unplug fails it
> > could skip the corresponding release_region() and effectively it's the
> > same as what we have now in terms of reuse protection. In your flow if
> > the memory remove failed then the conversion attempt from devdax to
> > raw mode would also fail and presumably you could fall back to doing a
> > full reboot / rebuild of the application state?
>
> With option two, where we will simply check that every memory_block is
> offlined, we will have deterministic behavior:
>
> 1. If user did not offline every dax memory section beforehand via
> echo offline > /sys/devices/system/memory/memoryN/state
>
> echo dax0.0 > /sys/bus/dax/drivers/kmem/unbind
> Will be the same as now, will simply return, and user won't be able to
> use dax afterwords or hotremove it.
>
> 2. If user did offline ever dax memory section beforehand
> echo dax0.0 > /sys/bus/dax/drivers/kmem/unbind
> Will be guaranteed to succeed to hotremove the memory, as there is
> nothing that can fail.
>
> So, if user wants to hotremove dax memory, he/she must ensure that
> every section is offlined before unbinding.

Sounds reasonable to me.

