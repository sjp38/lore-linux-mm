Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07B87C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 15:34:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C629C2064A
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 15:34:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C629C2064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 66DAF8E0005; Thu,  7 Mar 2019 10:34:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F7848E0002; Thu,  7 Mar 2019 10:34:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4989F8E0005; Thu,  7 Mar 2019 10:34:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5E08D8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 10:34:49 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id 207so13414477qkf.9
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 07:34:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to;
        bh=Wsfg0ok9ugLJ683R6tW39HiYXOlqVaFSZwOTghjsqWI=;
        b=EdDu3rGwYqKwrXsGOrfv/hxIZk2GnrPK9i4thOJS7maIXb3xGonEL4XpTxb9wlUH3s
         MYTHLkaf9a5ZHDbJqkk+b+e0W+Dvv8xJFmodKqf55mq6l/5NGTsW7y70XYIOV5NkBGIZ
         1iGsDB/jXzylnKbgAjiqUt3FaJH59dnzfVIz+cnduss3l6tBI51lNwcK40p0Rk8o/7rs
         9QixJJQEG6e9HWpeGEErxbD/ebnGmbFtJhIb4F/dBZA/ovblE7m7nYjQBSOGjLCYGz+M
         rtneSFLzjdemNNHVPl/lPoldy4k9mYcAkeFRZniDVmnEnocG4B9nlYpIPGVBLah7WJOj
         TUMw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXp00vI5dveql3+99KW3Gb0VOqY2w3upaGxG9XXghY2YWjzdNMk
	jCeUFkxZ+A2olGpEAEfG+3fqcU+QQEos7clK2nosOztKV8Ouf3+91JIMg/RGnXlWPpwXUMttEan
	mKPgN4UrHD6Hp5aiq9JDpE1rhlERLrnLa5OuI8NLO5PxyJnuP5WD2CusmgWJEY1w+Npmw3ARAAV
	rJ1lRyyNf03kOtjlKrXgR2AGCQ48Ww+hL8Fyc1NN/c++AI6kAaP6wZ5qYtixBPHRRCpVfDDGqpM
	QVS6Ix4b3Yv+Z0OBs9bjTSvmo4iqmdPQQdkdtaaKyynOrbJhHIIrUbCsrOj9WD/3d5b9S+p7nfA
	pd4gIFC5YUrwjFbgVgzvkq13g9cEpZpKF/c7RCeKYnghHIVOUO/CTnteA0Ha2tZiZ+JgjIY3rfu
	N
X-Received: by 2002:a37:83c6:: with SMTP id f189mr10118897qkd.196.1551972889106;
        Thu, 07 Mar 2019 07:34:49 -0800 (PST)
X-Received: by 2002:a37:83c6:: with SMTP id f189mr10118849qkd.196.1551972888403;
        Thu, 07 Mar 2019 07:34:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551972888; cv=none;
        d=google.com; s=arc-20160816;
        b=A1qcMJuKQDD2A1b5lTOhMxbYRfN9tKGNNW+MI/zthzmpmF6Q5X0x965kf7r51Ekhsn
         coN/clwhhDxGGzF9KK28nyEDwTzH1GtHHHIizio8926akqzMrp1Bz9L8Yem5wYHF0rXb
         6F/OFKtTCr93kKjtyVLlcZLMY4MgXCLSRkV0GYJOFBQe4Kuf2lBf1I8iKyPJE7t67y9T
         5w15V7XDHrZs8Z1t7GowCwlLIVB4TCMLLBJevdFE7wZlyedwmUmJcZjXQsiVLYLx4WNj
         8B+O3FaxwGXzpnurw7n6kWM534lpp6mSz8yRMoMM85NcrWMLrRktwSQjzz8XXb+39L/S
         984w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date;
        bh=Wsfg0ok9ugLJ683R6tW39HiYXOlqVaFSZwOTghjsqWI=;
        b=ax1MBotQTCpiZb6plR0njWM/nZ7ILwhwGq/LBVoBJ1i9e8+SoECnr8ZmDFp6OMZol/
         M14zNurDOTbPDvkaZNWDsc4EvSe7NAr2ePXRyHIRQRSRQxvtgvwIpGI7sXRzHiFK0M+V
         xlcA+qCcY1CSOefhsKJpUVhNwTeFhnhTXrWrEw3q5vwNpUyrrVeySMKVDXZne9Wcptex
         Cp63/kAi8L4fR9Lus7Acd5NTOBm3DC9AOh8UbBnJ6tpaO6hG/7Ddq8aa+cxZBnfa6UJK
         RpIVQd493EX7RFSFl9UdUvGgwIZGpZ/XVvewOLjvSJaFksnaV4DwdZFrBSzSDV9bRWKc
         YiRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 13sor1919610qty.65.2019.03.07.07.34.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Mar 2019 07:34:48 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqz69aAWMZo6tBGadWm6DMo8HXGSmtwBcs9kAOiIp3jiWs4Vy0Z3okP7DZSreWC/fa5WNW5dOA==
X-Received: by 2002:ac8:23aa:: with SMTP id q39mr10380050qtq.82.1551972888059;
        Thu, 07 Mar 2019 07:34:48 -0800 (PST)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id x43sm3517230qtc.10.2019.03.07.07.34.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 07:34:47 -0800 (PST)
Date: Thu, 7 Mar 2019 10:34:39 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	peterx@redhat.com, linux-mm@kvack.org, aarcange@redhat.com
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190307101708-mutt-send-email-mst@kernel.org>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190306092837-mutt-send-email-mst@kernel.org>
 <15105894-4ec1-1ed0-1976-7b68ed9eeeda@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <15105894-4ec1-1ed0-1976-7b68ed9eeeda@redhat.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 07, 2019 at 10:45:57AM +0800, Jason Wang wrote:
> 
> On 2019/3/7 上午12:31, Michael S. Tsirkin wrote:
> > > +static void vhost_set_vmap_dirty(struct vhost_vmap *used)
> > > +{
> > > +	int i;
> > > +
> > > +	for (i = 0; i < used->npages; i++)
> > > +		set_page_dirty_lock(used->pages[i]);
> > This seems to rely on page lock to mark page dirty.
> > 
> > Could it happen that page writeback will check the
> > page, find it clean, and then you mark it dirty and then
> > invalidate callback is called?
> > 
> > 
> 
> Yes. But does this break anything?
> The page is still there, we just remove a
> kernel mapping to it.
> 
> Thanks

Yes it's the same problem as e.g. RDMA:
	we've just marked the page as dirty without having buffers.
	Eventually writeback will find it and filesystem will complain...
	So if the pages are backed by a non-RAM-based filesystem, it’s all just broken.

one can hope that RDMA guys will fix it in some way eventually.
For now, maybe add a flag in e.g. VMA that says that there's no
writeback so it's safe to mark page dirty at any point?





-- 
MST

