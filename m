Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0A932C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 22:09:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8348206BA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 22:09:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="tjHvQbuT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8348206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C6F66B0007; Tue, 16 Apr 2019 18:09:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4744A6B0008; Tue, 16 Apr 2019 18:09:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33C946B000A; Tue, 16 Apr 2019 18:09:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id D4E3E6B0007
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 18:09:28 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id h4so18623026wrw.5
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 15:09:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:references:cc:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding;
        bh=vLZi3xWgBQQM83NFZVQKapZDuHfaXytUlCWtMDbYEWo=;
        b=Vn165VvuQH7NWd+nC12E8H2yVriz/EnmNj5G9/i45Yi1UY20ik3f+iYs0wZahE2+2o
         edGKEpSSvte4mSORqUGQApkrYc3G916McjBeneMz//vJkve1XqFTMJv7WmKFOQNzUhN1
         2KpHK+Pk72cFN0TmL5RKc9NO6e2sQqikbESjmXzHbNbmMnsiRrLmtpIh3qv7o4W88PQk
         9Y9WaAGDoFwxEyUSv8VuTNJF7J7XgJBTZvN7NYkfLw6RS65938jB0OcsZ14n4sPLvqtQ
         JidvENEx6HSFB/iujw2/5ZpBNsHqqUq95fk2pdOy3Mzd46P47Qu7JZOHlJzy2ZTGDfrw
         WwfA==
X-Gm-Message-State: APjAAAUaeBeJ0+Wd51FUsIKilA1JO4Pus3cr+AHyLqXAl2epOF18pyKC
	EOKhhziWt5BwKp4/DowMIyyIJ9vvB/A42ls4mYM/EQTUxQFy7EDXfD182UQonlw23JeQXM2dkvH
	axhWU4Iw+6c47VICW/Gltjptv9lRQqqxssAlIHG3Plw5Po6Aw+nwehs/Gj5nDFBdeKQ==
X-Received: by 2002:a1c:9617:: with SMTP id y23mr27860061wmd.31.1555452568302;
        Tue, 16 Apr 2019 15:09:28 -0700 (PDT)
X-Received: by 2002:a1c:9617:: with SMTP id y23mr27860017wmd.31.1555452567248;
        Tue, 16 Apr 2019 15:09:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555452567; cv=none;
        d=google.com; s=arc-20160816;
        b=jpM8Rvub31PQVcnYU97YW7t45lfgoGiYueicLHF0A/015tkMD1SaS+lmZse+AXAPNj
         41BdYJs2P89S6mwIe1DCIZRfwh0l0j2kXN/FOvGqIgNqaZm9XJj+pvpbgnggfMom8qyY
         dTjEKV+8nWFrjFKFkJ7V85O6vKNhu+WLJwl4QJpt1rNLklHoFm4YC/JzOktQfhEMwGhJ
         /BT/tY1kbNnVTEWaR90Dm6bcR21a68w47NQnv05+LxeTVP1t1/2Bf2yM5b8Td31KikUv
         m2j8csKFMvbYUfc1LRKcRptFTOtGuTpdEae7ET+VWRLIkeD8Y28IZlfXiMpelOWUCgKB
         9z0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:mime-version:user-agent:date
         :message-id:from:cc:references:to:subject:dkim-signature;
        bh=vLZi3xWgBQQM83NFZVQKapZDuHfaXytUlCWtMDbYEWo=;
        b=aUseGz8ZB7bFilWZZRZfgj3hzIdqUZSvBNh09fmtlAo4T8SyT4qCv9KUpq2zeNXwMU
         2vtd+gj4bNK9nljNxVdnE7tjOjXKvBXH9aGAc+VbVtKBMLzqvaPwB/2AQQZlwqHfjWF9
         t1SJFPMta41GqPdxS5g5AeuNXWkSuoNU+Q3GlCKSOwBuA29nYWrpqZu23GQ7nLxgjDKx
         fwIMwKeY821G6/4ldgV1NxJorTaCJLpaNpTme19WH/KNlEhpbgDcPiUADeZ/Froj2THv
         JDyus+v3ACN05vvt0PvbONgsZKaxhV2Hz5d6hvnswCasOPSFU/RDuyyLxdMuCm8b+pEP
         b/AA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tjHvQbuT;
       spf=pass (google.com: domain of openosd@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=openosd@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b16sor36939078wrv.6.2019.04.16.15.09.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Apr 2019 15:09:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of openosd@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=tjHvQbuT;
       spf=pass (google.com: domain of openosd@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=openosd@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:references:cc:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding;
        bh=vLZi3xWgBQQM83NFZVQKapZDuHfaXytUlCWtMDbYEWo=;
        b=tjHvQbuTJQL4kJ76zQRrF1l3uL6COs0CyiYtp5OnHc7Gcn6AYPAoIv0iHG101/HH42
         +QPJkowrqGPp2WIp7WpNVd2hrXDJ4HoJYteVSDJyukIY0HHGXLrzLOhDSzSwS0dSdON8
         RHiknTaY41P8K3NxWwc6wS4hpRE8AhW4edlbOBD+teH8AWyIw9FTkZDetysc/9+guWVu
         Y623m/GYzTim/hhoJ/0sYG7qZv7hNH9slXw9iLU2P/oTcljeReWrdQ8/U1hpglHS5bzF
         0dINjkh21LjcyNVDXg2HDoLYG5HVzYW8lRbGwEytQkuBcGcQA1y1bq0+XNiNQxnHBsK7
         dNTw==
X-Google-Smtp-Source: APXvYqycMfk7Hb5BK+ANAakriJGaFegQrNOcofwQWFcrxzUoCzacWNHgM4Jy27yYMfnGuVP6eemzEw==
X-Received: by 2002:a5d:53c1:: with SMTP id a1mr32527254wrw.174.1555452566894;
        Tue, 16 Apr 2019 15:09:26 -0700 (PDT)
Received: from [10.0.0.5] (bzq-84-110-213-170.static-ip.bezeqint.net. [84.110.213.170])
        by smtp.gmail.com with ESMTPSA id c10sm63597309wru.83.2019.04.16.15.09.23
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 15:09:25 -0700 (PDT)
Subject: Re: [PATCH v1 00/15] Keep track of GUPed pages in fs and block
To: Jerome Glisse <jglisse@redhat.com>, Boaz Harrosh <boaz@plexistor.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
 <2c124cc4-b97e-ee28-2926-305bc6bc74bd@plexistor.com>
 <20190416185922.GA12818@kmo-pixel>
 <CAPcyv4jLrQ6evLAJzsASh=H6Tzx8E1oiF+YR3L2fOpbZYNUWGg@mail.gmail.com>
 <ccac6c5a-7120-0455-88de-ca321b01e825@plexistor.com>
 <20190416195735.GE21526@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>,
 Kent Overstreet <kent.overstreet@gmail.com>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-block@vger.kernel.org,
 Linux MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>,
 Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>,
 Johannes Thumshirn <jthumshirn@suse.de>, Christoph Hellwig <hch@lst.de>,
 Jens Axboe <axboe@kernel.dk>, Ming Lei <ming.lei@redhat.com>,
 Jason Gunthorpe <jgg@ziepe.ca>, Matthew Wilcox <willy@infradead.org>,
 Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org,
 Yan Zheng <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
 Ilya Dryomov <idryomov@gmail.com>, Alex Elder <elder@kernel.org>,
 ceph-devel@vger.kernel.org, Eric Van Hensbergen <ericvh@gmail.com>,
 Latchesar Ionkov <lucho@ionkov.net>, Mike Marshall <hubcap@omnibond.com>,
 Martin Brandenburg <martin@omnibond.com>,
 Dominique Martinet <asmadeus@codewreck.org>,
 v9fs-developer@lists.sourceforge.net, Coly Li <colyli@suse.de>,
 linux-bcache@vger.kernel.org,
 =?UTF-8?Q?Ernesto_A._Fern=c3=a1ndez?= <ernesto.mnd.fernandez@gmail.com>
From: Boaz Harrosh <openosd@gmail.com>
Message-ID: <41e2d7e1-104b-a006-2824-015ca8c76cc8@gmail.com>
Date: Wed, 17 Apr 2019 01:09:22 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:45.0) Gecko/20100101
 Thunderbird/45.4.0
MIME-Version: 1.0
In-Reply-To: <20190416195735.GE21526@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 16/04/19 22:57, Jerome Glisse wrote:
<>
> 
> A very long thread on this:
> 
> https://lkml.org/lkml/2018/12/3/1128
> 
> especialy all the reply to this first one
> 
> There is also:
> 
> https://lkml.org/lkml/2019/3/26/1395
> https://lwn.net/Articles/753027/
> 

OK I have re-read this patchset and a little bit of the threads above (not all)

As I understand the long term plan is to keep two separate ref-counts one
for GUP-ref and one for the regular page-state/ownership ref.
Currently looking at page-ref we do not know if we have a GUP currently held.
With the new plan we can (Still not sure what's the full plan with this new info)

But if you make it such as the first GUP-ref also takes a page_ref and the
last GUp-dec also does put_page. Then the all of these becomes a matter of
matching every call to get_user_pages or iov_iter_get_pages() with a new
put_user_pages or iov_iter_put_pages().

Then if much below us an LLD takes a get_page() say an skb below the iscsi
driver, and so on. We do not care and we keep doing a put_page because we know
the GUP-ref holds the page for us.

The current block layer is transparent to any page-ref it does not take any
nor put_page any. It is only the higher users that have done GUP that take care of that.

The patterns I see are:

  iov_iter_get_pages()

	IO(sync)

  for(numpages)
	put_page()

Or

  iov_iter_get_pages()

	IO (async)
		->	foo_end_io()
				put_page

(Same with get_user_pages)
(IO need not be block layer. It can be networking and so on like in NFS or CIFS
 and so on)

The first pattern is easy just add the proper new api for
it, so for every iov_iter_get_pages() you have an iov_iter_put_pages() and remove
lots of cooked up for loops. Also the all iov_iter_get_pages_use_gup() just drops.
(Same at get_user_pages sites use put_user_pages)

The second pattern is a bit harder because it is possible that the foo_end_io()
is currently used for GUP as well as none-GUP cases. this is easy to fix. But the
even harder case is if the same foo_end_io() call has some pages GUPed and some not
in the same call.

staring at this patchset and the call sites I did not see any such places. Do you know
of any?
(We can always force such mixed-case users to always GUP-ref the pages and code
 foo_end_io() to GUP-dec)

So with a very careful coding I think you need not touch the block / scatter-list layers
nor any LLD drivers. The only code affected is the code around the get_user_pages and friends.
Changing the API will surface all those.
(IE. introduce a new API, convert one by one, Remove old API)

Am I smoking?

BTW: Are you aware of the users of iov_iter_get_pages_alloc() Do they need fixing too?

> Cheers,
> Jérôme
> 

Thanks
Boaz

