Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CD572C04E84
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 21:50:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CB7B2168B
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 21:50:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="tztgk972"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CB7B2168B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1BE466B0003; Fri, 17 May 2019 17:50:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 171846B0005; Fri, 17 May 2019 17:50:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05E416B0006; Fri, 17 May 2019 17:50:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id C36A06B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 17:50:52 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e20so5356389pfn.8
        for <linux-mm@kvack.org>; Fri, 17 May 2019 14:50:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=W9V/3UBp+GSgeFDmhmRCiL7YCna/nftCLnGT9igKQu4=;
        b=Du28DoFV3Nrfpt+lmo7AqqF/zYi4jzXNwlsCf3hUUzTBSLglnzeUFTk1C6DHgkhLL4
         wwPz/Dukr9gwpO9x/8bguOFvhdj2cxq8+M4kIzLSXn1LuM4a5YIi13cEiLUo2jw+cw6n
         T1HBT0wvq+wDhAo7vTADxckKqexRwxZX0mDC3Qd7bQligrJxm9e5FTG2+z2ZN5Pr2fSv
         XhCiyGY8gpcrXwCgvUTlUbCkAFiWhnoyOwPWO5XctNXwojESUQ/qw2haYDlqmdSpj+hP
         Op2teEalKWhSOPXvcwneaF1NzsEhu4/w82nIt6gIM6xvRyf2lLxlsqeoLsZdS+BDI37Q
         4wCA==
X-Gm-Message-State: APjAAAUjeISBsfsRS127rj2TniTOxaPxTMlEgjdLWdAJxJYelZN3k7Gz
	pgv57vrDtE4JBqc7W3de2xLXoYEgTPOuKppRf78j6T2FTJ06RXM8fnLM9ykK5LD8r9l/0bTP7q4
	UHSKdDakGH7UC5hyIHowGlqGW3y2Ak4EZJLdXYUfEPr0Sc2z/X/IYiXPzn1peBM0SxA==
X-Received: by 2002:aa7:998d:: with SMTP id k13mr50770572pfh.217.1558129852378;
        Fri, 17 May 2019 14:50:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwbzJNVZq7PxkYyAcMVZg1XXWPwWzXx5pLarWZDqb6m67bVbEmnVB/upQOiqVxfn7wijQM9
X-Received: by 2002:aa7:998d:: with SMTP id k13mr50770505pfh.217.1558129851702;
        Fri, 17 May 2019 14:50:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558129851; cv=none;
        d=google.com; s=arc-20160816;
        b=z9jfifi0T9iU1lkVedM9Es6rW9GhyX+fbuhxjm7B2uvanvEbjEi6qVW30y0A3/QnfT
         EsdI7e3MLprqus5pRNRiW61ZBcLst1yM5TpoyADBS1g8BU0IZB9hpzwN9zdmZZpDCqUp
         RlT3yy14HShbddrw/fXyFpOcHEqaSCqLBWC0W853pY7XiUyU7Wjfeo2H41JcG+2uulZJ
         iFqtIJQeKm7a7jyMpjVm+U2qVOlLDVg+Esoxk7awe59Mo6oVh5fklu8dBY+2g56fWN8H
         27R6IhfnkPxvNJA9Wly/W1DrX96I86eP7We5IemNsnagpasZahTLHHf7okfy28LplIwV
         nKnw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=W9V/3UBp+GSgeFDmhmRCiL7YCna/nftCLnGT9igKQu4=;
        b=G4T5Pfg3uX96xbsQbkA4sCpoNDKHWfWDVpYOSu/hhG+xpA3NboEimIRD/cb4gSnH1i
         zftFnnTBL8iw7SzgYLkXXTyAWHZB6b1eOOO/TUxf69GeuJR1zlcdmLkursMQomfJfpAN
         RH+z33q5VQlFOffeMOjo+PaKrtRcRLsBgryszxGYSinXRmR2VcBmR6oGP62ufdeEcaPz
         btKy7ErGKLvcs0G+vanZivYBBx+UdTrJU7PXoCBVaByQPIWxnpAEtzId9PQ6ZxPkkige
         QbnifSPNZeZRbW8OPrPuKl2QLfn6Ignj8rscLM4BIiM90Ct7YDjp1Ji5g7VhOmo77SW1
         15mg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=tztgk972;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 24si9041603pgt.474.2019.05.17.14.50.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 14:50:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=tztgk972;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 1AACD2166E;
	Fri, 17 May 2019 21:50:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1558129851;
	bh=XAnihnyM8tPVIS0duJIIenhFswdE2ITYujhIk4/YYXE=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=tztgk972S74ZcA0fIcYynWU2LA6EGW/8HyY1lB7Z8Q+uZTYmr5mdXyxHJCz53nGPN
	 0LRMAq2ZvAahbXimeMA4ojr8ed3jGYLdSUCeY8iDqMbVa2nQtEjkF+MxliNjSgYj93
	 QqElp0UTIeYT/VIePfTOf4ZQv7nK+VAlzZryhb1c=
Date: Fri, 17 May 2019 14:50:50 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 dan.j.williams@intel.com, jglisse@redhat.com, ldufour@linux.vnet.ibm.com
Subject: Re: [PATCH] mm/dev_pfn: Exclude MEMORY_DEVICE_PRIVATE while
 computing virtual address
Message-Id: <20190517145050.2b6b0afdaab5c3c69a4b153e@linux-foundation.org>
In-Reply-To: <1558089514-25067-1-git-send-email-anshuman.khandual@arm.com>
References: <1558089514-25067-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 17 May 2019 16:08:34 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:

> The presence of struct page does not guarantee linear mapping for the pfn
> physical range. Device private memory which is non-coherent is excluded
> from linear mapping during devm_memremap_pages() though they will still
> have struct page coverage. Just check for device private memory before
> giving out virtual address for a given pfn.

I was going to give my standard "what are the user-visible runtime
effects of this change?", but...

> All these helper functions are all pfn_t related but could not figure out
> another way of determining a private pfn without looking into it's struct
> page. pfn_t_to_virt() is not getting used any where in mainline kernel.Is
> it used by out of tree drivers ? Should we then drop it completely ?

Yeah, let's kill it.

But first, let's fix it so that if someone brings it back, they bring
back a non-buggy version.

So...  what (would be) the user-visible runtime effects of this change?

