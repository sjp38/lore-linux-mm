Return-Path: <SRS0=pjJT=VR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF330C76195
	for <linux-mm@archiver.kernel.org>; Sat, 20 Jul 2019 17:36:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89DC5217F5
	for <linux-mm@archiver.kernel.org>; Sat, 20 Jul 2019 17:36:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UPapH70G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89DC5217F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A88C6B0007; Sat, 20 Jul 2019 13:36:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 158316B0008; Sat, 20 Jul 2019 13:36:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 06EA18E0001; Sat, 20 Jul 2019 13:36:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C8F556B0007
	for <linux-mm@kvack.org>; Sat, 20 Jul 2019 13:36:23 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 6so20744484pfi.6
        for <linux-mm@kvack.org>; Sat, 20 Jul 2019 10:36:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=/jFzEFbXL8zNeFrvM9gtQJVw7kMPeTM3qxkr4uBXj7g=;
        b=YvxrePIL2ayxb22++M0gnlq+LSNiQz9RSsLQBpG8L42O0xBe0cRZDlZuHz75w3xiYe
         N0NUOvHt2KMKclI2YQ+cwhyg0VN/Pe/ASjF4eBguMYpTyZKiYoaUyyWmoMAd89J/0Sjn
         yHD3cb8/+d/MR6HQOw0mgs6Q739V2HfewRtGgJ1ScbEOO+a8txRDAgv83JDT8o8PhP8a
         E0twWAIw3N9DF5SjS7KtvDEiBpNSosChkyX4qerulNCqCV7X+xzP8g/YWvITRShnaPuL
         WHK22VqsQouhuDFfWnNPr0xBHXRhbZjK616L5vn6Z6lvjMS7Vv4YtKHQKP1dF6pAa67u
         oogg==
X-Gm-Message-State: APjAAAXrq9REwZ4cNUxHB5KUpiGEr1CJwP0JNauSnEBONCz7bfWyc7mj
	dNY9PHQF8pOGIeqNuTmK3ceOVZIJL4BXMmLai9qMJ9gLVBzOSiVMvVWj2mtUha+NK4cgSnnTQgf
	E7KxdlKM/v45/mEvpNiw2Ow5NnZUvBQ+7L8dLV0KZ00J86ppAx7PSCBoTjabAB35vyA==
X-Received: by 2002:a17:90a:2163:: with SMTP id a90mr62149489pje.3.1563644183419;
        Sat, 20 Jul 2019 10:36:23 -0700 (PDT)
X-Received: by 2002:a17:90a:2163:: with SMTP id a90mr62149438pje.3.1563644182564;
        Sat, 20 Jul 2019 10:36:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563644182; cv=none;
        d=google.com; s=arc-20160816;
        b=u/4QYuMx5o5xHlQis0721odC2woxr+TR1O5JXNBMlfTKTAPZWLpuv04ilxBnGTeKCc
         ixt0EfSa1hDZV++NoyzHY6gXB8BMrpn3+Kbp1QZgQdHt5ZjQvVCWy19T6JGsYu8d1X1Y
         FRlmfmNYAb5VGvLP6aPim9lZtaXImJX1P3mdUqmNI7Q2WLrsaS0V7pZb+E7CgGhRWWXC
         xmPuOWxvJab1zdgyHMEhq4zfVO1sPX0uU7n9U2/RI7my+nvZAUQJkgQBP6EQJ+G2z2wu
         wQqYWoysAIOmqL8eAFxi7XRe22jAtocuFBaJnK0fcNrCW//EKLmEQTyCltnsV8p5JCTU
         5b2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=/jFzEFbXL8zNeFrvM9gtQJVw7kMPeTM3qxkr4uBXj7g=;
        b=z2O/ofEW+pstoUpPx5DafRUKjaCFFcwUsbVQFZuh+D+2e+RoK0KBvWZhhOvz4IqG5h
         uFn/ghIrbKPuHYhC2Ay0BH8OD91XaLlyjutczioM8HLHkZyw3GqLuTchWuaaRKqE2Hrl
         r3n/nBQFPYjQMhCanlY+2aS8xn77gnZ1RmRQgW7Fl1/BsThQvX8Mk+Xx/5pdu23tdSyn
         geeKQaqdJGNr+XE6e1nMRAT5o+8P+m9Zbcarcjdv652RfZJ/Qxf06gm1mItReTxEptVW
         GTq5u4GmoHDS2W2iLTDqxQ+8+r39ZcGzQcbgLHAZ4QflfitH6TtQ+eax2Xk6CnhtpuUi
         WLeA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UPapH70G;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f10sor18077443pgg.6.2019.07.20.10.36.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Jul 2019 10:36:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=UPapH70G;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=/jFzEFbXL8zNeFrvM9gtQJVw7kMPeTM3qxkr4uBXj7g=;
        b=UPapH70G8Pzu1pg1x2Iha2h7FKvzz82Nv9TupdtGdQWcSvvtDW6XgGpOhzb6+WWvvO
         UyfByHF80wwI3MBKlBxATaAcS70wQ/N/BvPtoBw6juTuTyuJklnyo6YO+oOVveKIzcTK
         tQdXFARugh8oJMlOzbMXXFpzPXLBElc+7dUjTIB2RKUCS+Rkr/k0HEdNeFEbvAGuUUra
         0gGFoYoIOnBF5r+ljjENAr3kJLaZWURQ28WEyUwNl6P5dnd8GjgifxRLfQNjGT4ki4G5
         QCOIQlE+j15jXUoY3hw4bBKyO7hThGIdgKO4yOIaFXqV+h+G338QIjXtWmzL1ngNUWpn
         X2/w==
X-Google-Smtp-Source: APXvYqxNNZGDJ1Z3eY/IfJfUVpvisSu3W4uOc+tNJWgFyRdKEailjCJybjrD7z7wlYqd/BifdGEweQ==
X-Received: by 2002:a63:d944:: with SMTP id e4mr60439916pgj.261.1563644182185;
        Sat, 20 Jul 2019 10:36:22 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.33])
        by smtp.gmail.com with ESMTPSA id f197sm34302222pfa.161.2019.07.20.10.36.18
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 20 Jul 2019 10:36:21 -0700 (PDT)
Date: Sat, 20 Jul 2019 23:06:15 +0530
From: Bharath Vedartham <linux.bhar@gmail.com>
To: Matt Sickler <Matt.Sickler@daktronics.com>
Cc: "jhubbard@nvidia.com" <jhubbard@nvidia.com>,
	"ira.weiny@intel.com" <ira.weiny@intel.com>,
	"jglisse@redhat.com" <jglisse@redhat.com>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>
Subject: Re: [PATCH v3] staging: kpc2000: Convert put_page to put_user_page*()
Message-ID: <20190720173615.GA4323@bharath12345-Inspiron-5559>
References: <20190719200235.GA16122@bharath12345-Inspiron-5559>
 <SN6PR02MB4016754FE1BB6200746281A2EECB0@SN6PR02MB4016.namprd02.prod.outlook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <SN6PR02MB4016754FE1BB6200746281A2EECB0@SN6PR02MB4016.namprd02.prod.outlook.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 19, 2019 at 08:59:02PM +0000, Matt Sickler wrote:
> >From: Bharath Vedartham <linux.bhar@gmail.com>
> >Changes since v2
> >        - Added back PageResevered check as suggested by John Hubbard.
> >
> >The PageReserved check needs a closer look and is not worth messing
> >around with for now.
> >
> >Matt, Could you give any suggestions for testing this patch?
> 
> Myself or someone else from Daktronics would have to do the testing since the
> hardware isn't really commercially available.  I've been toying with the idea
> of asking for a volunteer from the mailing list to help me out with this - I'd
> send them some hardware and they'd do all the development and testing. :)
> I still have to run that idea by Management though.
> 
> >If in-case, you are willing to pick this up to test. Could you
> >apply this patch to this tree and test it with your devices?
> 
> I've been meaning to get to testing the changes to the drivers since upstreaming
> them, but I've been swamped with other development.  I'm keeping an eye on the
> mailing lists, so I'm at least aware of what is coming down the pipe.
> I'm not too worried about this specific change, even though I don't really know
> if the reserved check and the dirtying are even necessary.
> It sounded like John's suggestion was to not do the PageReserved() check and just
> use put_user_pges_dirty() all the time.  John, is that incorrect?
The change is fairly trivial in the upstream kernel. It requires no
testing in the upstream kernel. It would be great if you could test it
on John's git tree with the implemented gup tracking subsystem and check
if gup tracking is working alright with your dma driver. I think this
patch will easily apply to John's git tree.

Thanks!
Bharath

