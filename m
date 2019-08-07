Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3E1AC32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 20:10:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F90521E6E
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 20:10:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="afz14CAR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F90521E6E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F3886B0007; Wed,  7 Aug 2019 16:10:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07CA46B0008; Wed,  7 Aug 2019 16:10:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E5F746B000A; Wed,  7 Aug 2019 16:10:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id ABAB66B0007
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 16:10:31 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id d6so53888051pls.17
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 13:10:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=v7Yn28bZjwjyS2wTpAsPSZ8rrKC98YMZy1/3poQ2pFk=;
        b=JKJrcxjKpNUXywLzo4reRy6yg/cJKdp3IwBYnxYq7C49AZW+uCkDOATkVdO+oOH3IC
         Lxmi2E9GgHQyRIO7GXHMpi3bAUdFkI0ozfsqyOaixVNyRvl7sl3IAwfthi+aO81rFRdS
         VEXDYzsAH+z9G+2eAeTPOa3rKyCVsPvlMY6NyGw3elK8VLEi56+JXpmjONrHlQPOFhMO
         LjhTil9CPW8ATqVRv7fIVNHOLaH8arK4uA3DiqSkK0fUi3bI/R2ZRCnzSOhNHMXCdigh
         Mw163s8jWH8BKwO/vHwTrBz1tKAhHDNSt9hgObgyXny8ycHeIspA+g8MPpMDC1u0tCB1
         9t/Q==
X-Gm-Message-State: APjAAAXDJNMvJ8Bn1HHaI+uJofXO5MJ47hwPGeVz74U+jP/GY1EvF/kd
	MvKrhI+BWMQVXWdHpk0C1RThpk/QZgGJb79M4TZzfOX0PuROwqo87qpnliA+2+JW67PPV5ESKde
	BsbnD3MfB9GiL3f8ZRow/usnj+OoTcJydpEEG+/NsXfRb+4M4cDTJFhxkQ7NZR35BOg==
X-Received: by 2002:a17:902:704c:: with SMTP id h12mr9337099plt.318.1565208631263;
        Wed, 07 Aug 2019 13:10:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzg5X+Afr7g0xTZx3Z9cHCaMzAaKw4Iuqau5OB++/Nm+T7D1Z0vLeyU71Q7hkia5ddgdkvc
X-Received: by 2002:a17:902:704c:: with SMTP id h12mr9337048plt.318.1565208630575;
        Wed, 07 Aug 2019 13:10:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565208630; cv=none;
        d=google.com; s=arc-20160816;
        b=Q/w8E8Za/Iltm5onb6j/u9IhJL9z5GJHOhmGTwYoqOOYllgL68bvdqJ53qq6rAYAVx
         rSszSfxFjKtnlQl9Fq4V89bEKRiYfpzzC3EQIGIgVWPfTu0s0MyIDfkFeARV2Q0noUi7
         1Gul+j/CWSXSodUfXGobGGHE9sq8UNElT0rHALGk76HMEPPA08TA6VyhVvJoDFnfAJYj
         /Xtsc5sdUbkqnVP7vHHdAnUUGACzfeIJgYJyJ+18wmpima84iIF24HQyIoA7rE5zT/Cp
         e2RziYEX3c3pTNOqlHupMUed5XARpIleZ7+qdaXC8um3bowPkfcwwgFt0E+g+/OZjnZV
         8HLw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=v7Yn28bZjwjyS2wTpAsPSZ8rrKC98YMZy1/3poQ2pFk=;
        b=SMytd0xDZu1oTJn0y5U2KauEOqW9e2NedpxFa9jTdifk2z/lyE4c5R+FIqPGCLKU/j
         QNJVL48sLdHHnhQQ14UpsnsQ+fjkCLPH/bQIbp0fbDidkIh/ET1BGl5Rr1pQoVsYr12o
         6i85GY6mLG6neMLcvaZbYAE56tHCMC9C0Oql3BEySRYaOSncuT8T5iutAndsAm+lL0Fg
         9ckNy3ZaFSqxsdgRxDUJmHKKAIh4tigGRFPUsdlSBXX7uraVOqZPn6rVI8Y2SGePxFo1
         XVfggI+pbc/Beu9x7wMcQvKrACL4v0w+1n1wmbXsoqsfEeMUr2OZ7d8j8VQSpa347O3D
         BOpA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=afz14CAR;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a17si52672800pff.195.2019.08.07.13.10.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 13:10:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=afz14CAR;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 04C1021922;
	Wed,  7 Aug 2019 20:10:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565208630;
	bh=Jx7y/Ln14SESvaQs28ji2Po6nmIukoITtbZFc+CJc+0=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=afz14CARnD4KLD2Z5M0+ZTfbOtpHoXYlolGDnDkCNGSkIWv5zbksHxBVq/TE0vpoO
	 ATEyB6ZOp/MmuNOpdZ2f3Q5WKgAYPaN2KpyqOCBnvEJrYjfDqmRDcgfShQN1aeYPyC
	 6Rbexj2erKrr2x2qb4cEdspf+G4+gdgiWdtMeVJA=
Date: Wed, 7 Aug 2019 13:10:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Song Liu <songliubraving@fb.com>
Cc: Randy Dunlap <rdunlap@infradead.org>, Stephen Rothwell
 <sfr@canb.auug.org.au>, Linux Next Mailing List
 <linux-next@vger.kernel.org>, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>
Subject: Re: linux-next: Tree for Aug 7 (mm/khugepaged.c)
Message-Id: <20190807131029.f7f191aaeeb88cc435c6306f@linux-foundation.org>
In-Reply-To: <DCC6982B-17EF-4143-8CE8-9D0EC28FA06B@fb.com>
References: <20190807183606.372ca1a4@canb.auug.org.au>
	<c18b2828-cdf3-5248-609f-d89a24f558d1@infradead.org>
	<DCC6982B-17EF-4143-8CE8-9D0EC28FA06B@fb.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Aug 2019 16:59:14 +0000 Song Liu <songliubraving@fb.com> wrote:

> Hi Randy,
> 
> > On Aug 7, 2019, at 8:11 AM, Randy Dunlap <rdunlap@infradead.org> wrote:
> > 
> > On 8/7/19 1:36 AM, Stephen Rothwell wrote:
> >> Hi all,
> >> 
> >> Changes since 20190806:
> >> 
> > 
> > on i386:
> > 
> > when CONFIG_SHMEM is not set/enabled:
> > 
> > ../mm/khugepaged.c: In function ‘khugepaged_scan_mm_slot’:
> > ../mm/khugepaged.c:1874:2: error: implicit declaration of function ‘khugepaged_collapse_pte_mapped_thps’; did you mean ‘collapse_pte_mapped_thp’? [-Werror=implicit-function-declaration]
> >  khugepaged_collapse_pte_mapped_thps(mm_slot);
> >  ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
> 
> Thanks for the report. 
> 
> Shall I resend the patch, or shall I send fix on top of current patch?

Either is OK.  If the difference is small I will turn it into an
incremental patch so that I (and others) can see what changed.

