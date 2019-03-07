Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 039E3C43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 17:46:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA0EA20851
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 17:46:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA0EA20851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51A1B8E0003; Thu,  7 Mar 2019 12:46:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A2928E0002; Thu,  7 Mar 2019 12:46:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36DC58E0003; Thu,  7 Mar 2019 12:46:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id E711E8E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 12:46:56 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id f10so16971311pgp.13
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 09:46:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=B650aAqz0JXcIiNtPXoMS7FiqQQajk6JP9Xmjxq1Lto=;
        b=aye/rjyNzk0cfAwBqbAHPxICqJdMBqCFzjax9ftGe9n/pYIqIg/DCyBSrTLV1f0vUq
         0sNuI0wn15WsI8JaMhc+uE7K0tJTylYOxXMsQ+g6+b/VdZOHNkMvhCILy01pYPYKHAF1
         ZuTRuOySIPq+BP53l4r0I1upMDTBYN3UEorxyxww04JZ2/03vj253TITgHuVsbJLiKBm
         cNcUi6/vmWDi7lvL1fZrfdoeLARWDoREp+rvGxH/N5wBaF7ae4/CXypnv8AcnRWTRg8l
         opTMLGljCjirvHxkIbGnxJB66U/2daySUEvku/0coZVhAHpPwqExXm1FWGFTXPgk8rKN
         J9DA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAVNwVLsg+NLrA72g8HB8or2TuxN1j+epxvqwc9WvNLeCrwXo8lY
	bI8S0vIpEFYsMeYrKwo1dz0JUK3MEu0GAV7qF/74Bdoh+ghO196PYKA80zqL7nDs/tTt/n2xw/T
	kwLQxx5yJf9AUA7rjLiqN1Qj1Mu7SIUx0DFu+/RBRl9eC5QXQtoAmbXb9KzQe3gvESQ==
X-Received: by 2002:a17:902:7615:: with SMTP id k21mr14377841pll.152.1551980816625;
        Thu, 07 Mar 2019 09:46:56 -0800 (PST)
X-Google-Smtp-Source: APXvYqwh6tsMmyKJYkfX28W7Bt42nq/uTaQRAMocmW/IpujQOQvVLAE0U7nykZXGGGrXum1lkkxl
X-Received: by 2002:a17:902:7615:: with SMTP id k21mr14377762pll.152.1551980815590;
        Thu, 07 Mar 2019 09:46:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551980815; cv=none;
        d=google.com; s=arc-20160816;
        b=nW1tBc1mMuhcUMZQn+Hpev8gPx98x1oeWJZBu1LX4dfxSumZbhZINgJYEhnFhYH40G
         g39w1ltm7zxRuPQ6khkPhd0MwASPhd1puhtl/Ny780Kmi6m2L+b+wJFHDQQKNqZQOmHO
         EWaX/oa2DqQRqx+wIr0lh8Oj+mOCstx4EIOLJndI82/3ZKC6TNHV9cBMOOEtIlCygsUZ
         ZI33t5fsdbgqBfKPsI52qvaOYs7Sc2VvAcHu+Ce0owHei28Ca3cSaBjXrfxcNd5+YoOq
         8tuHS8aFA1Pa/4IEYe3bzol5hjHenLh+CKNbFaZXF1ckuMfB1tHrSKHXMLSYGE0C9L1L
         f6fA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=B650aAqz0JXcIiNtPXoMS7FiqQQajk6JP9Xmjxq1Lto=;
        b=J3EJtoeh9zXb1tHZpd3+BpcXoWnhVKADtdqrqvgPHw1nctpxVn2ylP1XSBGUBc8JFK
         h4uCMXxTsVbI2wDLtPYPSliMOSK1bxYUfTz+Fl9JokpzIuAtgFoD21So64QK9L74ILEI
         g0SUIxsE7V8sgb+tBkgOJ1Dbcf3bWpCu4fxQF8WcL3ppkGyumTiJecPgzJ8JrKb4CHC3
         33Sv7TLt52EoZpFBZ9hZe0X/2BmjGqitN8rWkyDrEUy4TcugRv9AiFkfpeosNmk+QR+y
         3ybJ6kT3A1FyDXrEjC5xszjfnvUNhO22MXAsWqPoFKNZ2qQt4CzMq17qnZhbVI8sP+we
         3oyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id u84si4659088pfa.134.2019.03.07.09.46.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Mar 2019 09:46:55 -0800 (PST)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 17DE1C139;
	Thu,  7 Mar 2019 17:46:55 +0000 (UTC)
Date: Thu, 7 Mar 2019 09:46:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Linux MM <linux-mm@kvack.org>, Linux
 Kernel Mailing List <linux-kernel@vger.kernel.org>, Ralph Campbell
 <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, linux-fsdevel
 <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH 09/10] mm/hmm: allow to mirror vma of a file on a DAX
 backed filesystem
Message-Id: <20190307094654.35391e0066396b204d133927@linux-foundation.org>
In-Reply-To: <CAA9_cmd2Z62Z5CSXvne4rj3aPSpNhS0Gxt+kZytz0bVEuzvc=A@mail.gmail.com>
References: <20190129165428.3931-10-jglisse@redhat.com>
	<CAPcyv4gNtDQf0mHwhZ8g3nX6ShsjA1tx2KLU_ZzTH1Z1AeA_CA@mail.gmail.com>
	<20190129193123.GF3176@redhat.com>
	<CAPcyv4gkYTZ-_Et1ZriAcoHwhtPEftOt2LnR_kW+hQM5-0G4HA@mail.gmail.com>
	<20190129212150.GP3176@redhat.com>
	<CAPcyv4hZMcJ6r0Pw5aJsx37+YKx4qAY0rV4Ascc9LX6eFY8GJg@mail.gmail.com>
	<20190130030317.GC10462@redhat.com>
	<CAPcyv4jS7Y=DLOjRHbdRfwBEpxe_r7wpv0ixTGmL7kL_ThaQFA@mail.gmail.com>
	<20190130183616.GB5061@redhat.com>
	<CAPcyv4hB4p6po1+-hJ4Podxoan35w+T6uZJzqbw=zvj5XdeNVQ@mail.gmail.com>
	<20190131041641.GK5061@redhat.com>
	<CAPcyv4gb+r==riKFXkVZ7gGdnKe62yBmZ7xOa4uBBByhnK9Tzg@mail.gmail.com>
	<20190305141635.8134e310ba7187bc39532cd3@linux-foundation.org>
	<CAA9_cmd2Z62Z5CSXvne4rj3aPSpNhS0Gxt+kZytz0bVEuzvc=A@mail.gmail.com>
X-Mailer: Sylpheed 3.6.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 5 Mar 2019 20:20:10 -0800 Dan Williams <dan.j.williams@intel.com> wrote:

> My hesitation would be drastically reduced if there was a plan to
> avoid dangling unconsumed symbols and functionality. Specifically one
> or more of the following suggestions:
> 
> * EXPORT_SYMBOL_GPL on all exports to avoid a growing liability
> surface for out-of-tree consumers to come grumble at us when we
> continue to refactor the kernel as we are wont to do.

The existing patches use EXPORT_SYMBOL() so that's a sticking point. 
Jerome, what would happen is we made these EXPORT_SYMBOL_GPL()?

> * A commitment to consume newly exported symbols in the same merge
> window, or the following merge window. When that goal is missed revert
> the functionality until such time that it can be consumed, or
> otherwise abandoned.

It sounds like we can tick this box.

> * No new symbol exports and functionality while existing symbols go unconsumed.

Unsure about this one?

