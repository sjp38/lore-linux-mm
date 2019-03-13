Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 629B9C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:01:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23277213A2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 18:01:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="PbNod2a6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23277213A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2D9E8E0005; Wed, 13 Mar 2019 14:01:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BB6B08E0001; Wed, 13 Mar 2019 14:01:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A59288E0005; Wed, 13 Mar 2019 14:01:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 61F1E8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 14:01:46 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j10so2231548pff.5
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 11:01:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=FLtnEhcZitgPrumTgx6A1mOi4wgkfJ/JfwJzueYQV10=;
        b=qZS57fF73igpEDAB5aXjoOko0SIiMvntbeqe3n65yVbKvOO81fNzSENdPwy9IkczUA
         nts70lBIEpLP5jiux6v72DENUonUguGgd4XXeR4A/3qyfPHxSjt7TGAx6US65MBeYkJW
         cZwQ9ik7nxk90qZlPicy4+3oxW+Iw9FjDrNeMiV5Ru3JrLYN3TdlqiBR56+a+vxZw5HY
         RKEwpvWYZxjKlsKlXo/d92mfiv3xPL8nJEP6fhjBuKby+hLN6VVFm877NQ+X5QAHO7sE
         06ZrN21yJMg7HV/O4dv7WYHiMw0dIbkWvyK+Q4e5WoMTWm4NGRQclY57eGTS7qc+rPRP
         f+lw==
X-Gm-Message-State: APjAAAX8gSI6e9RYvmvCcGR/62YeVAYNDbLQVwRG6MXq26munUTQbBpA
	IY+V79eSzDOnPk9f4t08yfk02ayDNPxEmvpP6kyOSsHUs/dLyqNfzfcx3KtcS88IUPStYjPwS7H
	rFh6y8r1Uz2fE5dpoJXXElWbzqwoJQ9nHF11v7lCedhiQ3YZbHFk39kW1doq+hGXetw==
X-Received: by 2002:a62:5e46:: with SMTP id s67mr45102130pfb.126.1552500105887;
        Wed, 13 Mar 2019 11:01:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxoNmoUWJX5ikmoCu5k0ahqnrr6JnFQ+DQcBuc9+Wd/eQsfgPLhEGRSKG+wtefbektZ/UUl
X-Received: by 2002:a62:5e46:: with SMTP id s67mr45102052pfb.126.1552500104981;
        Wed, 13 Mar 2019 11:01:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552500104; cv=none;
        d=google.com; s=arc-20160816;
        b=k2V19VGK744sEDsF8pMMbX/R1UO4Sjby0JPXQe9bINIjXl+Bd9HlGG4XkSx+f3hI8A
         hk8lvxw5UStf1/dLEGi+lRzQZqYySwBQjay8U8U8RkclDZoXQiwNpOXeCisI9Xos7nSQ
         5bA3mkjFXsqsJif6R20A0/ngsKXEEqnyeCU9e34PFEmUJlCrmiAeDE/hg5rumpzhrTFw
         Wy8BY7+lYl2wQp50DkIgCmn/ldl7Lxh/E3PVPNSFThBxYetjZ+WJKLiXb/6siQzvWtOn
         T7pCGiRkNqdfeD9jFMqzSZnGnzs5dT5kPvyxjrAjuPgdHlLbVrDpStVC7v25TsS70t3+
         LmnQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=FLtnEhcZitgPrumTgx6A1mOi4wgkfJ/JfwJzueYQV10=;
        b=y5cVVB/Od/l5HDAXC4mBX2j7VF96tzeY51FCnl5DHuFtilMhiBZAh4uMO6G4G3ASru
         1CMs9SfyQA+P5w2IOU42yj/U2Mo2WmLzrLoLDRlkIQhxM6RgkO1jfw4NgA29mCh6E4v3
         uorSxyXLQ24V6HEa8a+txF1LMPKUWVBilvNK49c+zYpekK4LHNCtngwK9XtUd0yFwH7U
         SZIclKlhlj9Z8MRpnwZ9FNxEdGfGMvnIaHSN0o50OGEULnEiNglhA2NHW0x/QoLC+rNd
         6PhSe5+XgOlnPAOva7oDsGuRjhe03HtwdgARDGC/sP0RgLnEfkAx89jCwcja8P1XnCCb
         RXgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PbNod2a6;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x21si6418330pll.75.2019.03.13.11.01.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Mar 2019 11:01:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=PbNod2a6;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=FLtnEhcZitgPrumTgx6A1mOi4wgkfJ/JfwJzueYQV10=; b=PbNod2a6s0twimut9yz4LCuuG
	3Gkxl2AugBv1zrAJBE2wrCq/aw6tUjEciElAs2Nv0Z88sh1Eed8kxDyRCrbrsEAS+LiA2gUwSBmyH
	bZTbGpAx15k1rx6tkVKl0aLfnwJrWMKAmJh5GZaAWI5QGFY+Dks2ss7DT1cFoEHodWNH7MWUFi3XF
	eFPenKgy/SJSph/gqVQlBkszagqB7svzNjQy5Mt5XYtTCbE/svYZQfC6KtBBhAjbcKDUNN+Tto4HN
	h7VSmL9pOJFpT4QT2e6gaU7/owcrnfk9q59XmTbDltmoJRJ1KMEiryCyzNUtMMnGptq5rY6WqZzWo
	SDddJUKgg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1h48CF-0005k5-Cu; Wed, 13 Mar 2019 18:01:43 +0000
Date: Wed, 13 Mar 2019 11:01:43 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: lsf-pc@lists.linux-foundation.org, Linux-MM <linux-mm@kvack.org>,
	linux-kernel@vger.kernel.org,
	"Liam R. Howlett" <Liam.Howlett@Oracle.com>
Subject: Re: [LSF/MM TOPIC] Using XArray to manage the VMA
Message-ID: <20190313180142.GK19508@bombadil.infradead.org>
References: <7da20892-f92a-68d8-4804-c72c1cb0d090@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7da20892-f92a-68d8-4804-c72c1cb0d090@linux.ibm.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 04:10:14PM +0100, Laurent Dufour wrote:
> If this is not too late and if there is still place available, I would like
> to attend the MM track and propose a topic about using the XArray to replace
> the VMA's RB tree and list.

If there isn't room on the schedule, then Laurent and I are definitely
going to sneak off and talk about this ourselves at some point.  Having a
high-bandwidth conversation about this is going to be really important
for us, and I think having other people involved would be good.

If there're still spots, it'd be good to have Liam Howlett join us.
He's doing the actual writing-of-code for the Maple Tree at the moment
(I did some earlier on, but recent commits are all him).

> Using the XArray in place of the VMA's tree and list seems to be a first
> step to the long way of removing/replacing the mmap_sem.
> However, there are still corner cases to address like the VMA splitting and
> merging which may raise some issue. Using the XArray's specifying locking
> would not be enough to handle the memory management, and additional fine
> grain locking like a per VMA one could be studied, leading to further
> discussion about the merging of the VMA.
> 
> In addition, here are some topics I'm interested in:
> - Test cases to choose for demonstrating mm features or fixing mm bugs
> proposed by Balbir Singh
> - mm documentation proposed by Mike Rapoport
> 
> Laurent.
> 

