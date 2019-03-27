Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3714DC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 21:14:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D655820700
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 21:14:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D655820700
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 45D6D6B0007; Wed, 27 Mar 2019 17:14:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40E5B6B0008; Wed, 27 Mar 2019 17:14:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 323FE6B000A; Wed, 27 Mar 2019 17:14:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 066BE6B0007
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 17:14:18 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d128so14883533pgc.8
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 14:14:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=5JI9REujBjOlKzsWNei+t3A7wXOptgCHe4Rav/6DxyI=;
        b=dEa1/2gXULXZjAMtsXaeljSSwNAem9xxZUMUZHdsdX+8GCAWE8ixijVLrslKoP7av3
         3EK/a1ZV5+WFuwFfvHx47zvBvRJjIj86JqAY6v8lXZBtdXGZT2QQniVAQF6iY1BFK6Jn
         Xh35H9jFFTam9myjESNwLSpOVPcvnnItI+rA1bBVoiwbcVA+X3KSjmHGnopZKrM7V8/N
         5Rm/k9AAzakwvQvywZj4/3koZl+8XcZFa4+V3QcBQwOAGOKu6t/EE51D5PzhYsDJkoCP
         7SRFMs7CEC/wxDPJ3IZDkTmRkF4Iq7o02GhsluTB8Gke0J+PFjhvnxcQrystBAydKhBR
         uVPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAWmAPHQ+J2wHKtW4eB/1c43oY//vcWFufLclbP6gchF98NHkbSX
	qe7wMDO4s28h6b/Qv811MGWSoKcOSF917iEkbv0tQ0UiJXhHO0wGrmHZevHy3UDMx0rlzM73uZU
	ijeSnkio54+Ipf4NxwU+95wvIiJsex15wNRFfnc+KxEBxvHvNFnDgPpiNrgLWBMuLRg==
X-Received: by 2002:aa7:8d17:: with SMTP id j23mr37061903pfe.62.1553721257643;
        Wed, 27 Mar 2019 14:14:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/ukHQbO+8MogX3S6VHzIsVHty0MpzH7f7LSyvHe+d0Y5YSgjMew7KpKYsU1494GH0r3gB
X-Received: by 2002:aa7:8d17:: with SMTP id j23mr37061838pfe.62.1553721256771;
        Wed, 27 Mar 2019 14:14:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553721256; cv=none;
        d=google.com; s=arc-20160816;
        b=Sz2irm8ThHZCf9jr4x1uwu2vCf8len+4dYCKgFuZNb/syR1k851l/0v0sqMz7b503m
         Tmi1sl1vXOduywJfQKXG0aoxhiRQLy12Jp5nUwILKW/A/zUiV+m+EsAgJwt8faRDVn2U
         YjdmAY+NnoSH0oGidHqoHtRtHLISfzktoW7LUnDD5jZFtpt+WONlizJrtZpFFb6veZtG
         otShXK0N2lFF4nfm0WJC88m8N2jujTcr8dYCn1ws8ZcTXzc6mrDASkn0rYCyVjL7VCQO
         WmgcUcUDTsUoSsTxDsUlCSvh3UiBs4qBS/fahftpIR3uReWfhEPS5otx1UislTp/slb4
         25oQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=5JI9REujBjOlKzsWNei+t3A7wXOptgCHe4Rav/6DxyI=;
        b=OV6gJihDYl0w2dxehpwLDB+5JCst7pLGpA5oxhQeIhwP685BAvpJl0cXRbTrSIVDnk
         ym5ZKNzVr3AWCKOEq14ot88ohhDUCiL5AWxcYi4RxugluV0LMcJp3GEw8y35yZHM93YT
         SOprPZjBRpvZiXlOPHKC8Z7FaBZnE5wnIL2DNE1mNTcF3RrnA2qsJFqWCGHKBs/Z8/P8
         pIb5CHZS58EdVb2EJ68UE5vsCPp6VFeq8jm2fvqb50VPzmQW6Y3pY0iv7VzqT06Zdx5p
         0oeVe2ap5waAgrGntdUCUK6YL/b1Z/XUMlHKlvuDRiZR9Ck/JVddHp0y+FGwlMbQoXvo
         FIDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i195si10927865pgd.521.2019.03.27.14.14.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Mar 2019 14:14:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 0A9EEE77;
	Wed, 27 Mar 2019 21:14:16 +0000 (UTC)
Date: Wed, 27 Mar 2019 14:14:14 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Jan Kara <jack@suse.cz>
Cc: Linux MM <linux-mm@kvack.org>, "Aneesh Kumar K.V"
 <aneesh.kumar@linux.ibm.com>, Chandan Rajendra <chandan@linux.ibm.com>,
 stable <stable@vger.kernel.org>, Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH] mm: Fix modifying of page protection by insert_pfn()
Message-Id: <20190327141414.ad663db479afa8694ed270c6@linux-foundation.org>
In-Reply-To: <20190327173332.GA15475@quack2.suse.cz>
References: <20190311084537.16029-1-jack@suse.cz>
	<CAPcyv4gBhTXs3Lf1ESgtaT4JUV8xiwNnM_OQU3-0ENB0hpAPng@mail.gmail.com>
	<20190327173332.GA15475@quack2.suse.cz>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Mar 2019 18:33:32 +0100 Jan Kara <jack@suse.cz> wrote:

> On Mon 11-03-19 10:22:44, Dan Williams wrote:
> > On Mon, Mar 11, 2019 at 1:45 AM Jan Kara <jack@suse.cz> wrote:
> > >
> > > Aneesh has reported that PPC triggers the following warning when
> > > excercising DAX code:
> > >
> > > [c00000000007610c] set_pte_at+0x3c/0x190
> > > LR [c000000000378628] insert_pfn+0x208/0x280
> > > Call Trace:
> > > [c0000002125df980] [8000000000000104] 0x8000000000000104 (unreliable)
> > > [c0000002125df9c0] [c000000000378488] insert_pfn+0x68/0x280
> > > [c0000002125dfa30] [c0000000004a5494] dax_iomap_pte_fault.isra.7+0x734/0xa40
> > > [c0000002125dfb50] [c000000000627250] __xfs_filemap_fault+0x280/0x2d0
> > > [c0000002125dfbb0] [c000000000373abc] do_wp_page+0x48c/0xa40
> > > [c0000002125dfc00] [c000000000379170] __handle_mm_fault+0x8d0/0x1fd0
> > > [c0000002125dfd00] [c00000000037a9b0] handle_mm_fault+0x140/0x250
> > > [c0000002125dfd40] [c000000000074bb0] __do_page_fault+0x300/0xd60
> > > [c0000002125dfe20] [c00000000000acf4] handle_page_fault+0x18
> > >
> > > Now that is WARN_ON in set_pte_at which is
> > >
> > >         VM_WARN_ON(pte_hw_valid(*ptep) && !pte_protnone(*ptep));
> > >
> > > The problem is that on some architectures set_pte_at() cannot cope with
> > > a situation where there is already some (different) valid entry present.
> > >
> > > Use ptep_set_access_flags() instead to modify the pfn which is built to
> > > deal with modifying existing PTE.
> > >
> > > CC: stable@vger.kernel.org
> > > Fixes: b2770da64254 "mm: add vm_insert_mixed_mkwrite()"
> > > Reported-by: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> > > Signed-off-by: Jan Kara <jack@suse.cz>
> > 
> > Acked-by: Dan Williams <dan.j.williams@intel.com>
> > 
> > Andrew, can you pick this up?
> 
> Andrew, ping?

I merged this a couple of weeks ago and it's in the queue for 5.1.

