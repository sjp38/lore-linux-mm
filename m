Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58450C00319
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 15:42:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC4E520684
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 15:42:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="VLKuPs0p"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC4E520684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6699E8E0003; Tue,  5 Mar 2019 10:42:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6191B8E0001; Tue,  5 Mar 2019 10:42:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E1A68E0003; Tue,  5 Mar 2019 10:42:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2992B8E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 10:42:41 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id y129so13430724ywd.1
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 07:42:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=qDZBdwaChAn3RB4d4hTLVwKEXk+hZzC42CiJSaOc/m4=;
        b=qcjaSYDvIWRPu1PgIeIbnn6V3McZeZ4gVqhlwhWQxMryZCv3sdD5aIbXzk8bLkHz3E
         PGHsX1Rg9p3krHfDwTpV2gooTwMFryO+PhWu6cztms7eHsgqFgJQe3sVU0RPXdFMRCOl
         C+L0DlWNqIhLtnPdB4xPJEna7ie+fA37/VTDIiMKr9Mr4CBfSdVqUagq0VtHjIl7+qeF
         KfRKVuQ8xZCXru/m52SbbJIb1Tkk31V9bWpNAXvXFHR+PMfNYmTLfhK0h+a3X2h7Qj/F
         uYAd8vxL3KjJseIPFX71LdUlPVIqDTEzoWdAoWOanx+X2R6m8YtuI5F4C9MOmzz8/IJy
         oiAQ==
X-Gm-Message-State: APjAAAVe/7Zer3sAACmZwDb5yWFAd260ya9F7OGAJd1dU/ErFtPZcEbg
	WYRkbopfsWE5qQu4U1qIs7jKt4c8763kB5XEeKv2fOtbudVBI/64tLeGLN+PXCn5KJss2CcTHDp
	9Byu+3u2hTpWund0mpOAbtgXhm2EjDk+Q50cwK5vzsC24foLJpHDwBl7Z13OWNt97FWz67Mo36t
	kWFAkaY+UYemifWQaOp4HcMAGLOzY6ZA7K6DsLzvpDgz9XlFadoxU2Q8MQ8wgFuLkoBAQkBD9LV
	Cdxz50xE5LY+/LjbPvVwnce7oUMyBApPo5r/oWQhrtFl11pB/mP5XUyaVVAjKQx6wtF6lgsyEvU
	i76lagfIUlle0SxWzocbeqE/s0+VuWcGNKAhqdGKpsfPh7Ep4UhthKmtbYmwHHtMy7r/O88TMg=
	=
X-Received: by 2002:a25:cd44:: with SMTP id d65mr2734489ybf.144.1551800560777;
        Tue, 05 Mar 2019 07:42:40 -0800 (PST)
X-Received: by 2002:a25:cd44:: with SMTP id d65mr2734445ybf.144.1551800560128;
        Tue, 05 Mar 2019 07:42:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551800560; cv=none;
        d=google.com; s=arc-20160816;
        b=VRjgSRSQr37Lu2is5J26RYonhsHVnmZ48jjuxdwhaQs6WTkhjABVm33AmnMdAY1aVs
         jXf+jceYeBmUvM6alkpyfBC/XSzaCssbsrMBHu9lGEjdq85iOvOzpUWvwGWwjRs9wK65
         wd6akttXcgVd5GA05oVtyLnwvzzFXvu5ODHJfrmBYpqPe25RFzNOzM8TUQ/gCwK3+Z4q
         HSdCfHvig8KHLs+HnpHZrO3X2aKsBWqPQrtz7G/nbLRZzAMt1abzRr96oyyB2+IdD3d7
         5cDum4jWEFSZdnkdRjlxvUl4OamO6qBtoUKoJRy/HJsV+tLMj3f7YcgBMyXHgh6edqqi
         Xpew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=qDZBdwaChAn3RB4d4hTLVwKEXk+hZzC42CiJSaOc/m4=;
        b=lNRRbCZt4zDeZzcuQDAO8R3AfgselD/Pi5t3GhoUp1iKddQyixOgfNH843SCen0DVn
         liVAlw3AAy7WG7YYBQBRq4e+swLO5hABRTbt4RoC5ydLNtaxARp/kCZyuZj9Hz8jo8kE
         62reh1uEAaVZ9AA1UDrNZZ6TFwYj4QDA+NYVGDuBa92c6t+B9utkCdnX+NJawqVpC2qt
         bmOWrpmvR5FWlGIGBkGntmkiLMESK/sfhuKD5OEPiC0Z/GmWKVB2wO6CqVGRs75iO59A
         PxCZh8v1qd/PwxpipnB4I5XQvvimDwIGlc8V2O9tnmyL/hmhqFA0VREABHzh2r0mV35r
         kOKA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VLKuPs0p;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d10sor1274418ywd.144.2019.03.05.07.42.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Mar 2019 07:42:40 -0800 (PST)
Received-SPF: pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=VLKuPs0p;
       spf=pass (google.com: domain of htejun@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=htejun@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=qDZBdwaChAn3RB4d4hTLVwKEXk+hZzC42CiJSaOc/m4=;
        b=VLKuPs0pH66G9o/zzWqDne/ydkzGw4Y4U2C8XPRudhsFYKkuwLTMmUPxJrgMoeWEpr
         5JUgb+nAlHyLiVeCOvtvIoo5f1ewVnEIBvZb7RtriNmDjQA6qs77+n4nH7tez9CwvwoY
         Ngt01nMu48VrqEF5KWIaE6n6H2j+Nqrvq7OecBsRqeKoJlL9TYL7K73zTnu2CehsZQmU
         r4zN6+A+XAHWMo+jmedArLy1S3m5tWSk2pi//kNWvP9qyS8FXmzX9Bq96ezJROFjpUgd
         GtIS6HeA2stG6E0ObNVfB/1eHqPgV7eZoaw3XA4tECnCDdd1LNa7Ps0+/iRYUq1FZSlV
         muNg==
X-Google-Smtp-Source: APXvYqwUDppjzSfUVBMV4g4BO4GtTbeuOk/twDUtBSn5yr6ghJxzd6Ms2nzNzyirEfZxMMfClcTqlA==
X-Received: by 2002:a81:84d4:: with SMTP id u203mr1456335ywf.363.1551800559664;
        Tue, 05 Mar 2019 07:42:39 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::1676])
        by smtp.gmail.com with ESMTPSA id d85sm4604058ywd.96.2019.03.05.07.42.38
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 07:42:38 -0800 (PST)
Date: Tue, 5 Mar 2019 07:42:36 -0800
From: Tejun Heo <tj@kernel.org>
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] writeback: fix inode cgroup switching comment
Message-ID: <20190305154236.GA50184@devbig004.ftw2.facebook.com>
References: <20190305004617.142590-1-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190305004617.142590-1-gthelen@google.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 04, 2019 at 04:46:17PM -0800, Greg Thelen wrote:
> Commit 682aa8e1a6a1 ("writeback: implement unlocked_inode_to_wb
> transaction and use it for stat updates") refers to
> inode_switch_wb_work_fn() which never got merged.  Switch the comments
> to inode_switch_wbs_work_fn().
> 
> Fixes: 682aa8e1a6a1 ("writeback: implement unlocked_inode_to_wb transaction and use it for stat updates")
> Signed-off-by: Greg Thelen <gthelen@google.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

