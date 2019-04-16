Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BC23DC10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 15:04:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 794C7204FD
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 15:04:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ncO+VPtx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 794C7204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BA606B02B3; Tue, 16 Apr 2019 11:04:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 16A9D6B02B4; Tue, 16 Apr 2019 11:04:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0335F6B02B5; Tue, 16 Apr 2019 11:04:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id D39AA6B02B3
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 11:04:20 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id n71so15919646ybf.3
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 08:04:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=FRqDJ8FNiKgynp9CaFKoUJRyYj8V33CvqZRUIRqf77I=;
        b=tXevzh42PQlHSbJTCBV9vQJnlvXv2/WVNIt0my71aE6s9bsvY0sohy5OfFOwvJKnPD
         Hyus3hQmjh5OGvcj5R1Fv8zHPp9CYh+tLSzpraa1hBqERDW4mkrnmH1R/ZmlyS6X8xB4
         Bg2kR2thf56josxZRS3erzUmMQqnxBGElz9FoC8G6IqZgSnVYVZmN6xOcB5l8khkQTSc
         uVkPhYqESjRMg9mvHB5Mndq+iQe17A+C9yg0u86HGCg4TM7BNUgrpIWFV/UBoqzKfQlZ
         k5qN18RNzJNEXRMrL8Y9nsfrM+d/OM/D9G7r47twmj+uQ6gsvsNTa8hcA8h2hKHGvzp/
         EBXg==
X-Gm-Message-State: APjAAAUoXqgIm0/Lb9daIuDyWOWdua1sc04z2J6CYKZ/5sPJw9GdIt2i
	DM8jABwZ46FZWhOGSjiLDDjL3giQu4tXaFlCf82j2ISC1yPZT/pdguxl+MhQaO4BY1S+i/6OWdW
	utkU9udCRcakc0uF6hkzn43acB8yJc3BTChsYI92PJ/VihWTu+9u9oyWX7hJC5lk=
X-Received: by 2002:a25:c648:: with SMTP id k69mr52999271ybf.67.1555427060494;
        Tue, 16 Apr 2019 08:04:20 -0700 (PDT)
X-Received: by 2002:a25:c648:: with SMTP id k69mr52999194ybf.67.1555427059750;
        Tue, 16 Apr 2019 08:04:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555427059; cv=none;
        d=google.com; s=arc-20160816;
        b=RUupYSuUsKdI8tMS6soDevcp1noZdWem60bi85NH2rTdnZBpWjChXb+yNlxZ6Gl033
         vWZAjekoMF57IPpOKdt+vvQbvjOQIWKYUAO6ib7a+N+ltJ8/C+pyTQMRac/xkKulxFCa
         FAsiOxgH9Cn+ux+dUV8AbhnbqgBjxGatyod6s0iOhraMKOptiuFKIU5uUKQJLhSrdFCt
         G5e+k1uIIm3ovcp9+irYZ5g04L0856Lga5Lgs2cTOfDKxth5GPCqpcGPQf2WI6Ch1vGq
         6+scWQwZnKmzgb5Yaus8fpIlwPEUv9vXFMsY77jaRltUVvk4bUMA9kSXW5Ef+cMlpu2S
         +oUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=FRqDJ8FNiKgynp9CaFKoUJRyYj8V33CvqZRUIRqf77I=;
        b=DSWA9gt3x4FPkEF6s9SQVG+x5XC0a7N01tKEV1yN50O5lgWp79nKK5sScMD9C/7KC1
         XUQc9oPSGjd9EbpL0LR5rz2T7YjY88XtPpqv0VlaLdx/E7LqVnJddgmvMeBJHJRTpNzJ
         9o4kYWNEOl7o2FwoQyU3o9wS2CPFl3NzkTBZ0F2luGStRWGXpEjfi5hy0fCOH4zYwoIa
         Tdickg3PiHO2JVkJRfnoYU1aIqDYlHJ8aD4imi0inHJb6P0JM7ihUdYRjIRtYTN84XE0
         C0JLrQGS/S0GWBgo921WiV9XTrzHXRBi3p9S/jXpo0g5sem+LQBhqZfHY27p7Ri3WRSC
         VQYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ncO+VPtx;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h189sor8572033ywh.127.2019.04.16.08.04.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 08:04:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ncO+VPtx;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=FRqDJ8FNiKgynp9CaFKoUJRyYj8V33CvqZRUIRqf77I=;
        b=ncO+VPtxK5kIGdukbQgE/YQ03dtTLausFKpbLnGrIWUNsMtFliiAQTs69Y7wZwloso
         UYJ1O0XXuUYxD5UlHaEPwZH5bI5qWDCVknQwEnjwIx0JnauOQTG5lSTolyDSEzXEWCBE
         lIUxGFPTsPXyqduDdBiJbE27m3NpJ9tQZNmVpQHvFKBCsgdoVwju5EtL80crUsxgwmFR
         6syqxPSFBgN7dcnJ1vlkUgzCxVllqtGxSJY1RWuyvN+3+6wryR41mgmsd5+waTANkPpk
         2RAZ4lC0uc/MEf7s/88H1tCP9HhWBxo66VBnhIIieUGRSMozGvkqRf3L6V4aB0pHImPU
         jQJQ==
X-Google-Smtp-Source: APXvYqwXwf9G6/bs3nUU5gStz7nmbBMkjNo0zrZjOg7pIlc2YfpGOkiTsVkB31hoOPXM0XzEM0FeKw==
X-Received: by 2002:a81:7a0b:: with SMTP id v11mr65084752ywc.127.1555427058547;
        Tue, 16 Apr 2019 08:04:18 -0700 (PDT)
Received: from localhost ([2620:10d:c091:200::c7e0])
        by smtp.gmail.com with ESMTPSA id 205sm16592872ywp.104.2019.04.16.08.04.17
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 08:04:17 -0700 (PDT)
Date: Tue, 16 Apr 2019 08:04:15 -0700
From: Tejun Heo <tj@kernel.org>
To: Jiufei Xue <jiufei.xue@linux.alibaba.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
	joseph.qi@linux.alibaba.com
Subject: Re: [PATCH v2] fs/fs-writeback: wait isw_nr_in_flight to be zero
 when umount
Message-ID: <20190416150415.GB374014@devbig004.ftw2.facebook.com>
References: <20190416120902.18616-1-jiufei.xue@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190416120902.18616-1-jiufei.xue@linux.alibaba.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello, Jiufei.

On Tue, Apr 16, 2019 at 08:09:02PM +0800, Jiufei Xue wrote:
> synchronize_rcu() didn't wait for call_rcu() callbacks, so inode wb
> switch may not go to the workqueue after synchronize_rcu(). Thus
> previous scheduled switches was not finished even flushing the
> workqueue, which will cause a NULL pointer dereferenced followed below.

Isn't all that's needed replacing the synchronize_rcu() call with a
rcu_barrier() call?

Thanks.

-- 
tejun

