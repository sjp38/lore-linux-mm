Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79A62C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 18:02:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35AEB2070D
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 18:02:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="iyFuHWDl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35AEB2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA7928E0126; Fri, 22 Feb 2019 13:02:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D553B8E0123; Fri, 22 Feb 2019 13:02:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C44B48E0126; Fri, 22 Feb 2019 13:02:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 946318E0123
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 13:02:45 -0500 (EST)
Received: by mail-yw1-f71.google.com with SMTP id i2so1854480ywb.1
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 10:02:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=0U6oTt6/Sgt3Nu8PhIORM2GAgTzgiX+4PSRFp/ODm9w=;
        b=qFXqQ6aUlg5VrjhdQaOCc0NWJdYwQqJ7VdINJSbk+nRAuBA9JvqaK1deJExvcC86r8
         XJ81Pvb2RI2ZZIt76f8GJj+wAWIFgsxArBRLQC30DuMFLWkeIOqgryUG0a3LcfAOHkmT
         Jfy3MHX8PKKHaDBGKhVxRlR/UAgjFZuUGnhGwUgd2pbFeN7WjrZoe3dm4MaXGSpT/oln
         EV28kQD5G8PLfEvu9WmhGpdHVy9eauMgkXlm1jzuFq4el36laxPiGkE+wnJpaOjG2FY1
         IB+PYPegvqYZlniMn456Q6RWWOjzV2K1sadAuosODY0Hs61qqdnc9Hqz2eKDKbhowBaw
         Dd5Q==
X-Gm-Message-State: AHQUAuak4f02TxJ8XODTuqXtdVL3DfwJSHQFT6OUS4sltXupslBXTfhX
	GIvZ+SeTXDTb/q/7AaycGbZ8jaDyRx4qjKMphhpVTxx0eprbA0zrZzPNIbQJuyIgsaTEJw5e1WH
	drT4r0/VULZhC4sLt5bO3sPNwGvpLeQNsSy7D/InU3uVIMlkj3qfr1uuerS0zI1wN5Njhp8bqC5
	JpP6mK+r/wKggPh21UEEaBoGuz5nsLy0am/TYtQTuz2USNE11mSSDAHErgD3E8N2jwnanBu8Gvh
	ENVFk7kL+r4Jrw2e6g0bT8/MZtZonCOTiCKoXhjHRCeqM2dKh75Yt9qkmLySCBCyDMwyUDCIn45
	9gvuAbScYy/IKgCQj35hNdth7BSRwgSO10LuKFRRSQVeY5PiHI99bPOLKmb9e2mWZZCuS5rIW+z
	w
X-Received: by 2002:a0d:dc83:: with SMTP id f125mr4414271ywe.67.1550858565322;
        Fri, 22 Feb 2019 10:02:45 -0800 (PST)
X-Received: by 2002:a0d:dc83:: with SMTP id f125mr4414217ywe.67.1550858564706;
        Fri, 22 Feb 2019 10:02:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550858564; cv=none;
        d=google.com; s=arc-20160816;
        b=Dz+93mDIi8ELCZzI57xuk8jDhDhFbw2AnWsqzzDVAOmcFV0sdI4qHt7iuZlajNgsY3
         nQmo6VwsCWj6iY7xx8zPuKq1hwft5atoTH0VeR3T9iH1lSwXntPO7GLDe/z5hVN20f2Y
         7s41tim1MpNeWObYAWmcmNTQrTeDVVk5tvnS+/RvNWKisCUPhMqup3HeJNPDNcj3Mhmn
         3Q8LFQ9vW8Dx3zr3wNmPVkZ4Kk3G0nJLuGu9FcrrSxKs+lXXG9GrVul0zAU5U9Rq7KLG
         3SfXfdKYSf1PudeUWI8MCb2woeGDIv5u5pCbd6QiRu5yOhszgC2Dy59LzJtSi0e/ZTFE
         STsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=0U6oTt6/Sgt3Nu8PhIORM2GAgTzgiX+4PSRFp/ODm9w=;
        b=tpEXZvQ/z2NOziU+PhWDpDmpEXa9D7ZTMYiyxY9r6z4yuXgs6eJ3UtbAGk6VPMoSYC
         D22CInNTFUUNHiaozdXoFCX8IIt1scj5QqdwOyefqZWlS5BrJvKf8BgRXxDHi4n1YnSD
         9HyZmzyug8wyH3SQ29My9IZq+2QCLV02yGd5GbVtTyXm8DRRSYAx/O/RmO4pSPom1VDl
         qhxDe6RRBFzD9fa2h41Swue2lYMMofmhDGY3zR+vveURKdE3RhmHnJDWuEtajyvZRX8A
         NSShCrk/+aWHSapXZuWsTyhfcNcTTTa+3qX4yH6i9v3HNtUUqr+BiWk5E9iLYCyN/K3G
         0SbQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=iyFuHWDl;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 203sor1033337ybo.30.2019.02.22.10.02.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Feb 2019 10:02:44 -0800 (PST)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=iyFuHWDl;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=0U6oTt6/Sgt3Nu8PhIORM2GAgTzgiX+4PSRFp/ODm9w=;
        b=iyFuHWDlZUT6BHswFDnmTxhNU0raC8a7XIB12MC8QKlcuG0i29Eko/N6xrRgmZhypz
         LzL7PwhcUg5WeOv4PmYSIm/a4xFU9fqzpQuZ+6TGQB4L5QVQuHDWb0WPjw4j5hSaJoZI
         2fh5xCEyOOTgAo6sULalA3UKqhXi4emKCz5ClnGTiHTbAYAOufVjzcim5x/p/w3thZP8
         QGF2wlV8lLS4DaAHe0rGFwH52eL5gFu39FZfRHtMs4KHdDgZ1JzpkYglcp3w5JAnlfxz
         RzJs0lcG5jVZlUx4KzBOPJlRaD/uNZrFRYl6UgALCxZkLkv31Fw19+r7UGPd2zNNvcAu
         BP5Q==
X-Google-Smtp-Source: AHgI3Ibd/MTh5Q9gpkZz4igQpyJRmfcmB3hfLK858GyyaSg/R4wG5men+PZAksxMchFTM+ZhHLgURw==
X-Received: by 2002:a5b:34c:: with SMTP id q12mr4340807ybp.473.1550858564315;
        Fri, 22 Feb 2019 10:02:44 -0800 (PST)
Received: from localhost ([2620:10d:c091:200::1:cd3d])
        by smtp.gmail.com with ESMTPSA id b7sm876522ywa.86.2019.02.22.10.02.43
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 22 Feb 2019 10:02:43 -0800 (PST)
Date: Fri, 22 Feb 2019 13:02:42 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@surriel.com>,
	Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 4/5] mm/vmscan: remove unused lru_pages argument
Message-ID: <20190222180242.GB15440@cmpxchg.org>
References: <20190222174337.26390-1-aryabinin@virtuozzo.com>
 <20190222174337.26390-4-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190222174337.26390-4-aryabinin@virtuozzo.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 08:43:36PM +0300, Andrey Ryabinin wrote:
> The argument 'unsigned long *lru_pages' passed around with no purpose,
> remove it.

The reference to this was removed recently in 9092c71bb724 ("mm: use
sc->priority for slab shrink targets"), might be worth pointing out
for context.

> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Rik van Riel <riel@surriel.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

