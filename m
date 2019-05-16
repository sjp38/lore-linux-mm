Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4965EC04AB4
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 21:51:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F07672070D
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 21:51:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="JK0kNXwo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F07672070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6DCF76B0005; Thu, 16 May 2019 17:51:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 68D166B0006; Thu, 16 May 2019 17:51:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 555026B0007; Thu, 16 May 2019 17:51:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5FC6B0005
	for <linux-mm@kvack.org>; Thu, 16 May 2019 17:51:54 -0400 (EDT)
Received: by mail-oi1-f199.google.com with SMTP id x193so2063074oix.1
        for <linux-mm@kvack.org>; Thu, 16 May 2019 14:51:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Q9BJIUmtXvGA8NYL+nEThmnX3fsQkDEf9gjJHVtWFbw=;
        b=r5stRJ/TENUIOykiyM07PLKbo1ZTqIPBjvD6A2ToO4+DA+9gR3TSrsL9Rb55e+ar0L
         Uw4G5xZ1Reof+nfOU1GJyOOQVWbd7UTEJiBAK92xKCyG8qv13ExUnuF1v1aZ7fJelgM0
         bPPSmKn3D0KJKNdkwMIFJ660/cHqMSrgtGxFRyPvnapfQcE2mhHD7PkYrzqXLY2V+K07
         OVEN0jHuMTdgPl1Fy/BgvuWahdfrDvh/mbmKMM1VOu5z8hk8DKrVsWVW8d/v/m7NALcO
         4gFY4BBso2JnuajY/MrAFndRgwazkk2Xfd67d/qjl0bQbQRSwM3eQP2oasQhi7r7HYnQ
         q1Nw==
X-Gm-Message-State: APjAAAWkMToi5ktWa4MqEQCuhiz1B//PLP+j1rQE50TbXmKfof0+0vl4
	aqvQR3PqAplgLfDBADd2+nZxm360bIY8jAJe15TVyxfjEJyW/H7+L2gpqc2jvuUhIuQbNspRav2
	r+5z1SOKT7cKwhTis48C/6EYlvLqEbBm5hBxyJ/h8EmOGucS7JJJbIj5Gwi/JdblAbA==
X-Received: by 2002:a9d:4e4:: with SMTP id 91mr29919082otm.62.1558043513788;
        Thu, 16 May 2019 14:51:53 -0700 (PDT)
X-Received: by 2002:a9d:4e4:: with SMTP id 91mr29919051otm.62.1558043512697;
        Thu, 16 May 2019 14:51:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558043512; cv=none;
        d=google.com; s=arc-20160816;
        b=Tx86y5REZkok3EyeoLcCFIBFEjhFeXKuFbASYhh8R9tCx/XJfUVRe7h2+soMlfcpP4
         z5nvpqKrYKmHR2W99Kxzk6Nvw5iVp/VmeM99YRVt306Q10UFpBh9IzIkwslVRqTyoOTy
         BvzjTwiuC4Itkdg6mDfNC1OQi7vOc0JP1A5TkbSXw69pVxDnr5QY3W7cp7B7d0JwYCyu
         5Kepqp+s2EmWCNLUoTkO7R+5UmZN8t0hgEang2QSCiAjymr9nsRLjVd77Fy34J+bhpfp
         PFL/9kth9np4UgW6M6ONXq9WdWmyLbOXtn64SaEVEaepG8rSfIblypDktF9egiO1tDMu
         2diQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Q9BJIUmtXvGA8NYL+nEThmnX3fsQkDEf9gjJHVtWFbw=;
        b=iG9ilXH1P7f1Dtsr/sp0oZD+yeakA5hQWooFWIgH5G8RU0ICcFW4OGLzoKGfMx3JwZ
         Ln5zcMDahgAsH8eXrDOEka0i/GbtgXMbJwpSrb2iwlRi8z/d0i3rJ9wVC3pOjkRVTe1F
         0Ck/pYbG6IKuypvBRVye9JR+Izj0r0p3jyTLZCB/wN7xA8P159yWiFgNQmMsbtmV9Vtc
         h31UeNdLhxhuo/iFhCZBGSaNYxQce2PoR/XGVVpTElL60Z9S3z2xjWLUUgBVlVWG/OZ3
         ltWhqTzsj3yshtGgID10zmmZRVTHYXbznj+Ytd7ftuqQ2C7nZC1IPkB8WyNYIKdTGxD7
         cglA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=JK0kNXwo;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e72sor3269272ote.95.2019.05.16.14.51.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 14:51:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=JK0kNXwo;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Q9BJIUmtXvGA8NYL+nEThmnX3fsQkDEf9gjJHVtWFbw=;
        b=JK0kNXwowOzM74+Om7kEhXLK+rOIMCMEPEAa6Fk0D93qKu8M2dq0YJm2ZfDxgTeCiU
         ZnpolSVQFmjdgAGuHgNPUQKcuPGJMBEDpFs5OvgWHO2/r1lUKUoq+r79dmC3nusASLwW
         b7J6BtVgy9HYQwcAKkLHQsoshwVUNWjVqol42iFhSJKjgsIi6Dc+SwbzWrocF4PuQV9M
         IYPIajeB7RxjAFAl9a4GWlG5H5AeA23IEp+6x25xZR+whf8n/MJa5cQu6cdcsWrU1TDn
         /Arr+Bi1p3leIaZVgocYnoMbwVUjOA/IIrN5CFkLQKwwu660ooYhVCJaHs5KP3OXWCL+
         YIIA==
X-Google-Smtp-Source: APXvYqzibKwOyLJegIvrnmsMGvcFID1N0Mw2/FEB7rFcTHdA1PYSfF3HR1ZbWMzElybqvVBCcqSrRsrG3NhAGtjgYjo=
X-Received: by 2002:a9d:2f0:: with SMTP id 103mr30133978otl.126.1558043512432;
 Thu, 16 May 2019 14:51:52 -0700 (PDT)
MIME-Version: 1.0
References: <155727335978.292046.12068191395005445711.stgit@dwillia2-desk3.amr.corp.intel.com>
 <059859ca-3cc8-e3ff-f797-1b386931c41e@deltatee.com> <17ada515-f488-d153-90ef-7a5cc5fefb0f@deltatee.com>
 <8a7cfa6b-6312-e8e5-9314-954496d2f6ce@oracle.com> <CAPcyv4i28tQMVrscQo31cfu1ZcMAb74iMkKYhu9iO_BjJvp+9A@mail.gmail.com>
 <6bd8319d-3b73-bb1e-5f41-94c580ba271b@oracle.com> <d699e312-0e88-30c7-8e50-ff624418d486@oracle.com>
In-Reply-To: <d699e312-0e88-30c7-8e50-ff624418d486@oracle.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 16 May 2019 14:51:40 -0700
Message-ID: <CAPcyv4hujnGHtTwE78gvmEoY3Y6nLsd1AhJfeKMwHrxLvStf9w@mail.gmail.com>
Subject: Re: [PATCH v2 0/6] mm/devm_memremap_pages: Fix page release race
To: Jane Chu <jane.chu@oracle.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J. Wysocki" <rafael@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Bjorn Helgaas <bhelgaas@google.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Christoph Hellwig <hch@lst.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 16, 2019 at 9:45 AM Jane Chu <jane.chu@oracle.com> wrote:
>
> Hi,
>
> I'm able to reproduce the panic below by running two sets of ndctl
> commands that actually serve legitimate purpose in parallel (unlike
> the brute force experiment earlier), each set in a indefinite loop.
> This time it takes about an hour to panic.  But I gather the cause
> is probably the same: I've overlapped ndctl commands on the same
> region.
>
> Could we add a check in nd_ioctl(), such that if there is
> an ongoing ndctl command on a region, subsequent ndctl request
> will fail immediately with something to the effect of EAGAIN?
> The rationale being that kernel should protect itself against
> user mistakes.

We do already have locking in the driver to prevent configuration
collisions. The problem looks to be broken assumptions about running
the device unregistration path in a separate thread outside the lock.
I suspect it may be incorrect assumptions about the userspace
visibility of the device relative to teardown actions. To be clear
this isn't the nd_ioctl() path this is the sysfs path.


> Also, sensing the subject fix is for a different problem, and has been
> verified, I'm happy to see it in upstream, so we have a better
> code base to digger deeper in terms of how the destructive ndctl
> commands interacts to typical mission critical applications, include
> but not limited to rdma.

Right, the crash signature you are seeing looks unrelated to the issue
being address in these patches which is device-teardown racing active
page pins. I'll start the investigation on the crash signature, but
again I don't think it reads on this fix series.

