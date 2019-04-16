Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EA67C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 18:35:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9ACF20880
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 18:35:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=plexistor-com.20150623.gappssmtp.com header.i=@plexistor-com.20150623.gappssmtp.com header.b="pEiXT8K3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9ACF20880
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=plexistor.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EC226B0269; Tue, 16 Apr 2019 14:35:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69CBA6B026B; Tue, 16 Apr 2019 14:35:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5644A6B026D; Tue, 16 Apr 2019 14:35:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 067AF6B0269
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 14:35:20 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id f15so19841151wrq.0
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 11:35:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:subject:to:references:cc
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding;
        bh=8y5Z+JdanBBceyEZm22eMmkZF2xMmUpSUQ+GyqeIDOI=;
        b=DzJp0xV64RSSIP07D9P50Q5ds0ZGofXJg7tDWglztBjWjCTdrOzxxq6m/UYwJlC1OJ
         xH2wTrSD+sUil7VsmPcOoB+bgatdFw9tkrKyIqLFogOmgbQABr97b1eVl0xNMChxc99U
         3K1n0C7B7khONzCnfrbViiyfhSA2ngn/rb5UAc2NjJq48iqqlzjS3tYPG9/YWy97R5ey
         aswVw2PDGuI/hW1gKnIAfrU91bcAFdNQlVgSVYSxARhWXjfRmvtDCpqwJi06mYgN2W+8
         kiRYburGTlDD1gsi7nFiQ0f4twINiCw9WqYni1ZHBkfILfHUgu2YOk3xf2YZ/hCHeZ44
         E2wQ==
X-Gm-Message-State: APjAAAVnO9/zy5IReL5Yl3OvEgPWFRo8vfK+DWYO8zIABcYd2yCCE4Fk
	aNQ7eo0Y+/gg9z5p2GtHF9JPMwgOMjCVXssDss9M5dIBj85GHROynVSzWgHJvM/g4HOWMldqMLL
	iBRy2ta5FRxtDWfz7JpXz/BoEvRge81OQbsbkw/xz1PUHlVRKYOb/T/RiSZeMdKqXMw==
X-Received: by 2002:adf:efc1:: with SMTP id i1mr52950371wrp.199.1555439719594;
        Tue, 16 Apr 2019 11:35:19 -0700 (PDT)
X-Received: by 2002:adf:efc1:: with SMTP id i1mr52950335wrp.199.1555439718875;
        Tue, 16 Apr 2019 11:35:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555439718; cv=none;
        d=google.com; s=arc-20160816;
        b=SfFyy79h92ljx9OGXv+0skAlRIRa1nFe2ZmUjNnsd31jeI20NRbBxW3X9MrWmBO6CZ
         uJWrBGjkdE/0jnKlvxRappTAJZszoul0hDiC6BVN7z0RMp4SYcM3n+KgZNZ2rwWdeZax
         8H9GPITh5/oj6fLymSb5m4eECUyJTDz14SzIiDOG+YZ9tRqW2E2abmiBtSoaMYySLrtx
         VnosimYE6dDgSBTF2T43kbkwKyvzqzrucYd5yNKSST6lSXSNKgyBXWXB+QJsIs7hPDGa
         6J3EIgw6ajIyth36vy5+6pDmewejryBf9JO5vws9W9RShLf1pr20oUWJ1aiRsPAFCegy
         l62w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:cc:references:to:subject:from:dkim-signature;
        bh=8y5Z+JdanBBceyEZm22eMmkZF2xMmUpSUQ+GyqeIDOI=;
        b=mtxILaiAockFvVPtbecU99NbFecKF+04Wy6bNfRrtbslW2CN68+r0M+c7j93G7TSEL
         aknQZVTLCKXb4zoTY6AA5v1vxzpaWG0QylS+S4gCKMR6PVmvVUE0qRNNH14WMYJ2MbCB
         /8fslRpoljJrs4uBMGZnQAae6eZ988Ia7qHZ3+VrvNPe5JZVack9228x9pzMjzIvqefd
         NgWpJOv4HdywP4+fOGTLlV0Aiy8ALPK9zeui1Mk6e5yaK5QKauT55HRBZ5le4q+zLUUP
         gn2mR1Ac9zhlLvtXPlg/aV3MJNh0ldIB/7aJd/nw2tYDgzqUAXwCB9Qoc0Ps1FNA6fcp
         hcbg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@plexistor-com.20150623.gappssmtp.com header.s=20150623 header.b=pEiXT8K3;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of boaz@plexistor.com) smtp.mailfrom=boaz@plexistor.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h187sor151720wmf.6.2019.04.16.11.35.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 11:35:18 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of boaz@plexistor.com) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@plexistor-com.20150623.gappssmtp.com header.s=20150623 header.b=pEiXT8K3;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of boaz@plexistor.com) smtp.mailfrom=boaz@plexistor.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=plexistor-com.20150623.gappssmtp.com; s=20150623;
        h=from:subject:to:references:cc:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding;
        bh=8y5Z+JdanBBceyEZm22eMmkZF2xMmUpSUQ+GyqeIDOI=;
        b=pEiXT8K3FkXb708qyAnd50wNFcy2vun2MP+TowzcADOfGsdzaDkZm+Z2W3YYiiyPBx
         /i0cqaD5GKrDE3+fT07IThNc2+oq7fzIhXpNNdGF3utypwg0l23VOeTeSDdJVgGR/IGU
         f6cPyrWAO8utqa9FivqFwd/7ZEgOx0IVbnArHlXAjaxyXbHNGYh7VxyELg3BRGOpfywO
         fAvv2akX88AHkqLijjx5GMp59TSk8BRbl0tpq29nLGCdvd4dnxlEbs9lgDzNct5UiEMH
         JF47xRidohMvpl2d1nE6CYxbhKK4OA4j3JU1w6qgJ5U+TDCaPBmgi0m6oKaNv05XLTSK
         1HYQ==
X-Google-Smtp-Source: APXvYqzElk8Bwv9PNk1zXzEbAVnyrCQluryqDkFg71tdlsIqJy7aqVfhGldpLqEFzWF5iB8YabHIug==
X-Received: by 2002:a7b:cb16:: with SMTP id u22mr27831487wmj.60.1555439718379;
        Tue, 16 Apr 2019 11:35:18 -0700 (PDT)
Received: from [10.0.0.5] (bzq-84-110-213-170.static-ip.bezeqint.net. [84.110.213.170])
        by smtp.googlemail.com with ESMTPSA id u189sm453146wme.25.2019.04.16.11.35.14
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 11:35:17 -0700 (PDT)
From: Boaz Harrosh <boaz@plexistor.com>
Subject: Re: [PATCH v1 00/15] Keep track of GUPed pages in fs and block
To: jglisse@redhat.com
References: <20190411210834.4105-1-jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-block@vger.kernel.org, linux-mm@kvack.org,
 John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>,
 Dan Williams <dan.j.williams@intel.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>,
 Johannes Thumshirn <jthumshirn@suse.de>, Christoph Hellwig <hch@lst.de>,
 Jens Axboe <axboe@kernel.dk>, Ming Lei <ming.lei@redhat.com>,
 Jason Gunthorpe <jgg@ziepe.ca>, Matthew Wilcox <willy@infradead.org>,
 Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org,
 samba-technical@lists.samba.org, Yan Zheng <zyan@redhat.com>,
 Sage Weil <sage@redhat.com>, Ilya Dryomov <idryomov@gmail.com>,
 Alex Elder <elder@kernel.org>, ceph-devel@vger.kernel.org,
 Eric Van Hensbergen <ericvh@gmail.com>, Latchesar Ionkov <lucho@ionkov.net>,
 Mike Marshall <hubcap@omnibond.com>, Martin Brandenburg
 <martin@omnibond.com>, devel@lists.orangefs.org,
 Dominique Martinet <asmadeus@codewreck.org>,
 v9fs-developer@lists.sourceforge.net, Coly Li <colyli@suse.de>,
 Kent Overstreet <kent.overstreet@gmail.com>, linux-bcache@vger.kernel.org,
 =?UTF-8?Q?Ernesto_A._Fern=c3=a1ndez?= <ernesto.mnd.fernandez@gmail.com>
Message-ID: <2c124cc4-b97e-ee28-2926-305bc6bc74bd@plexistor.com>
Date: Tue, 16 Apr 2019 21:35:04 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101
 Thunderbird/45.4.0
MIME-Version: 1.0
In-Reply-To: <20190411210834.4105-1-jglisse@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 05:08:19PM -0400, jglisse@redhat.com wrote:
> From: Jérôme Glisse <jglisse@redhat.com>
> 
> This patchset depends on various small fixes [1] and also on patchset
> which introduce put_user_page*() [2] and thus is 5.3 material as those
> pre-requisite will get in 5.2 at best. Nonetheless i am posting it now
> so that it can get review and comments on how and what should be done
> to test things.
> 
> For various reasons [2] [3] we want to track page reference through GUP
> differently than "regular" page reference. Thus we need to keep track
> of how we got a page within the block and fs layer. To do so this patch-
> set change the bio_bvec struct to store a pfn and flags instead of a
> direct pointer to a page. This way we can flag page that are coming from
> GUP.
> 
> This patchset is divided as follow:
>     - First part of the patchset is just small cleanup i believe they
>       can go in as his assuming people are ok with them.


>     - Second part convert bio_vec->bv_page to bio_vec->bv_pfn this is
>       done in multi-step, first we replace all direct dereference of
>       the field by call to inline helper, then we introduce macro for
>       bio_bvec that are initialized on the stack. Finaly we change the
>       bv_page field to bv_pfn.

Why do we need a bv_pfn. Why not just use the lowest bit of the page-ptr
as a flag (pointer always aligned to 64 bytes in our case).

So yes we need an inline helper for reference of the page but is it not clearer
that we assume a page* and not any kind of pfn ?
It will not be the first place using low bits of a pointer for flags.

That said. Why we need it at all? I mean why not have it as a bio flag. If it exist
at all that a user has a GUP and none-GUP pages to IO at the same request he/she
can just submit them as two separate BIOs (chained at the block layer).

Many users just submit one page bios and let elevator merge them any way.

Cheers
Boaz

>     - Third part replace put_page(bv_page(bio_vec)) with a new helper
>       which will use put_user_page() when the page in the bio_vec is
>       coming from GUP.
>     - Fourth part update BIO to use bv_set_user_page() for page that
>       are coming from GUP this means updating bio_add_page*() to pass
>       down the origin of the page (GUP or not).
>     - Fith part convert few more places that directly use bvec_io or
>       BIO.
> 

