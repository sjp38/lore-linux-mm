Return-Path: <SRS0=iDsh=XH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBB1AC5ACAE
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 10:06:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A768F20830
	for <linux-mm@archiver.kernel.org>; Thu, 12 Sep 2019 10:06:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="i0kb28AF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A768F20830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 569F66B0003; Thu, 12 Sep 2019 06:06:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51BAF6B0005; Thu, 12 Sep 2019 06:06:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4304C6B0006; Thu, 12 Sep 2019 06:06:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0224.hostedemail.com [216.40.44.224])
	by kanga.kvack.org (Postfix) with ESMTP id 226576B0003
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 06:06:44 -0400 (EDT)
Received: from smtpin04.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id C5465181AC9BA
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 10:06:43 +0000 (UTC)
X-FDA: 75925839486.04.coast07_74e174b12ea5d
X-HE-Tag: coast07_74e174b12ea5d
X-Filterd-Recvd-Size: 3784
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 12 Sep 2019 10:06:43 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id v38so23412615edm.7
        for <linux-mm@kvack.org>; Thu, 12 Sep 2019 03:06:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=aqH8fHtjT3IC/e5deArdd8oGX2wHZ4L9R7PbYi/ofyE=;
        b=i0kb28AFynzLDWYc/Md76wO+4Lrr7IrS1+6jbZyJp7B8cHfwzc/YZfeotZo+Pv4uZ7
         UAKdPDOo0lrmH5R3sOlwBQOxvcLChktxmsEkB+2uTyH+Rq5XfI65O9Z94Z+obWutx07s
         XzEavAok9ThOFRQDiddgAkrUpPD9vKHfgSV4xMOrhKHaSN0oE7H4Yr4VBAe2HEbZqAnb
         9KSSc54fY9hiuvthnxGax8VALweMokoc51TtUn2OguvauYy6k4Wf/eRQakDuDca+32zF
         nVCVZN16xOi5r9rxTqinPAKy8k7PUWvLiCbD79ga6QA+z7+zIgZuSPfhFacnfdsxQf4c
         9vJQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=aqH8fHtjT3IC/e5deArdd8oGX2wHZ4L9R7PbYi/ofyE=;
        b=GuIA3V9JU72pEvcTle5ewMW4Cmqg2PWsZDiRDC0UVqLPW11sOvGTb/A72XjCLqPrlS
         /oWm/pwYSqoO78XbA1OqcZvIkdn8iSsnqNsBy3jBwFQJL86aXpeQ73PAdV6MsRHxpRzb
         wJY1QGlKrhHJyrDKl0MRbgiCI3PaOX3006+wbp3G4qYw1PjPpbAZNNd4cZ8gKUfjP6uG
         LYYY/BrwT/ApDnwBoi8uXSjlYliHhWYaI/OILmuVjSKH4+ZE5rWv+EewcCoULl/fosI1
         HPV8HV0Q5p3rFwa1jffRWknBX45sMnK+mIpB+1OyVY7GZEF9SodRfRnkrl9fgCkj643A
         9THA==
X-Gm-Message-State: APjAAAVBdvygKe9DSGmhaxaV2o/laCQ2GoM+ODe1SSaUS9l56ertzJ4y
	J5C9YMCKoAASxdDp7e/8xH7wcg==
X-Google-Smtp-Source: APXvYqwr+ZxopPgubxD20LDe8gLP9CjjeqgoPlo0lC+2DPB6zZR0a/xFGp2E99s4bGIqlKqsUOHv2Q==
X-Received: by 2002:a05:6402:125a:: with SMTP id l26mr4416227edw.95.1568282802039;
        Thu, 12 Sep 2019 03:06:42 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id n1sm118790ejc.16.2019.09.12.03.06.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Sep 2019 03:06:41 -0700 (PDT)
Received: by box.localdomain (Postfix, from userid 1000)
	id 68FF0100B4A; Thu, 12 Sep 2019 13:06:42 +0300 (+03)
Date: Thu, 12 Sep 2019 13:06:42 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Yu Zhao <yuzhao@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 4/4] mm: lock slub page when listing objects
Message-ID: <20190912100642.57ycbflh5ykcgttu@box>
References: <20190912004401.jdemtajrspetk3fh@box>
 <20190912023111.219636-1-yuzhao@google.com>
 <20190912023111.219636-4-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190912023111.219636-4-yuzhao@google.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 11, 2019 at 08:31:11PM -0600, Yu Zhao wrote:
> Though I have no idea what the side effect of such race would be,
> apparently we want to prevent the free list from being changed
> while debugging the objects.

Codewise looks good to me. But commit message can be better.

Can we repharase it to indicate that slab_lock is required to protect
page->objects?

-- 
 Kirill A. Shutemov

