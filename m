Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4FCFC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 18:00:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FD0620657
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 18:00:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FD0620657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 204E46B0005; Mon, 24 Jun 2019 14:00:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B5D88E0003; Mon, 24 Jun 2019 14:00:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07E238E0002; Mon, 24 Jun 2019 14:00:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C127B6B0005
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 14:00:57 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b33so21538868edc.17
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 11:00:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZfCnjF5WzJqyoyJYwwCVgwYnCY2bQr+Xw14cGgXCzdc=;
        b=pABalwe3/4eqxTUzcu0eCJtbEXHWbbV1j8YcPtocYMfg001T4iaFkTsYPrNU+z9HD1
         XASLSx1tWRq7VbvwpAxEckSk5rUBD9JYCw64MpzLBZRmzXAYND0+4t5nP8gSt7Y7cd5p
         4TRELGmMqbcYhPx05WLSs702fUPklBqpQCUiaDGdAai9Wp1T7AZy6uDHIgxvoSYeKfWw
         yi1TdCz68nDtQRIekDnbwf0bOf4/h1qDUELGuYWU2QOE7XhhvzeimLXpFPGOu4zV2R/8
         VDiJk8GwFjjNHUU+TlPbgSDTYsAFfcsYBAaN2VYQb73y9QyujwdXZKhFkFQsutUcaOCm
         +guw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVZvowpKolSzl1Li8c3aadwokJpEyd8nvo8N51IUEiRwp5j6HUm
	WYULJa7mtUlTTq4J/1nAGZA7WUiRq7lGzmTstkuJZrkBSQbHTsiVVAfVcu/6VAMaYjMLQ4hcdWD
	4MDgtp+QlPMOz6tkAlV3CJ0K+0XGbvwy7R/j/5GSHnqbQ5ghQx97gJd0E7b6TEI81AQ==
X-Received: by 2002:a17:906:43c9:: with SMTP id j9mr9705480ejn.248.1561399257360;
        Mon, 24 Jun 2019 11:00:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6S7qeGlFlsOrWKBgKBr+O9PWHXE/vx3j5suP2hx13HyzcPAwod1qpSeuUM1619UyNwNrc
X-Received: by 2002:a17:906:43c9:: with SMTP id j9mr9705396ejn.248.1561399256591;
        Mon, 24 Jun 2019 11:00:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561399256; cv=none;
        d=google.com; s=arc-20160816;
        b=MACPXBTrbZcRQcDdpNMcpMg45OYontxoWFhCHG9CpzbgyBNx99hAoxOTZ5l1eu95M5
         jYEDb3zq7jrvT+hYBOgOANir8WKQl7SzA6eM1o2eYgjCY7D5PlIFdRGbrqyqYrlFHIUi
         J9n6Ae9w4Bp2hxYfjEw5RRYM0+mMN0r8C2LP+MhSLGbiem2U1jm9A3upfD+naR3pnWos
         /NYyLPmX5JsuzaUGaGo08IlyFSCM2Kw67yO2ZHk+6uNygeC95K2/a9zG52HMthOG7QaV
         oaMrECbFF9ErEjLhTCtLIsgdu6fqk6142Q+3nyennF0K7ztr+j2tns2qwu4lgsbH6nH5
         53kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=ZfCnjF5WzJqyoyJYwwCVgwYnCY2bQr+Xw14cGgXCzdc=;
        b=enhq2bz63GgI7TqP/BvKcNi5JWyzZOUQUIEYe8E0ElqFPKHbv7IzY00udxwS/CISQU
         hC/XT+45I54TrPRkD7T1QxkFKvNleEZwjOLDVPjc1hVER5wDUF3pnOZJtwjB861RFBkU
         WGlakUBUs8mkcXf+gTpzwyHi7AQ1d9bZQyj9LKlWFo1pUSBKYpIb42UdEtnT++F8QZ+H
         E8WPq5577AWRotwFuzOJ9GKIwAcuiwTmo+T1AQ9OuOl+zDrGTVDqEriYR8winOltTF4f
         xTYocBHWOCcy9q0hej3iM937j/MWlRox+yiGiBnI2kMtgZRShAtWg6NqozT8ZTnAVubQ
         6++w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z7si7343997ejq.44.2019.06.24.11.00.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 11:00:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2569EAEFF;
	Mon, 24 Jun 2019 18:00:56 +0000 (UTC)
Message-ID: <1561399254.3073.7.camel@suse.de>
Subject: Re: [PATCH v10 05/13] mm/sparsemem: Convert
 kmalloc_section_memmap() to populate_section_memmap()
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, David Hildenbrand <david@redhat.com>, 
 Logan Gunthorpe <logang@deltatee.com>, Pavel Tatashin
 <pasha.tatashin@soleen.com>, linux-mm@kvack.org, 
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Date: Mon, 24 Jun 2019 20:00:54 +0200
In-Reply-To: <156092352058.979959.6551283472062305149.stgit@dwillia2-desk3.amr.corp.intel.com>
References: 
	<156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <156092352058.979959.6551283472062305149.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2019-06-18 at 22:52 -0700, Dan Williams wrote:
> Allow sub-section sized ranges to be added to the memmap.
> populate_section_memmap() takes an explict pfn range rather than
> assuming a full section, and those parameters are plumbed all the way
> through to vmmemap_populate(). There should be no sub-section usage
> in
> current deployments. New warnings are added to clarify which memmap
> allocation paths are sub-section capable.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3

