Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3072C04AB7
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 19:24:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9AC5220873
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 19:24:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="F54v5r3Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9AC5220873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 362966B0005; Tue, 14 May 2019 15:24:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 313C06B0006; Tue, 14 May 2019 15:24:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DC336B0007; Tue, 14 May 2019 15:24:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id E793F6B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 15:24:35 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id a2so18582otk.13
        for <linux-mm@kvack.org>; Tue, 14 May 2019 12:24:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=dgq3UM6Fy7t89KBsWPa/dNwubJ5x9NhFBR3nKkdGxBQ=;
        b=DEEfBicJ43Iw6YlgZCrzlW3KxqkyjvBNh8kRAfTTzUPxcM/NtErBKDgNhqBYCm9Omr
         cpJnG1wUd/AFkSYX3RTCiAAxqoKG1ZNT8rd3iOOIgT7u8HXMBEGO3iGQH/OyYGMN8smJ
         gv9lMSiRei+tGvAOed0apvmWPma45/r8z56xkvLHfMMdC3PauFJljmUQuhQLK53NY0VF
         xCwpK0I2nXI9kZoFj7q3rYU2IprRxSs7resJiV6xptrwQONR4AFTBoqincW2H/50Rt6M
         qgcsAWBjUeIGlMGsg0e/TInHp54/8A9lsEWdG/OQRTgmW7wauQ6kwN0+CfW80lkhpCSs
         cDxw==
X-Gm-Message-State: APjAAAWF2brDm2qZGVWFoACWjyybZmdx/n8k7hvWEikyEIy0tLhsRlvk
	lU3a9X/U6bnlJHo8H0O20aLnhbpx4T8OvjC+3UX/LFu633S6SFiVwEvZrz3vjaPBKcXS2dQLQKj
	2ijqO28laddHZ4BhpK1viTE4m1QHkCUtdMIaWzcuHeURkfGhbr+y33VrFMsbOvJTJjg==
X-Received: by 2002:a9d:6e17:: with SMTP id e23mr35658otr.258.1557861875681;
        Tue, 14 May 2019 12:24:35 -0700 (PDT)
X-Received: by 2002:a9d:6e17:: with SMTP id e23mr35625otr.258.1557861875150;
        Tue, 14 May 2019 12:24:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557861875; cv=none;
        d=google.com; s=arc-20160816;
        b=bhxhKR9oDlcahZNukF0phFONdA8+eAPuTZ1PmZuQmYt+m2gZ71yALdRFe6aLBtayYn
         jdXhQaJQLJEV9g46ehaS5yabKLG09WiJgKBnmYSiNJpReWSAudmGnsSrpPv7tv2jaz2N
         GM1WmLlY7B8j3LSjkJoihgS7mxx5qKP/EcU/WULZSUIvWc6s13kNuielXuBWylVWPXnV
         vd/vnuMu2cM7JeqBlhTl+cRExJdyQwr3Ixx2EH3YNuE0dVwzPkX6emIzDC4kC32+91Ie
         qXvCIYxPtdam2oxzk2kotFtVVRRjJJERhZlEaMR53PRD7+1VJYgvY9Qw3AN4iUDycsuG
         TYTA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=dgq3UM6Fy7t89KBsWPa/dNwubJ5x9NhFBR3nKkdGxBQ=;
        b=apQTaZZ77Wa2gqC+VSwsU23zhAhUQETg1gNgcSBDVQP856HIjonY5GiMmWelnTFU6/
         BQ1GJ9kZNmuCt/hskSUY4DVEq/2nZRnwX4Y/MultW79e0xT9NpdOXHwObCIoZSm/JOad
         MNeLCu0l/485raLs8qUWZh52HXxnFN1BjDWLiDQXHLz2lxtbpkQvwdCZWxWA6WlLX/mU
         PxCM1CxYNBcMrT5+7eBwP2ZUq0hPbhPyqg8VAgLMx+y7mP/EuK6w3BDAgPOfRPxraA2j
         N7devbPjImI6mhH7n5BGHpjAhtJg/+aQMrMrCutI9pNEcnzYdvHz+oX+7Bg2Q4NWHnQS
         s1og==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=F54v5r3Q;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x26sor8240290ote.128.2019.05.14.12.24.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 12:24:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=F54v5r3Q;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=dgq3UM6Fy7t89KBsWPa/dNwubJ5x9NhFBR3nKkdGxBQ=;
        b=F54v5r3Q2UY3p0fjMipKOr0SMEZcrmYQxQ6eq9lQTgFwD5XGRo7ab2Bz8ptu15lqGi
         KZME0yohwroLEHCqjTihL6T8ZzRNmzMX7XD8jv7Z+22fnjT4CvamuDPDwm9ZqC92NFbL
         psOyeN7hAWl/ayAPPh+L4sKlmOR9e4FXsgXAFcGuaBankMius3erJ5ABRCntGuZtIkgO
         9jeDxqXQHS2OhoN7nFNVwmCrmTOEL+tP7bKNE5KCXPZpUqEb8Q3ZSOO0v0EPUhAncVKX
         R8ZR5TfBmbtgDvjr2jF88CVkbM+5tHyeeTNmn91CplwgR3mz7BuLfoQZwny3cygAJMrY
         Lw+w==
X-Google-Smtp-Source: APXvYqwKrS+xjnV2C39v/K43aWh/ONuM204U4eBm/zYWLBvQbW5tmknEyf9ZYMNzmmuNbTGmVFMfdvg9LHWShr9lgv0=
X-Received: by 2002:a9d:6a8a:: with SMTP id l10mr21177381otq.197.1557861873856;
 Tue, 14 May 2019 12:24:33 -0700 (PDT)
MIME-Version: 1.0
References: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155727336530.292046.2926860263201336366.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190514191243.GA17226@kroah.com>
In-Reply-To: <20190514191243.GA17226@kroah.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 14 May 2019 12:24:23 -0700
Message-ID: <CAPcyv4jO5KA4ddvBx6PFTgv2D+PfJ4Znzt5RFP4ry9NUDZ+eSQ@mail.gmail.com>
Subject: Re: [PATCH v2 1/6] drivers/base/devres: Introduce devm_release_action()
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Logan Gunthorpe <logang@deltatee.com>, 
	Bjorn Helgaas <bhelgaas@google.com>, Christoph Hellwig <hch@lst.de>, 
	"Rafael J. Wysocki" <rafael@kernel.org>, Ira Weiny <ira.weiny@intel.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Linux MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 12:12 PM Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
>
> On Tue, May 07, 2019 at 04:56:05PM -0700, Dan Williams wrote:
> > The devm_add_action() facility allows a resource allocation routine to
> > add custom devm semantics. One such user is devm_memremap_pages().
> >
> > There is now a need to manually trigger devm_memremap_pages_release().
> > Introduce devm_release_action() so the release action can be triggered
> > via a new devm_memunmap_pages() api in a follow-on change.
> >
> > Cc: Logan Gunthorpe <logang@deltatee.com>
> > Cc: Bjorn Helgaas <bhelgaas@google.com>
> > Cc: Christoph Hellwig <hch@lst.de>
> > Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > Cc: "Rafael J. Wysocki" <rafael@kernel.org>
> > Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > ---
> >  drivers/base/devres.c  |   24 +++++++++++++++++++++++-
> >  include/linux/device.h |    1 +
> >  2 files changed, 24 insertions(+), 1 deletion(-)
> >
> > diff --git a/drivers/base/devres.c b/drivers/base/devres.c
> > index e038e2b3b7ea..0bbb328bd17f 100644
> > --- a/drivers/base/devres.c
> > +++ b/drivers/base/devres.c
> > @@ -755,10 +755,32 @@ void devm_remove_action(struct device *dev, void (*action)(void *), void *data)
> >
> >       WARN_ON(devres_destroy(dev, devm_action_release, devm_action_match,
> >                              &devres));
> > -
> >  }
> >  EXPORT_SYMBOL_GPL(devm_remove_action);
> >
> > +/**
> > + * devm_release_action() - release previously added custom action
> > + * @dev: Device that owns the action
> > + * @action: Function implementing the action
> > + * @data: Pointer to data passed to @action implementation
> > + *
> > + * Releases and removes instance of @action previously added by
> > + * devm_add_action().  Both action and data should match one of the
> > + * existing entries.
> > + */
> > +void devm_release_action(struct device *dev, void (*action)(void *), void *data)
> > +{
> > +     struct action_devres devres = {
> > +             .data = data,
> > +             .action = action,
> > +     };
> > +
> > +     WARN_ON(devres_release(dev, devm_action_release, devm_action_match,
> > +                            &devres));
>
> What does WARN_ON help here?  are we going to start getting syzbot
> reports of this happening?

Hopefully, yes, if developers misuse the api they get a loud
notification similar to devm_remove_action() misuse.

> How can this fail?

It's a catch to make sure that @dev actually has a live devres
resource that can be found via @action and @data.

