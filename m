Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5CCAC28CC2
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 22:06:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B78E2425B
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 22:06:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="gerrou/C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B78E2425B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 082876B026A; Wed, 29 May 2019 18:06:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 03C896B026D; Wed, 29 May 2019 18:06:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E643E6B026E; Wed, 29 May 2019 18:06:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id AD2CE6B026A
	for <linux-mm@kvack.org>; Wed, 29 May 2019 18:06:14 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id s4so1852718pfh.14
        for <linux-mm@kvack.org>; Wed, 29 May 2019 15:06:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=yKoIy4+OSW8XRfhH7FO+yhBNRqFldA7SyirAFs+3k4o=;
        b=RQ9ykXMyIA6GzsWH3UmyMRAit35+2ixsehxH8PccoSqbehs9DRtoGC0lK60aavBEWc
         nRnxTX1BtMb4OrLhW3EyUlwHcCEvYp+Jzod9YecxbPtbVf89OheWv5ldLU08FI5tqawS
         hNd5e9N5zsFtrlvgNKo5HaNcwlTU+utXldsTuV+zEMTf1wd2MQmwLSsb1Y9gau/ZpN3a
         UBOSWFU8a9HRKtx2VNfk1UKqYkTuYjZI5qz+AjinkGDGjCgkGdawTi4KdgGxbHpW51OP
         7Z1oz8Q4FLKEx+b88OGJ0sZ6nTNYDkOZM3cS8yzZjsi7AE7G2qMTqxqPQwiUhkQkynK8
         FF7w==
X-Gm-Message-State: APjAAAWXhDZiObQVhmPvKU2nl43xqAp4KFby5U9gVz0b63Myg0buqZlh
	xs+s01NQSjaZIQvzbFt6tvdKvkMxOEPICgQr4lrW+clxOZ+U3iZfqAjC1tGpcw34Bgw3vJjo+HY
	Sk6QVYBmA2X7VgRrlx3pJgUkanpfaQWEjUZlUNdo98MCTqE7JhamSrDOOZ4uoDT9ZGg==
X-Received: by 2002:a65:41c7:: with SMTP id b7mr257258pgq.165.1559167574339;
        Wed, 29 May 2019 15:06:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQDnx4jmmuyz6CcUdTrOJy0GKRrMOo0vnNuFJt0b0QnEVa1Xl+yN28bLXAiNGsM1LXbi1f
X-Received: by 2002:a65:41c7:: with SMTP id b7mr257182pgq.165.1559167573447;
        Wed, 29 May 2019 15:06:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559167573; cv=none;
        d=google.com; s=arc-20160816;
        b=iegWEofIjD/9knqfKMbvSo9K+nmF8bUgEE467QskofamYo//PPKYCtSUw7NBvbKvUY
         +fWkj7LjA7UPOkKarFJH3xglhOrjNRwNlCXG7dCRAzeknH+4dRWfK4zZPAIMxhScpx/Z
         yERmdpM26YYgkfJYEeHIsFI12SJQnvJbZ3ouBESpcPVNFWnD/3OR2/nObBVlxG7vP7rL
         trydzsn2qn0Gp6U5yu9IucaZIuAmDhLoHy1uKQaEONe4DIwpw6/UzQ850MN3QhbAAXZW
         6ekmAPJmMolz5wWmbWjkjBM3pmfVuF5gJwCMOa0g+ozbp2updUqXGJY1h+vbJWmDDO0E
         s/Uw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=yKoIy4+OSW8XRfhH7FO+yhBNRqFldA7SyirAFs+3k4o=;
        b=WURG/SyJhD9srmoTZ33QP114MDQpnDAnmq9EPZrZN/rtnasWwdwTeAkuW/VjdwqwM9
         PDt+gY8GsAeMbxef1QcCQVi6EysS9HLsg1wwGQAwZEeUOFZsf/TdbS+318IuPi+7nqe4
         g8Lab30LuPrK/ef/ESZmXqjEQ+/KxSypNqQZAhbJx35RLyoNJ9ZsC7ZlhXWOh+oLlHnX
         Mg2FoSbo+dbPESG4kE4MmsAfqKxyFOhkZsB+gyM2efucEG4gAscXDKA5pAU7Omf0Bkb4
         BkrCgcrBEss0zCLXe/m5WxcBG9OuBSFmM5rtngjEKaaH/qqaDMTA03O833TL2NsNYHcV
         YDow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="gerrou/C";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d16si974065pfr.229.2019.05.29.15.06.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 15:06:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="gerrou/C";
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 5589024257;
	Wed, 29 May 2019 22:06:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559167573;
	bh=rWWvSy2SCl28ReiT8I2BWwARbIr04tpQHSj7QNq/5YE=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=gerrou/CZt1Rss49kiuG2BG724zLbGiugPqeN8w79MuOdLxnGvWczrM8RB6V9L42i
	 zA4kb/wlkjvupHprLPu31fdVa7RSi89A82U4qS1bVdg4CAs2w4/GdbvDYSjNBzLwol
	 3FIiGIoC+mL0ttq79m2ihlSfHUAa91+n+iX0Nxgc=
Date: Wed, 29 May 2019 15:06:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com,
 will.deacon@arm.com, mark.rutland@arm.com, mhocko@suse.com,
 ira.weiny@intel.com, david@redhat.com, cai@lca.pw, logang@deltatee.com,
 james.morse@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
 dan.j.williams@intel.com, mgorman@techsingularity.net, osalvador@suse.de,
 ard.biesheuvel@arm.com, David Hildenbrand <david@redhat.com>
Subject: Re: [PATCH V5 0/3] arm64/mm: Enable memory hot remove
Message-Id: <20190529150611.fc27dee202b4fd1646210361@linux-foundation.org>
In-Reply-To: <1559121387-674-1-git-send-email-anshuman.khandual@arm.com>
References: <1559121387-674-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 May 2019 14:46:24 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:

> This series enables memory hot remove on arm64 after fixing a memblock
> removal ordering problem in generic __remove_memory() and one possible
> arm64 platform specific kernel page table race condition. This series
> is based on latest v5.2-rc2 tag.

Unfortunately this series clashes syntactically and semantically with
David Hildenbrand's series "mm/memory_hotplug: Factor out memory block
devicehandling".  Could you and David please figure out what we should
do here?

