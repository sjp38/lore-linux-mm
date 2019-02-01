Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 757C0C169C4
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 02:34:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 10D1720855
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 02:34:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="Ot1JRQLY"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 10D1720855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 703778E0002; Thu, 31 Jan 2019 21:34:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B2368E0001; Thu, 31 Jan 2019 21:34:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A1B78E0002; Thu, 31 Jan 2019 21:34:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2FD978E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 21:34:48 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id 42so6098790qtr.7
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 18:34:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=ap47YqkMD41XNgwtc6/MM0TCsDj89dwy3qzdIs8s5c8=;
        b=b8JcrhGs4/ZTyPypXecSHAaxRC4nlyMAaaLDsBNEnbSQjj51rG8126OWs2Z4NzG/5x
         EJ50O00THJZwR3KDSZ9o8T5x0qVFRq9dGtLgyp2IV824PjIJJsKGGp75whBkrsnIWpbI
         zi9XsTNrxPb0WVW/689Edd1H7Eqx+VktNnLmjqLrb6ySH+2YCXyMkH7vMFlw3uPYMVbH
         fPvWx359f0JRNtoLDe3g1Qvkt6Otz5S7gzM7wKiGFNolMLj9AO5NZac520V/bQoCQlJa
         6DSKmMD3txGHod9Fe94KGutoXJ0MZyXCikx/z9dfba7/+h5wNzwO0YPt5eLb50Za3j8u
         89mA==
X-Gm-Message-State: AJcUukcBlHFmi59xad/7aVyqN/6eq526/c/mj1DzexsvxSTdXGM2hSyZ
	ME5g+h7BZVCTCJAsNBtukKIPTEspV/fUbjzyjnul+MdKoClzmweHvbpxJ2kcdV1qX7AkQd+PZ7r
	5+zqzTLyn36kwELBsx9UFPjzbkf2rm26Mwkh7S5d25V2xMmH7XTPrl0QPoZKXXzQ=
X-Received: by 2002:a37:b842:: with SMTP id i63mr34430143qkf.69.1548988487957;
        Thu, 31 Jan 2019 18:34:47 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6YBq22vfgU5Siw50c6nfI1Te4ap9XLFJ1MRWWJfV8TB/M01WAL+C+CKGxTdw8VUBEETOPw
X-Received: by 2002:a37:b842:: with SMTP id i63mr34430119qkf.69.1548988487325;
        Thu, 31 Jan 2019 18:34:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548988487; cv=none;
        d=google.com; s=arc-20160816;
        b=tZI6Ve5lG1Oau2hbejlW2eTSfQyll7NTVS03KkOHBi2fvs9+0GNkVVmL+IHLIltBWy
         ZaffuQI9nD6awaUktH1EutFuL7+ItSd3Es6oSwYnAGiC/Hr1Q1GLQCpZgPuSgESQzCjG
         K1Cq9EQ19d7lFdHHvEtT+d3BhrZwXJiANVlHGO8XoZM/WSnuMA/Ahj055Z1wkWK+Dm95
         w0czJ18JCBmAGZ0hBRHtBt5Z4Wsxxr9ir56TIkpgSuSTbhqiR+NqMXanpLvA3J6SmrbV
         uNurBpeBlvpTGnScY25ZVFOCeFfuHKgY4WhQtNd1tZ1xnG5tx9XzmeH2cyAWYoXnwilT
         LtJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=ap47YqkMD41XNgwtc6/MM0TCsDj89dwy3qzdIs8s5c8=;
        b=HLeMppYhUX9IBxj6D/XzD1ORlRQ3MOMEWUBGI09o363ThXIahqg+peZ025bBEPapgL
         AeZwyEXkcbFcrTKnisKOTZ5nkfrJa427nXR5QDg9gD+a4sX8BO/6Kp5khp79hPMCj/tH
         jaWnGRqEVv14NgPZHF4UJR240bv6d44xuL3HEa/cM5yGANwNA08NAVWCwsPG4SxEQIaU
         pq3HwP4IYVJF8Xc2B9iE76kUFXKVDR98CmHsBMshKuKU8gt+l/8/edgdGomHw6QazUXX
         pPfaE2+HK7G1eSaWoLIy3vhjszZrDSO7e4XBdj9T4kvayyWorKbaS25r78hZb54+ew5L
         onOg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=Ot1JRQLY;
       spf=pass (google.com: domain of 01000168a6e8944d-b8e72739-2611-4649-a8d2-304b98529b7d-000000@amazonses.com designates 54.240.9.46 as permitted sender) smtp.mailfrom=01000168a6e8944d-b8e72739-2611-4649-a8d2-304b98529b7d-000000@amazonses.com
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTPS id b2si636160qti.171.2019.01.31.18.34.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 31 Jan 2019 18:34:47 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000168a6e8944d-b8e72739-2611-4649-a8d2-304b98529b7d-000000@amazonses.com designates 54.240.9.46 as permitted sender) client-ip=54.240.9.46;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=Ot1JRQLY;
       spf=pass (google.com: domain of 01000168a6e8944d-b8e72739-2611-4649-a8d2-304b98529b7d-000000@amazonses.com designates 54.240.9.46 as permitted sender) smtp.mailfrom=01000168a6e8944d-b8e72739-2611-4649-a8d2-304b98529b7d-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1548988486;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=GQG+fGJgX62Yh7Aovoer22fTd1EYeth0253wwis/ybU=;
	b=Ot1JRQLY1t5HLkohdl+kAWmNK2IJb1fnTVJJwtPo77WILVS7MeO26vryyDIWopuv
	JN/k1cC4dmt4I1nY1lGRh4QzcmBgDczc1JHqzYIlTNBs3I93kuq6q4pg9Uba8ilsKrf
	ArcCOLEgNXHDqgbb7s/QFEgxHtNokZbXYLFwPa+A=
Date: Fri, 1 Feb 2019 02:34:46 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: "Tobin C. Harding" <tobin@kernel.org>
cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, 
    Joonsoo Kim <iamjoonsoo.kim@lge.com>, 
    Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, 
    linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/slab: Increase width of first /proc/slabinfo column
In-Reply-To: <20190201004242.7659-1-tobin@kernel.org>
Message-ID: <01000168a6e8944d-b8e72739-2611-4649-a8d2-304b98529b7d-000000@email.amazonses.com>
References: <20190201004242.7659-1-tobin@kernel.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.02.01-54.240.9.46
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 1 Feb 2019, Tobin C. Harding wrote:

> Currently when displaying /proc/slabinfo if any cache names are too long
> then the output columns are not aligned.  We could do something fancy to
> get the maximum length of any cache name in the system or we could just
> increase the hardcoded width.  Currently it is 17 characters.  Monitors
> are wide these days so lets just increase it to 30 characters.

Hmm.. I wonder if there are any tools that depend on the field width here?

