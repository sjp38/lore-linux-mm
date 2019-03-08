Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B54DCC10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 03:41:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7164420840
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 03:41:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7164420840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30AED8E0003; Thu,  7 Mar 2019 22:41:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B8E78E0002; Thu,  7 Mar 2019 22:41:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1820D8E0003; Thu,  7 Mar 2019 22:41:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE8AE8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 22:41:02 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id p40so17302509qtb.10
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 19:41:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=3Mt6xJjFhDSCxqYQUHLE6KVLLfYkY/OqtRZyIsdVU9Q=;
        b=QrL6HPR7MdLMH87/z74L3zdEl9JpteY2VLw7ke6ke48fbHOfZGmPDf1Q1OO7yG65I/
         9g0c6V0/DJk9WbpV5xr1nRH1PpW8ypg2AV6F4LhOs6Il6JBysioaik+/dL+SvdQRbNer
         0AWZbNsr6NXXpgrwyG2+9NLHrlBLOkc2rK9W7IOlG7fpK9y8Q75bVpIkfoNXSOtgVyAo
         WJcZhrmmK1pyxULXNyQ9sG/AbS+12+aKKI2j14iBJ4YeToHILBt9kcIiARA6ThdSUHsC
         VctyVBR4uJYoDiT41T4kVccDuTYcItKISLiIhpp2ZnHxgHS0PBQCfRFgcd3jx+y52Tal
         2gzQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW9lbftzB9ZrHQf1ZNl3RDxmRhGMlq346ksgUcxXZHezXuZ+d2Q
	qgxXsSsrMWV3ah/Cf7aWz0eQb2X9mTObV5lOGJuRuxtdDz1ckuQI5dSPOPK+16knUfKHa79yT/7
	KCzPE9sklohRR6NF8yu1j73YPVRAITUxt0X3By4ACdY4qQT4PD2jHDCZ7piTbrW/yXw==
X-Received: by 2002:aed:2515:: with SMTP id v21mr12983706qtc.191.1552016462638;
        Thu, 07 Mar 2019 19:41:02 -0800 (PST)
X-Google-Smtp-Source: APXvYqwOll3AbnmNJ/WEOUFbtYSI3FES0kuJkaSsGFrkcuYyaKtoETFqu/PeeGmLKXEMEyXek3+o
X-Received: by 2002:aed:2515:: with SMTP id v21mr12983677qtc.191.1552016461891;
        Thu, 07 Mar 2019 19:41:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552016461; cv=none;
        d=google.com; s=arc-20160816;
        b=VaoIoEJHXA+jWxlZJ0cxqeCJRcM7sGXy2MDhiAqJpQVRF6ONjtXgm0v/EslZ12+NmK
         ssrO2C6rB01SjIq1sMQ43Uz60hpflbXcyZEzEydHT0t/8LclGEc6/lLFi4Juszrji791
         MZHYlusAlN4o1i5KY/eb2FoFvITOG67trZNYuzW8xfX+AU6snwsbfnrnpZgrvg1le6CM
         hYC6M2y+3EAjmqohcr4iBS79HPGcY91naYicgEYZRDooR7505ldiVkbeaUKY1QwXLGak
         I4deFyO6SG049XlDSU4i4D8buoQskLihJl/l5IU6V1T29JylyzN1Hmi5pktBl/jd3tsq
         RBIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=3Mt6xJjFhDSCxqYQUHLE6KVLLfYkY/OqtRZyIsdVU9Q=;
        b=gHqnJNsI5jsuxs5H/6jG+YrM/V5vsBl5eu7q3PY3zBzORHAADB3JqzDGPNOiR/JMKV
         hr9Oqu0s3ZC5CCNEmY4k5qwu/Ytm6rvkODX01RoiThwcs+ivveKzRvfJOMlkDMzYhLNj
         sU7or9h22Nb22hH4inA6REzhmJxyDOWTKCDcDSJsI1MQgjXxcWwmea33dNhIES+7RJeI
         eHnRFNl0woiVOqRKiScFFJkfI1tMrRR+VMgzCBenKdpn2zhzPANt6f5AVUnVv7s6hRSe
         DSpZdkS8uVMIwPAzQtg2Ew4ORGUjsnEJCoVsRWESixL1CZD+wqEjlVyjbgFP0PAGDV+x
         LEHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w9si816419qki.247.2019.03.07.19.41.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 19:41:01 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E21753C2CF7;
	Fri,  8 Mar 2019 03:41:00 +0000 (UTC)
Received: from redhat.com (ovpn-125-54.rdu2.redhat.com [10.10.125.54])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C72AB1001DC1;
	Fri,  8 Mar 2019 03:40:55 +0000 (UTC)
Date: Thu, 7 Mar 2019 22:40:53 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
	aarcange@redhat.com
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190308034053.GB5562@redhat.com>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190307103503-mutt-send-email-mst@kernel.org>
 <20190307124700-mutt-send-email-mst@kernel.org>
 <20190307191720.GF3835@redhat.com>
 <20190307211506-mutt-send-email-mst@kernel.org>
 <20190308025539.GA5562@redhat.com>
 <20190307221549-mutt-send-email-mst@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190307221549-mutt-send-email-mst@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Fri, 08 Mar 2019 03:41:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 10:16:00PM -0500, Michael S. Tsirkin wrote:
> On Thu, Mar 07, 2019 at 09:55:39PM -0500, Jerome Glisse wrote:
> > On Thu, Mar 07, 2019 at 09:21:03PM -0500, Michael S. Tsirkin wrote:
> > > On Thu, Mar 07, 2019 at 02:17:20PM -0500, Jerome Glisse wrote:
> > > > > It's because of all these issues that I preferred just accessing
> > > > > userspace memory and handling faults. Unfortunately there does not
> > > > > appear to exist an API that whitelists a specific driver along the lines
> > > > > of "I checked this code for speculative info leaks, don't add barriers
> > > > > on data path please".
> > > > 
> > > > Maybe it would be better to explore adding such helper then remapping
> > > > page into kernel address space ?
> > > 
> > > I explored it a bit (see e.g. thread around: "__get_user slower than
> > > get_user") and I can tell you it's not trivial given the issue is around
> > > security.  So in practice it does not seem fair to keep a significant
> > > optimization out of kernel because *maybe* we can do it differently even
> > > better :)
> > 
> > Maybe a slightly different approach between this patchset and other
> > copy user API would work here. What you want really is something like
> > a temporary mlock on a range of memory so that it is safe for the
> > kernel to access range of userspace virtual address ie page are
> > present and with proper permission hence there can be no page fault
> > while you are accessing thing from kernel context.
> > 
> > So you can have like a range structure and mmu notifier. When you
> > lock the range you block mmu notifier to allow your code to work on
> > the userspace VA safely. Once you are done you unlock and let the
> > mmu notifier go on. It is pretty much exactly this patchset except
> > that you remove all the kernel vmap code. A nice thing about that
> > is that you do not need to worry about calling set page dirty it
> > will already be handle by the userspace VA pte. It also use less
> > memory than when you have kernel vmap.
> > 
> > This idea might be defeated by security feature where the kernel is
> > running in its own address space without the userspace address
> > space present.
> 
> Like smap?

Yes like smap but also other newer changes, with similar effect, since
the spectre drama.

Cheers,
Jérôme

