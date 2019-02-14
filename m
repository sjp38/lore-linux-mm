Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8AAE9C10F04
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 06:00:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23319222B6
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 06:00:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="AqFGGKQk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23319222B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84DEB8E0002; Thu, 14 Feb 2019 01:00:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FDF18E0001; Thu, 14 Feb 2019 01:00:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 713DD8E0002; Thu, 14 Feb 2019 01:00:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3056B8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 01:00:10 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id h15so3881822pfj.22
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 22:00:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=EyhZ0LXI8S6DO+1lKPJ+3xCo7Hi2M9DApl/OXP8GRG0=;
        b=DU1kN5q8etAxJbVIfq+DaRWaYjyNAsJg6VCJRlJJQDNCoYnfN7fOWB0v9Ydwbh0RiM
         /HU12RIfm+jePp4xarROEcHfaWwv/kg5V+vScsR4366za0Z6n1rDfYRByKbWXIWeYHkO
         LT13w2b3pypIDsCp4E4TgnaZrMSiWRt3kTwAW5PtBThoTI2/h5YGH3ynPxWNYkuRDmYu
         9lLONpsFIVnG9kZtGbGNdj/09pz3BEFf33shUdL/wDB1GLL8K52i9EDAdY1Jqwnp1pRK
         tj4xZhIILkTlkJkmy+k9ED2gknDlSpUv+E9imIN2BfH2U6LxNP2PPj2KDK72tx345Z/v
         GGLw==
X-Gm-Message-State: AHQUAuaayQhtKfyPnKqver89vCs+fsRt4NhC5tYx4uBhAtm0Uqzkr8dO
	eHgVTAyqv6F2vZi33hXCLHHtZBSsmVjJ5q1QD1+6yX41ve9yyGk3kpa4aSVLDEHDOQdGMrdYslE
	ZX6qUczu7Xs9TeB6Fxdc+4TdtMJ9ow3CK1AEvVsGqYPHDBL1+OYSAkxYBQQdhZAzRQxsbLwGZKe
	peSrMyBWtGVrici7LG+sjE2SdZq5xh6iML7eDEe9raSn0Tgh1GF7G/ChcVGDMQBfIOBgHAR+aQD
	uWL0cfYmZIkxczdbtxnsPNHw7eabQBdd99Wwde2/PwM7bWGvmIRQw0FzeBmDupYU34m4inbbhyD
	akU5M+UPKvfW34AKEaIxhsT1r7XDEyTw77U5/f1kywAxYoMzWE3NKYcMi7BR/Ku6mP+Ttp7eE1a
	f
X-Received: by 2002:a63:be0a:: with SMTP id l10mr2150834pgf.292.1550124009762;
        Wed, 13 Feb 2019 22:00:09 -0800 (PST)
X-Received: by 2002:a63:be0a:: with SMTP id l10mr2150769pgf.292.1550124008763;
        Wed, 13 Feb 2019 22:00:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550124008; cv=none;
        d=google.com; s=arc-20160816;
        b=wYMURILUhEbLxOrEnMj0dzymcYEfABxOvXGr7ueRNUpvUb+kA8SE3c01puVpqYeS0d
         tD9HEkpg/tRCcZ/yO6zOeTcAndsLy7BCkOHaQDxJ9IXdL0acefD3IHWiisIYX52YIM9h
         C1xhBptQ8tBC3OpgidyXyJJwXjnozf0EI61e3eeK652aJjYMOKJTm7PerzFvZshQpy+t
         kQ6ZGSKb+fz6n0rmHuFYx++4Qbzrp1AqX1CVE9iUbS5DNzhxljlgcxAIJRWVxghBHsfi
         jVf4fkhmdzgAH0s2CjIu0PWs0hHOFtey94XJqNTwnbiUVyBNW9ertmivf0ZFWQP5X/WE
         MqZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=EyhZ0LXI8S6DO+1lKPJ+3xCo7Hi2M9DApl/OXP8GRG0=;
        b=KTcgK2xbB8IraWEu5Ywz2AVg/giZUcQ7mms5kRRJQhWbOLzKQ50Q6jY6rzyhUhGm24
         l6LPZChgqgWyL2981KTaE7QSNESoejE+vEO3iuemMzTbEx/PxCvuo0j0NzMHRasJqWhM
         DyMUB4sAB2uaHKlfKPl+zxbDWGrCFFs5M9wq5ZhtB5T5AtNrAOdvZPFSdCqa2TB+pXzR
         YSd+tmfnNevtgkWnauoAmVs68ryu0Q6IB8MpmskRGODNFVGavU+FgVIQuVhzrzLM0/M9
         dC46mjlzC3b08eTUv5SySCyEHqVRZGECBZ9y65bDQ3cBCtleNedexcYvMnKKUX3tMRt4
         IPAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=AqFGGKQk;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t62sor2149938pfa.72.2019.02.13.22.00.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 22:00:08 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=AqFGGKQk;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=EyhZ0LXI8S6DO+1lKPJ+3xCo7Hi2M9DApl/OXP8GRG0=;
        b=AqFGGKQkWIE4m9oWUPQKPfYDWffEV3DD3kw2gte/hIVc+ZOI2ALww287MyZktoOcDi
         CbpDfqNDDxjQTYKo+HSL1jPCcxgIu0tlHCqsVDa+M5KY9ZBsLFTmv/t2wqc5kisOEAq3
         Ey9IsWcwZPCXnG/nVFmz7GUhhGKdm8IWeTP2Dk0HwbmuU3cqx7K5BZzuoEE5qUenFwFw
         FhXuEgKL+2MrnrRuMG0A1nR+NYB/69dpYPvc7V/phtqqydIA5J2EkPID7AxDk9lsLjAP
         NbaOeXfbMwnJ+uPtI2ATX/eErFA+0vBz71ipAT/cQzRY+HNlZcQmNhta5uk0wuPGbr4p
         3GKA==
X-Google-Smtp-Source: AHgI3IZsTuAr/2agKNUI6fHNmik1DYYjhaWBR5rn+7baCxky03ZS5RyeSxDZdNqDP/QzwRlb2m6TAA==
X-Received: by 2002:a62:9f1a:: with SMTP id g26mr2297647pfe.123.1550124008008;
        Wed, 13 Feb 2019 22:00:08 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id z127sm2288820pfb.80.2019.02.13.22.00.07
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 22:00:07 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1guA46-00040P-Jk; Wed, 13 Feb 2019 23:00:06 -0700
Date: Wed, 13 Feb 2019 23:00:06 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, akpm@linux-foundation.org,
	dave@stgolabs.net, jack@suse.cz, cl@linux.com, linux-mm@kvack.org,
	kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
	linux-kernel@vger.kernel.org, alex.williamson@redhat.com,
	paulus@ozlabs.org, benh@kernel.crashing.org, mpe@ellerman.id.au,
	hao.wu@intel.com, atull@kernel.org, mdf@kernel.org, aik@ozlabs.ru
Subject: Re: [PATCH 0/5] use pinned_vm instead of locked_vm to account pinned
 pages
Message-ID: <20190214060006.GE24692@ziepe.ca>
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
 <20190211225447.GN24692@ziepe.ca>
 <20190214015314.GB1151@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214015314.GB1151@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 05:53:14PM -0800, Ira Weiny wrote:
> On Mon, Feb 11, 2019 at 03:54:47PM -0700, Jason Gunthorpe wrote:
> > On Mon, Feb 11, 2019 at 05:44:32PM -0500, Daniel Jordan wrote:
> > 
> > > All five of these places, and probably some of Davidlohr's conversions,
> > > probably want to be collapsed into a common helper in the core mm for
> > > accounting pinned pages.  I tried, and there are several details that
> > > likely need discussion, so this can be done as a follow-on.
> > 
> > I've wondered the same..
> 
> I'm really thinking this would be a nice way to ensure it gets cleaned up and
> does not happen again.
> 
> Also, by moving it to the core we could better manage any user visible changes.
> 
> From a high level, pinned is a subset of locked so it seems like we need a 2
> sets of helpers.
> 
> try_increment_locked_vm(...)
> decrement_locked_vm(...)
> 
> try_increment_pinned_vm(...)
> decrement_pinned_vm(...)
> 
> Where try_increment_pinned_vm() also increments locked_vm...  Of course this
> may end up reverting the improvement of Davidlohr  Bueso's atomic work...  :-(
> 
> Furthermore it would seem better (although I don't know if at all possible) if
> this were accounted for in core calls which tracked them based on how the pages
> are being used so that drivers can't call try_increment_locked_vm() and then
> pin the pages...  Thus getting the account wrong vs what actually happened.
> 
> And then in the end we can go back to locked_vm being the value checked against
> RLIMIT_MEMLOCK.

Someone would need to understand the bug that was fixed by splitting
them. 

I think it had to do with double accounting pinned and mlocked pages
and thus delivering a lower than expected limit to userspace.

vfio has this bug, RDMA does not. RDMA has a bug where it can
overallocate locked memory, vfio doesn't.

Really unclear how to fix this. The pinned/locked split with two
buckets may be the right way.

Jason

