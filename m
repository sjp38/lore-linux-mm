Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBCBDC282C2
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 20:12:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77D432173B
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 20:12:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="d2P+Grqs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77D432173B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F33D18E0064; Thu,  7 Feb 2019 15:12:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE4358E0002; Thu,  7 Feb 2019 15:12:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DD4028E0064; Thu,  7 Feb 2019 15:12:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 975B18E0002
	for <linux-mm@kvack.org>; Thu,  7 Feb 2019 15:12:56 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id y6so727527pfn.11
        for <linux-mm@kvack.org>; Thu, 07 Feb 2019 12:12:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=i3o0Wtmju3HWlOWRjY87xJXCKZCTQhmfuSMisLTGU9Q=;
        b=n3TjSxZoXceMorbb3yy0noDQF+u4Tb1BEuP/FrcaAxiNDx3D+PM6GaViBqtLHWtDHp
         k6kmZo+iM9zQi/DwV3lnwGFCzb45S8SARXeoI80bS7QpaWfBTq+vvCMekI0n2RrLZfDf
         Siaypk2qecaH5d3a6zdsr8GdTSvSYmOFr0wZBRdjNq0SPnZG+UjTmORsC+7UMMlpsOtI
         9uno7BhvKkpbnvk9Md0XOuckJGri3YuH4mjb1zywTH5XwXtTttvZcxo8nunvHG3oOkoS
         UdhZzgKnOqFT/LwbrWbpS2MZUdneOoNoyaRnodKAjN5PBFv5gJ48taBQbDmpuzKtUnoM
         Wzhg==
X-Gm-Message-State: AHQUAuaUsz1is/o94o7/ViZ2w4Iu52Y93uMBdjWxV9x/eyyDTl1mDdcV
	GarKMO/HeewjGdbWRdXCES4OaM2+t5kMEh9uGAfDWIZ+3LGZiDj1ykh4B+81Q9PGFNO1WWshHCQ
	/rdDwgUZ1swfCWZj+SFkyM/KV1T1tJMdhlBCYWtBOVaLU3HbCGfAP7fThs0UkPf9X53lPEMpHqo
	cOrF0hbPLBORHa/x1c7k7z9/XunGseX0hsN2T5d69vuF1Q4tGnB8yVVFzUPMu18k2A466rCmg2W
	KxYZSOJQ37zbQueyS7t1PWuHkXBJmaH2y/FY/4kiRGoC2eQ1cNByKbx7ba1R1tpysctIJeJDV1j
	0vH6K1Szckw914XzeDnNuu79GIjl+XuiDj//gDkNCorCUD/qP1Hz+VJl0AkW8aRMXLfYEQkK4hE
	t
X-Received: by 2002:a17:902:5601:: with SMTP id h1mr18871105pli.160.1549570376286;
        Thu, 07 Feb 2019 12:12:56 -0800 (PST)
X-Received: by 2002:a17:902:5601:: with SMTP id h1mr18871030pli.160.1549570375343;
        Thu, 07 Feb 2019 12:12:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549570375; cv=none;
        d=google.com; s=arc-20160816;
        b=JhhVgNycBROF2/XPjxIK5feQ/r3W2wCZumTt1ILNxm/kkl22NQ79f1USUCbLk5Xtl9
         NuDCI5c1NkRuTTX/wdDKiwyyrWIlAolfLiSAotYmINk/wO50HVTf8Y9927Ka8re/ygmI
         4HKJT7x4ixTFpIW+gheq3gMHeux5d4QCF3XeyZ7RaDVDM3EIHIqviquWEcVoJeRPNpq5
         sfSVouZtWDxv/pmLagMKtX8httE8w0LW0/oMckWgaqBJhUPhMPABuPLJEwhCOlgDtOXg
         JCDjl3AckmrXTJU6DWb+5YKMVL6HuQtGuV6jPr43mv1rHLKv6gsZ9VmfqS9B+e6rqRlj
         Nhbw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=i3o0Wtmju3HWlOWRjY87xJXCKZCTQhmfuSMisLTGU9Q=;
        b=q70hzcSaemXuVicbv7Hkth6TCp1C4h4JR1z6OUD+V22LE661CNt0+yYXSecierBiiZ
         SKWaWWb+opsDmYxOi0y401qWTNl4XTF3JdNFDqHbxPX4Rur/LKfpP6fqr5hkVCyrW0fK
         A1jql1IpqVTSW+HobPa+nqWswFCsGtGM9ZgJSQbcrAz4qcVPCquC1QnVzGJS8Ux76un5
         MXJzulqYEZ95cidOg+w0cnYTN6sU211GU8qyBFfqJvtwHllYexDIDhoFHWxXhQ/zU8gW
         SrHKlt02vZFG6q1qygCyl7s9rL4dd2cpVaxHkETm+uEB+2xkX6e03WM7XoANsmtkyoHf
         MHdA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=d2P+Grqs;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d15sor15204813pgh.86.2019.02.07.12.12.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Feb 2019 12:12:55 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=d2P+Grqs;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=i3o0Wtmju3HWlOWRjY87xJXCKZCTQhmfuSMisLTGU9Q=;
        b=d2P+GrqslJzvgdlnz6Eav1B+D7I/m8xscyn6kTTJLquPa0IY1GfVTrofH3r1PpWpZd
         vCo+0N+4bTCIYLt25+EFFnmPQTE/UQ69kiIz2AcT2ZEoCh6R3rU5K2mIqdfFC8wlHtGj
         UnwLzL/lJJO/K6JbILjo7a2dvOxUd4s+Ut96LkvCa99faWZnJRCkv9NOa6nDSKkkomJb
         w7ci6Mtgai4+AFaKOT3AL9z5miVuaZtUXLoEI/2QAmxXZ3aBWLiIjkl1Zkemz7sN/bS4
         oupTqM5/m8AWEZgSt8D+PaTtPGYXzaTmFnbgW+nBXEovDTtl3dBqowDMSGhQplyhiX7D
         MzFQ==
X-Google-Smtp-Source: AHgI3IYm3LSwAFPA/+TRnAO4YDxgSO58WBSy8EHqyXqyWTpaU/2l37yGeO/u9pjsH4R1atqLl5oYLQ==
X-Received: by 2002:a63:4744:: with SMTP id w4mr16295126pgk.110.1549570374762;
        Thu, 07 Feb 2019 12:12:54 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id i74sm6113693pfi.33.2019.02.07.12.12.53
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Feb 2019 12:12:53 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1grq2W-0007mg-QT; Thu, 07 Feb 2019 13:12:52 -0700
Date: Thu, 7 Feb 2019 13:12:52 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, dledford@redhat.com, jack@suse.cz,
	willy@infradead.org, ira.weiny@intel.com,
	linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3 0/6] mm: make pinned_vm atomic and simplify users
Message-ID: <20190207201252.GA29842@ziepe.ca>
References: <20190206175920.31082-1-dave@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190206175920.31082-1-dave@stgolabs.net>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 09:59:14AM -0800, Davidlohr Bueso wrote:
> Changes from v2 (https://patchwork.kernel.org/cover/10774255/):
>  - Added more reviews for patch 1 and also fixed mm/debug.c to
>    use llx insted of lx so gcc doesn't complain.
> 
>  - Re did patch 3 (qib rdma) such that we still have to take
>    mmap_sem as it now uses gup_longterm(). gup_fast() conversion
>    remains for patch 2 which is not infiniband.
> 
>  - Rebased for rdma tree.
>  
> Changes from v1 (https://patchwork.kernel.org/cover/10764923/):
>  - Converted pinned_vm to atomic64 instead of atomic_long such that
>    infiniband need not worry about overflows.
> 
>  - Rebased patch 1 and added Ira's reviews as well as Parvi's review
>    for patch 5 (thanks!).
>    
> --------
> 
> Hi,
> 
> The following patches aim to provide cleanups to users that pin pages
> (mostly infiniband) by converting the counter to atomic -- note that
> Daniel Jordan also has patches[1] for the locked_vm counterpart and vfio.
> 
> Apart from removing a source of mmap_sem writer, we benefit in that
> we can get rid of a lot of code that defers work when the lock cannot
> be acquired, as well as drivers avoiding mmap_sem altogether by also
> converting gup to gup_fast() and letting the mm handle it. Users
> that do the gup_longterm() remain of course under at least reader mmap_sem.
> 
> Everything has been compile-tested _only_ so I hope I didn't do anything
> too stupid. Please consider for v5.1.
> 
> On a similar topic and potential follow up, it would be nice to resurrect
> Peter's VM_PINNED idea in that the broken semantics that occurred after
> bc3e53f682 ("mm: distinguish between mlocked and pinned pages") are still
> present. Also encapsulating internal mm logic via mm[un]pin() instead of
> drivers having to know about internals and playing nice with compaction are
> all wins.
> 
> Applies against rdma's for-next branch.
> 
> Thanks!
> 
> [1] https://lkml.org/lkml/2018/11/5/854
> 
> Davidlohr Bueso (6):
>   mm: make mm->pinned_vm an atomic64 counter
>   drivers/mic/scif: do not use mmap_sem
>   drivers/IB,qib: optimize mmap_sem usage
>   drivers/IB,hfi1: do not se mmap_sem
>   drivers/IB,usnic: reduce scope of mmap_sem
>   drivers/IB,core: reduce scope of mmap_sem

The surprise 7th patch was mangled, but I recreated it by hand

Otherwise applied to rdma for-next

Thanks,
Jason

