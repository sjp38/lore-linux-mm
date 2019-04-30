Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06D06C04AA8
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 10:29:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A80E921707
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 10:29:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A80E921707
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE3D06B026F; Tue, 30 Apr 2019 06:29:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E93956B0270; Tue, 30 Apr 2019 06:29:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D82B06B0271; Tue, 30 Apr 2019 06:29:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9EEBF6B026F
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 06:29:43 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id c14so15168420wrv.5
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 03:29:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XdbDnxf84uCdT6qDXfWjCLNehtVPK73rVMJyV4ViNsE=;
        b=jkzohSoRsqeShbeezdpFV4ADB1Fl/flbmNrcCiA4Aal8lMuT/Gxt4j8MS4T2K6w5/J
         wrP/spJRqaEqkJq8AgmxbyGlngB+2oxzZAzZNbib/qlEWGvv05zUvK0B2ss+kQIOFkmL
         4sdyE6RzWOdWl6EXv0YpLaSIRUfhjZLv2eb+zwvfm1TkPECbv3w6qRrnE1xiYVdBVP+N
         ZpjgbhbB3pg6rq3R4WQKjO6l+TlLPvyYiMlfqcV9YG03Dn9/hMkq6rNYh1cbtYRho4NH
         /boxMiP2qaGO/RoHLiMmYU0+qBlwj3qoIcVR+KyXLRXa4fo/Hoa3CSZtFOloTYzW3yOH
         snfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXEyyaUeGOmZqKz2ukQrDF4jYCKOFzDp0FibJHv1SMgxi3oYYnT
	dgNVMfJW2O4Zr446Kpf9MFdBm7h6nMUz8cgC5EeDfyIHKsu888pbzk5MhhX6FiCamT3PRHCCGWM
	IhYBfhvBlmxFhmDKDY8WamnX72XSEPmvRP4P+HFwGTgtSmbcN9lX+TpZpE/CKgKlQEQ==
X-Received: by 2002:a1c:2986:: with SMTP id p128mr2624579wmp.134.1556620183168;
        Tue, 30 Apr 2019 03:29:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwkdW4AzdxTAxde9bQ3EEbvrSr2oo8OsA8ShrfLQZ+UHpxArzQazZ0PEZvOfWae8hyw0XlO
X-Received: by 2002:a1c:2986:: with SMTP id p128mr2624524wmp.134.1556620182182;
        Tue, 30 Apr 2019 03:29:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556620182; cv=none;
        d=google.com; s=arc-20160816;
        b=sbu3i5eUZlHNSVkCgf2MmsU2AovsbouXUllHzKZ43OtugXf3iVlYHyJS9WxF/0JLf4
         LV/1NJIAbYsWVqgKPiOdEQ3HSCcB0ItJvDi8xkyICUCqWxuDuLtXlLpIvlOSM7D748/q
         T8I5epsBnLTlvDqECUmvtuoGFAUqWtvFXeLGBImCsSJSOhNibuWB5UNHDgDXf6fVS3Ah
         hacINLHUaaGjJInV+RxHtSebDTmUmyJsx3v+17Mt/3NZz4gqDun2keCYWcqvVu0WuqH1
         SYBXLOcgrmSALNGtK2Bjyc6JnmfTQfmJP4LKuiobr+RQBF/R3jFpAq4qKwxfKNZacRgD
         gmvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=XdbDnxf84uCdT6qDXfWjCLNehtVPK73rVMJyV4ViNsE=;
        b=ALIvtzX9IMytRYFZVo2NR5XBMs49p2GYufmPK5UjIF9Wzb4B0YjhJUVe3LIZnni58J
         d53quvE5uCmqMtmKoJ2/eeLdI25tFsZPFLBpumG2EryJf1TTJOGwsHFnJQhEqUfSisEH
         Pyocpqd1zizqzA6IwZwN0YJlDQLMVht3pLS/F4txQ8LMMKk4ZQ5NlQ/5crgQBBvpzN5d
         j84Z7d52ClaYus+1sw9A87na8bv2cR2zji6N1HP0tJkjN3jFyslvXbKIvAKHFpE8DrG8
         5muiBmkushmBUh6UK1is+e7ZEY/CZp+K10S1klEMx9w4s5fzbA3XTHuOOv+In6b8WKuf
         ifgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id o9si1260552wmc.70.2019.04.30.03.29.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Apr 2019 03:29:42 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id C4D9C67358; Tue, 30 Apr 2019 12:29:25 +0200 (CEST)
Date: Tue, 30 Apr 2019 12:29:25 +0200
From: Christoph Hellwig <hch@lst.de>
To: Andreas Gruenbacher <agruenba@redhat.com>
Cc: cluster-devel@redhat.com, "Darrick J . Wong" <darrick.wong@oracle.com>,
	Christoph Hellwig <hch@lst.de>, Bob Peterson <rpeterso@redhat.com>,
	Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>,
	Mark Syms <Mark.Syms@citrix.com>,
	Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v7 2/5] fs: Turn __generic_write_end into a void
 function
Message-ID: <20190430102925.GA19506@lst.de>
References: <20190429220934.10415-1-agruenba@redhat.com> <20190429220934.10415-3-agruenba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190429220934.10415-3-agruenba@redhat.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 30, 2019 at 12:09:31AM +0200, Andreas Gruenbacher wrote:
> The VFS-internal __generic_write_end helper always returns the value of
> its @copied argument.  This can be confusing, and it isn't very useful
> anyway, so turn __generic_write_end into a function returning void
> instead.
> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>

