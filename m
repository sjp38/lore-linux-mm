Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E291C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 14:51:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B0222192D
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 14:51:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B0222192D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC7668E0002; Fri, 15 Feb 2019 09:51:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9C868E0001; Fri, 15 Feb 2019 09:51:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B2D48E0002; Fri, 15 Feb 2019 09:51:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5DD8D8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 09:51:29 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id f193so3338160wme.8
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 06:51:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=O5p0KAwr5ZokybPIDy4qfIIkgCW6D5hJVc4VBUKYBqI=;
        b=NN7pp52GdX+SZsNwS3ZXwJCgJG0kqlLbJITSG12OJu821Em2nttMhJnGwKMyle7hTM
         QhLQAFnoUdiIag1PsFr9qg+ItbWNxhR9e6O48RPKr2wuDJ8ChBG5sWEjR0LrOyEPY6eP
         kYdkX+ukPjYTi5ZB2Sk+x0UdnlockV7tSzOSfNj5LvB8C371XUYCCxMODIorV9KhAw7p
         Sf5LdpPD+1RlhjPGH5LIpFmw9plHwl6RhbCWcWqRjyT2KVwV0owouxRD25NZlS9VZ1kr
         Ort5aO1dI5ZSumAIl1LGzGx/BEpfmweHQ/Zf/BXtLoqglaV2b5goLEpRGwXlU8OTjMhS
         4mOA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AHQUAuYoUMvWDp0E0XSHOc+55uPu+eqRKtj6s5QYJ41O8hHZ/wlwUauF
	Z2LYwGsC+xe+c4HYH7/AbAoFLWu9qt053PplTiVGSfCezdm+F1Oii06FdEMmpVuBma4lMzOpG70
	LCOY9kW8ebZYZZiOJN7h3oSYxbFTfGBHaYZ2QcYPDa6iXtUM/TAHgzg/Ahkn9Qq4IBw==
X-Received: by 2002:adf:ecc7:: with SMTP id s7mr6995333wro.255.1550242288914;
        Fri, 15 Feb 2019 06:51:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZR+SZiwpshMyg+lsMoS8X5Bf79OXaDVYhTfVk0D4S68mXIeenyiZOpuWGwpTOq0dHERGtW
X-Received: by 2002:adf:ecc7:: with SMTP id s7mr6995297wro.255.1550242288000;
        Fri, 15 Feb 2019 06:51:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550242287; cv=none;
        d=google.com; s=arc-20160816;
        b=Zo/+EEWM76qLvnHq05z6HgpIrhLRpl/kb7lB52GYxdjOLemgVg84hUUNAkKhz0zTCA
         t6XYX1xFP8//wV+KfIj8RZII4uGOYiDXx3ZfSFf6Q4CPrVMjt/OilAxSX1z9+Xxc5WLq
         s4jamBju2q7bxdjiuwlt02efL9q2p0rHFJmroQ2bUE0hY4oh0nmvEWI3tLo8hhAaR4nn
         z/Ydc6q720pv1SqcRIqBIHChuGiLlPQFb+tbGI3mL6XKtnHz38YDCuTWHLAVCTGEfFxa
         fObs1SuPkXysemwuoqQkZgICQyLmUeA2yiAbF46nyY1obvATla0WKO2c37f8bU6BW1Lk
         RTlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=O5p0KAwr5ZokybPIDy4qfIIkgCW6D5hJVc4VBUKYBqI=;
        b=irpTefAvsHFVerGuBiHYpazci9zexym6gl6D/uP8OGD6377izwLLZxYXCHrV3n1ASj
         x4n1Wcq7GHr1a1rilVqhTK/Jk2lYDDugIBX29P/8eQgynmfuBbOd34bjm7D808dehPqn
         PBGdKK+asxThk72pQA/xHb+d1Hwp9qtyRDLDZau1188D8eFwOqtWHCMEHJ04kUc+cq1u
         3NPdWnWrHReicEp6LJVcL2DiDfz5X8eSxZ57QVXxTbmBO71SSg3ue4i3fE7AZ101hkH/
         X8Inm4/LCJw+wxVslgx6tAVeY/AeIf8ZdfRN5TkdrGqutA2kY2W4wzvRJ9e1e4caDNuY
         Z+/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id k14si3718034wrx.125.2019.02.15.06.51.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 06:51:27 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 233C668D93; Fri, 15 Feb 2019 15:51:27 +0100 (CET)
Date: Fri, 15 Feb 2019 15:51:26 +0100
From: Christoph Hellwig <hch@lst.de>
To: Ming Lei <ming.lei@redhat.com>
Cc: Jens Axboe <axboe@kernel.dk>, linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	Theodore Ts'o <tytso@mit.edu>, Omar Sandoval <osandov@fb.com>,
	Sagi Grimberg <sagi@grimberg.me>,
	Dave Chinner <dchinner@redhat.com>,
	Kent Overstreet <kent.overstreet@gmail.com>,
	Mike Snitzer <snitzer@redhat.com>, dm-devel@redhat.com,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-fsdevel@vger.kernel.org, linux-raid@vger.kernel.org,
	David Sterba <dsterba@suse.com>, linux-btrfs@vger.kernel.org,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	linux-xfs@vger.kernel.org, Gao Xiang <gaoxiang25@huawei.com>,
	Christoph Hellwig <hch@lst.de>, linux-ext4@vger.kernel.org,
	Coly Li <colyli@suse.de>, linux-bcache@vger.kernel.org,
	Boaz Harrosh <ooo@electrozaur.com>,
	Bob Peterson <rpeterso@redhat.com>, cluster-devel@redhat.com
Subject: Re: [PATCH V15 00/18] block: support multi-page bvec
Message-ID: <20190215145126.GA16717@lst.de>
References: <20190215111324.30129-1-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190215111324.30129-1-ming.lei@redhat.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I still don't understand why mp_bvec_last_segment isn't simply
called bvec_last_segment as there is no conflict.  But I don't
want to hold this series up on that as there only are two users
left and we can always just fix it up later.

