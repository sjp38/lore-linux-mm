Return-Path: <SRS0=o7Ai=QB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A441EC282C6
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 19:15:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65D402087E
	for <linux-mm@archiver.kernel.org>; Fri, 25 Jan 2019 19:15:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="j0naHyGZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65D402087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EACDD8E00EA; Fri, 25 Jan 2019 14:15:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5B7C8E00D7; Fri, 25 Jan 2019 14:15:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4AB48E00EA; Fri, 25 Jan 2019 14:15:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id AA7078E00D7
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 14:15:22 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id z6so4176685otm.10
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 11:15:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=FXX004AUcxBjaHmlWfnuskZBXjN2zPH5jsYaxqyIBbA=;
        b=HwqgpCSTekl8V0lMwM6ghZbAo2bDr9RTy7rEsUP32pZQLyZcwrvY17aFpkT1dKozfk
         pOUYmNqm3mxURZiy/WU2arFW+t5sDKAZdRI3xQsNw739PSJ0rTMODrVSy0ybONu2o3MZ
         kMvMIkSZZ8flZ5avaKWX8OKWVk4ZEK5KEN6saqFPBekJKdGLHRRfczpp6evdZb5k9kJd
         KJw5Sl1PLlCBNwDLAmh20ak953WUF733+GMiQr07ThVUGdVyZJEQkK30dkJXGro+dKTg
         VXdcWw8+EbEzrBscFlui89TaA1XGNwdXlDoGjgKJPlaW8Le+gR6xcrgsjrGNmfPW7+Ud
         DNxA==
X-Gm-Message-State: AJcUuke7xLrtZAFgJ/vKlhI9PMaGI0qoY3LY/JOE5ac1kAdt/Z/Y+CG4
	O4LGYzVyovH4FacNqBpUWIIS//jUSasGeEVcpnpr+5wfD5ZchkAUvFXYUXcH38qxKIju9t/IVZK
	ewqQfDEuHkwYGv3nH7iI9kx8SQY46dKDN92WGjxxwWRDlmZqWyD5QhZjkbu8swB/DRd2TKYQrpO
	9GiKfupJcY7oblatHU0OSrMBzX3pwm6um69OoJou1D9t6YviTN1uKR9OkmVHiUQPWcrnlRmxcQP
	C+7NZiuOd7epmCL91KtPEbmO0GB8svnHPTJwSIgs/2DOfjcugfwQGi0zxEyaHgPiu3Tl2T8/jnB
	EJI3FUSEwUUmYBMQRqXEt+9DDy55OWJXUHXWTuQI5E+5Y4opBra4rK3QFK+tQnMjbRTGbibwSsQ
	x
X-Received: by 2002:a9d:6b11:: with SMTP id g17mr8670304otp.70.1548443722353;
        Fri, 25 Jan 2019 11:15:22 -0800 (PST)
X-Received: by 2002:a9d:6b11:: with SMTP id g17mr8670269otp.70.1548443721653;
        Fri, 25 Jan 2019 11:15:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548443721; cv=none;
        d=google.com; s=arc-20160816;
        b=bdqBpWmgEhfJiQ7MpXKlIQeSsXPwehYwFFCGBis8yWbTx/HALNmRKfrBKu/UIvuphC
         Qu7S5LrajWuP4zGCBMyegfh7O19eCpU7H0eZikQ8DQr0jug1xcMFdgg/4eC6EPtf21EK
         5UoNLLp5U19HNvTNLpzAJIaxhM3TME/0EXtRP73leF7yCbvVtj8KFJRzMcEPh7WRTmpC
         qE2fKslw4pJe2sMghkSKXc6i8USF5rKbwOsSf94bCiOn3OoEjhs8f1QVdkDzTt/91fKi
         5diVBfwQXyHgtGCBkTc4O4Ba06/9EAld1OZJi2ui6rKpbSJ2y3nZMmU2uX0lR/VonFFK
         WcwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=FXX004AUcxBjaHmlWfnuskZBXjN2zPH5jsYaxqyIBbA=;
        b=aqr7a/AIWRaDER4jDCpBxqtZoH/epHLTnaq3enC6SZUF74BGnQWeusOJGqM96kRjEs
         zqH7+kjc+dc289zcO5hApksM7+OFMHAhwEfBgK1JGQSxgCdQg2pHMiZHbu9MyN7hrmZ+
         Sz9ikfVBLDW9ET05YSZoAbUEB5PBa+Dwz9m6mkubMKn/gSc4pWLzws1Qq2/PIKb58DpK
         cd+3akZ/98jq9hd60Qz/HA2zZe9IeGlj7wgrHFDUYgKBF0tOkhEJg5tWWsDEbt8lcj3m
         +OqLD8XxEictUIHYtAAnkdNNWB4zMDTdeg+s31ozyhR6gLdOXnIvRHjP4f5OwsX13zyD
         LWqA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=j0naHyGZ;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l109sor2017138otc.139.2019.01.25.11.15.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 Jan 2019 11:15:20 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=j0naHyGZ;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=FXX004AUcxBjaHmlWfnuskZBXjN2zPH5jsYaxqyIBbA=;
        b=j0naHyGZb7bTOZgS5cKphb1EaD6TDe8yYOuc3+W4EFKKF0dqoNYQZ0C4GxAOqGhQ0X
         pDtgQ8ti8VVxXkKWPEGq6sFIatbuZTQJsxj9O6U9667pmeSAPODPTPkR+ObAPZ7TYKAp
         b+S3oydSEbwteEh7fUofOubhcbLuzrle7wQ6ofNxh5mE5DmTJaj0CZHHIh1JePCh7Tpd
         no+lYtsUgMbOTmxgMlqB61uSNA2maTzIvV31tyt+a4Dj2bm94JzAvP/J3c+XsxUY15rR
         Hxif60hGnf80FZo9hzMvwmIq05FLlUTS0Ai7LIWG5rW6TKsGwyfUHyaPv9JrXdcZVs0/
         4tCA==
X-Google-Smtp-Source: ALg8bN6Kb8jFPohdwfb3jz7Y3w7BALuAbBbG0OIeL/vtE/+MMlIOH5lQdmAqpGvcB0DV1IB9r3F6bfAyrB9ZgAkju/M=
X-Received: by 2002:a9d:6a50:: with SMTP id h16mr8256461otn.95.1548443719889;
 Fri, 25 Jan 2019 11:15:19 -0800 (PST)
MIME-Version: 1.0
References: <20190124231441.37A4A305@viggo.jf.intel.com> <20190124231448.E102D18E@viggo.jf.intel.com>
 <0852310e-41dc-dc96-2da5-11350f5adce6@oracle.com> <CAPcyv4hjJhUQpMy1CVJZur0Ssr7Cr2fkcD50L5gzx6v_KY14vg@mail.gmail.com>
 <5A90DA2E42F8AE43BC4A093BF067884825733A5B@SHSMSX104.ccr.corp.intel.com>
 <CAPcyv4ikXD8rJAmV6tGNiq56m_ZXPZNrYkTwOSUJ7D1O_M5s=w@mail.gmail.com>
 <b7d45d83a314955e7dff25401dfc0d4f4247cfcd.camel@intel.com> <dc7d8190-2c94-9bdb-fb5b-a80a3fb55822@oracle.com>
In-Reply-To: <dc7d8190-2c94-9bdb-fb5b-a80a3fb55822@oracle.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 25 Jan 2019 11:15:08 -0800
Message-ID:
 <CAPcyv4hEyG-1hC=20M7YGFG-BF7yvNcG7EkLurAfysHHB2yXBA@mail.gmail.com>
Subject: Re: [PATCH 5/5] dax: "Hotplug" persistent memory for use like normal RAM
To: Jane Chu <jane.chu@oracle.com>
Cc: "Verma, Vishal L" <vishal.l.verma@intel.com>, "Du, Fan" <fan.du@intel.com>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "bp@suse.de" <bp@suse.de>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "tiwai@suse.de" <tiwai@suse.de>, 
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>, 
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "jglisse@redhat.com" <jglisse@redhat.com>, 
	"zwisler@kernel.org" <zwisler@kernel.org>, "mhocko@suse.com" <mhocko@suse.com>, 
	"baiyaowei@cmss.chinamobile.com" <baiyaowei@cmss.chinamobile.com>, 
	"thomas.lendacky@amd.com" <thomas.lendacky@amd.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, 
	"Huang, Ying" <ying.huang@intel.com>, "bhelgaas@google.com" <bhelgaas@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190125191508.FhcTWHBgyRreKfuSWaoubd_-HxygPDFY8SSDFElQFp8@z>

On Fri, Jan 25, 2019 at 11:10 AM Jane Chu <jane.chu@oracle.com> wrote:
>
>
> On 1/25/2019 10:20 AM, Verma, Vishal L wrote:
> >
> > On Fri, 2019-01-25 at 09:18 -0800, Dan Williams wrote:
> >> On Fri, Jan 25, 2019 at 12:20 AM Du, Fan <fan.du@intel.com> wrote:
> >>> Dan
> >>>
> >>> Thanks for the insights!
> >>>
> >>> Can I say, the UCE is delivered from h/w to OS in a single way in
> >>> case of machine
> >>> check, only PMEM/DAX stuff filter out UC address and managed in its
> >>> own way by
> >>> badblocks, if PMEM/DAX doesn't do so, then common RAS workflow will
> >>> kick in,
> >>> right?
> >>
> >> The common RAS workflow always kicks in, it's just the page state
> >> presented by a DAX mapping needs distinct handling. Once it is
> >> hot-plugged it no longer needs to be treated differently than "System
> >> RAM".
> >>
> >>> And how about when ARS is involved but no machine check fired for
> >>> the function
> >>> of this patchset?
> >>
> >> The hotplug effectively disconnects this address range from the ARS
> >> results. They will still be reported in the libnvdimm "region" level
> >> badblocks instance, but there's no safe / coordinated way to go clear
> >> those errors without additional kernel enabling. There is no "clear
> >> error" semantic for "System RAM".
> >>
> > Perhaps as future enabling, the kernel can go perform "clear error" for
> > offlined pages, and make them usable again. But I'm not sure how
> > prepared mm is to re-accept pages previously offlined.
> >
>
> Offlining a DRAM backed page due to an UC makes sense because
>   a. the physical DRAM cell might still have an error
>   b. power cycle, scrubing could potentially 'repair' the DRAM cell,
> making the page usable again.
>
> But for a PMEM backed page, neither is true. If a poison bit is set in
> a page, that indicates the underlying hardware has completed the repair
> work, all that's left is for software to recover.  Secondly, because
> poison is persistent, unless software explicitly clear the bit,
> the page is permanently unusable.

Not permanently... system-owner always has the option to use the
device-DAX and ARS mechanisms to clear errors at the next boot.
There's just no kernel enabling to do that automatically as a part of
this patch set.

However, we should consider this along with the userspace enabling to
control which device-dax instances are set aside for hotplug. It would
make sense to have a "clear errors before hotplug" configuration
option.

