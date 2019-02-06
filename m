Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6151FC169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 09:50:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0A7AB20B1F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 09:50:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0A7AB20B1F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 624358E00AB; Wed,  6 Feb 2019 04:50:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D41E8E00AA; Wed,  6 Feb 2019 04:50:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C7838E00AB; Wed,  6 Feb 2019 04:50:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 07EEE8E00AA
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 04:50:07 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id v2so4535025plg.6
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 01:50:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=DuY2zviTcaphvLnzxlkAhfID059faVqqhbDuTJeLZVY=;
        b=Xqozs6hIthLjEPDJ2YReNVwOfWfq76qDThB6dNY2TSYeugssy0TpccxxVirzmgFPdo
         nbTiahalOR/GF4VxBQtWDfaCqKVdAw9HXYtUgF8LkcMEigJxAAC+TYB2mdB8Szil/URM
         zKgNxMsnZvcGjdUxFmVkMelnFZaby4hlR9H48FL/nttnwk7jdTdT6ZMYWQEyAt5S5dwq
         4UaKiLs4FoJpxLC42vdPeCFWd7O0rIrem8zrYUMRcy3T5n/4Wq78Ao0kVy69dLs7v0jO
         8pTgFe83nycjTtfETPsYtEoQb+CpvmaRV8a6MM95kYgZa7jdC31FGnMEUW15qpJiRkVh
         Hjwg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAubNihOeKuN6etdc1OUVGGDfUPuTUmXGfPEddCpJ4jJKPPPD3sRh
	XqxL2VHkKtKpUxoCwivLXhZURtI2wtLt7LqTs38CA4tg8YI6s/UFJ3DN4pFacwwop1gTBN1aYEd
	Hrzwx0hmqkinN/1u1Ohi7MRxs45fKA+zD2CJrevmV8hc1/gH63xhIF0ZsYb9dz5gv9g==
X-Received: by 2002:a63:3f89:: with SMTP id m131mr9007337pga.115.1549446606597;
        Wed, 06 Feb 2019 01:50:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZhMjUWnRbw8fs8reUionuKhJbm24dmjifAqwFnae1j1+HN49RRufNgdRgomttob0JtYTDA
X-Received: by 2002:a63:3f89:: with SMTP id m131mr9007272pga.115.1549446605573;
        Wed, 06 Feb 2019 01:50:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549446605; cv=none;
        d=google.com; s=arc-20160816;
        b=zq7qxJfJ7eMr4U5JE3N7e2wEXDwDhtFlGT8zvOaAjIW0IBjjjEm2wgBTg2ZH2aR77x
         RyvND7illB6DbpRhBaJ5Ew/C3nnr4bFhdxVL+xNh6kjBN2Dvifv5zaTSv2wxI6jt+Gym
         9ljvLnFsEyi8aj5JqHt8gz5AlkjjJD0M1F/lAE9KBGP0Veji1FFTG3Q6bqKtHLHbdymk
         /2bAemUK2qLyLb624RHLOjmUoLEKtm6NaGEsXFx5iBelBnLD4GF5OAxbaIB9zQUrnfZe
         Fyvv/vbZ9iNs9tOYqRbUDsNHJaUGbMbrrDlVblW+whtPvLUFtdhAdMfaPZj9nl70zHC8
         YzsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=DuY2zviTcaphvLnzxlkAhfID059faVqqhbDuTJeLZVY=;
        b=tFGy1SPitm195E7oE7wMk+2DBGtvH11ybrJ6UXq8KrQHjOLeBsCAe9OL1zg3W8j4Mw
         zMMnB88+mLvas4RQcp+txqLyEQ5dS2RWyXRj7HcUoBZSULbeJcc2OaWuE4w7T/GWRiyM
         ZSmZMb0XX2B7ltx4ZJlzq8dUIPEWA9pJjW3pv84vs/Z4j3vH88qkaKhZsyerH2obaqiR
         /oIms6RXdaca/VFEKrBRjLvda5+upd4SAj/nLDNvoL51y7kbg3RTqq3CZp5CYxsZ9N6E
         cwhJ8ven+P8l1GuMuYvq2wkEpfHIES6TE3fCdpinJqUoKuMub2BfzdFxylWZkHxSes8H
         knPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o7si5068404pgg.118.2019.02.06.01.50.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 01:50:05 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 263D1AE43;
	Wed,  6 Feb 2019 09:50:02 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 7E0631E3E15; Wed,  6 Feb 2019 10:50:00 +0100 (CET)
Date: Wed, 6 Feb 2019 10:50:00 +0100
From: Jan Kara <jack@suse.cz>
To: Ira Weiny <ira.weiny@intel.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-rdma@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>,
	Jerome Glisse <jglisse@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	Dave Chinner <david@fromorbit.com>,
	Doug Ledford <dledford@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190206095000.GA12006@quack2.suse.cz>
References: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190205175059.GB21617@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 05-02-19 09:50:59, Ira Weiny wrote:
> The problem: Once we have pages marked as GUP-pinned how should various
> subsystems work with those markings.
> 
> The current work for John Hubbards proposed solutions (part 1 and 2) is
> progressing.[1]  But the final part (3) of his solution is also going to take
> some work.
> 
> In Johns presentation he lists 3 alternatives for gup-pinned pages:
> 
> 1) Hold off try_to_unmap
> 2) Allow writeback while pinned (via bounce buffers)
> 	[Note this will not work for DAX]

Well, but DAX does not need it because by definition there's nothing to
writeback :)

> 3) Use a "revocable reservation" (or lease) on those pages
> 4) Pin the blocks as busy in the FS allocator
> 
> The problem with lease's on pages used by RDMA is that the references to
> these pages is not local to the machine.  Once the user has been given
> access to the page they, through the use of a remote tokens, give a
> reference to that page to remote nodes.  This is the core essence of
> RDMA, and like it or not, something which is increasingly used by major
> Linux users.
> 
> Therefore we need to discuss the extent by which leases are appropriate and
> what happens should a lease be revoked which a user does not respond to.

I don't know the RDMA hardware so this is just an opinion of filesystem /
mm guy but my idea how this should work would be:

MM/FS asks for lease to be revoked. The revoke handler agrees with the
other side on cancelling RDMA or whatever and drops the page pins. Now I
understand there can be HW / communication failures etc. in which case the
driver could either block waiting or make sure future IO will fail and drop
the pins. But under normal conditions there should be a way to revoke the
access. And if the HW/driver cannot support this, then don't let it anywhere
near DAX filesystem.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

