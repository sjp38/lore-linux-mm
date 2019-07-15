Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_2 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA0C3C7618F
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 21:24:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8257D206B8
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 21:24:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8257D206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17ADF6B0006; Mon, 15 Jul 2019 17:24:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 105766B0007; Mon, 15 Jul 2019 17:24:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 042166B0008; Mon, 15 Jul 2019 17:24:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id AA0D16B0006
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 17:24:15 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y24so14600585edb.1
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 14:24:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=dlfsEPibOaDlK6TTh7GEM6mo85/tADVk1MeXtNCkFEw=;
        b=ck75hy6fBHutLGCpUqS0d6IoNFivt76ocayg0CSfOe85xrX2+rjB2TQcvk8LV5wui+
         2TpAXhE8X/1wT4gGeTDhzRfZUaTkYTGKgY7KBf/yfORjl+H3m7ctsDQVkhXnplqbNSc5
         8h0ZVsArBv3jCe0hOQ7csuzNYBYoa+6bHNmBHdbJ78f+hOD0Y/o+nlJmfXJyyaJTPHbM
         326Tmrc6nWPP66AVQLQ4FTSkUotaT3IvRc7piddiUhwJCR8AcnXnLhkb/CeVn+VOZn1T
         tFDxvCHOdxEnAb7hDcpuVU99MHCmkREaUjJBpFq0uZOtxzTuGhxPrCPABR+SQQ5IBWlB
         j1Hg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVOFfqpZMH13ymklKQRsmMv/G1yugogszq9BiFT//+kS56BCqWI
	CNOnhoesaQv2gjYlWsX5pJItKEsXKCbJ1vrMeMayiQqZxn0fnLQPNu/mbXHMPXbJo8SZAUUCghc
	Xii/8qwQsmswwcUgapZbWYg3MdopwXsKCZ98U60XiQPfd3mdPA1dKi49uzOOtHAgbfA==
X-Received: by 2002:aa7:c554:: with SMTP id s20mr25114507edr.209.1563225855263;
        Mon, 15 Jul 2019 14:24:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzk5X6oFuJ54qvbNeg8QrTQDvoIi6+KYPRL7wP+bjTjOErngwRUJ7iEvH5J9uZSh94Td1rS
X-Received: by 2002:aa7:c554:: with SMTP id s20mr25114460edr.209.1563225854256;
        Mon, 15 Jul 2019 14:24:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563225854; cv=none;
        d=google.com; s=arc-20160816;
        b=GxpenxQX9psYpdT4Cj04wEop2HSXtD5f3zWhB6OMXc6V6QzR/Tm68mGx1EweI8nkwz
         OZW4FbzDdz95E/c7Ks5NyakoMloJg1y5Kk10d5fyvTgWGGxw2mo+AMCBh361QvZza9Fv
         8K5UuKxMDT5x3JXl6ToPJhwyXriCfxzZjkz8omdDEP4ne42hnBB7ut3bcvPPE0rHwPjU
         67JwSszN6o/VpkOVfYz2nHF7XcP9x+/bu38o50U8jue324yL1WgPz4v+aG2S6wy30rUB
         ungwA6UKGlo8QLwIXasFVLymzzxepYIHLcLHTWEo3IHdoJ9dEJpoYJ/FLDH6ZHz2W3G0
         Og5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=dlfsEPibOaDlK6TTh7GEM6mo85/tADVk1MeXtNCkFEw=;
        b=OwroCTPgaeufCONyvSlAoUmkhF5DNunqHy1f1gMrsS6bsQzNVt5Wd7X68x9dhsjZHZ
         ZD+551phgyvm63Bb+5ThSn4AWV+SDL9Ut5uIJqih92bgZVskDgBMLQhETIgJvadfM9Oc
         rIkXrqGxn+B81/+YZilT1zHnDplRr28ZfdpGkXqebkRcrn9rzuTjWSnb8nEuS+gzN5rh
         pzpNi4W0INTPY7ojHXw6+j51iSEjTBDxj8zBNQRwegxDFnDD8yCeEP/4ijP5JVilzGxZ
         hLUDoS0fb72mgsxiVBHjtqE1yXyMEkLd/jKt5SYsJRrPDy6p0bJscyriMgxODSi3Xr2N
         dQYw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g27si10074709ejc.229.2019.07.15.14.24.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 14:24:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8BAF6AE16;
	Mon, 15 Jul 2019 21:24:13 +0000 (UTC)
Message-ID: <1563225851.3143.24.camel@suse.de>
Subject: Re: [PATCH 2/2] mm,memory_hotplug: Fix shrink_{zone,node}_span
From: Oscar Salvador <osalvador@suse.de>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, 
	akpm@linux-foundation.org
Cc: dan.j.williams@intel.com, david@redhat.com, pasha.tatashin@soleen.com, 
	mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Date: Mon, 15 Jul 2019 23:24:11 +0200
In-Reply-To: <87tvbne0rd.fsf@linux.ibm.com>
References: <20190715081549.32577-1-osalvador@suse.de>
	 <20190715081549.32577-3-osalvador@suse.de> <87tvbne0rd.fsf@linux.ibm.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-07-15 at 21:41 +0530, Aneesh Kumar K.V wrote:
> Oscar Salvador <osalvador@suse.de> writes:
> 
> > Since [1], shrink_{zone,node}_span work on PAGES_PER_SUBSECTION
> > granularity.
> > The problem is that deactivation of the section occurs later on in
> > sparse_remove_section, so pfn_valid()->pfn_section_valid() will
> > always return
> > true before we deactivate the {sub}section.
> 
> Can you explain this more? The patch doesn't update section_mem_map
> update sequence. So what changed? What is the problem in finding
> pfn_valid() return true there?

I realized that the changelog was quite modest, so a better explanation
 will follow.

Let us analize what shrink_{zone,node}_span does.
We have to remember that shrink_zone_span gets called every time a
section is to be removed.

There can be three possibilites:

1) section to be removed is the first one of the zone
2) section to be removed is the last one of the zone
3) section to be removed falls in the middle
 
For 1) and 2) cases, we will try to find the next section from
bottom/top, and in the third case we will check whether the section
contains only holes.

Now, let us take the example where a ZONE contains only 1 section, and
we remove it.
The last loop of shrink_zone_span, will check for {start_pfn,end_pfn]
PAGES_PER_SECTION block the following:

- section is valid
- pfn relates to the current zone/nid
- section is not the section to be removed

Since we only got 1 section here, the check "start_pfn == pfn" will make us to continue the loop and then we are done.

Now, what happens after the patch?

We increment pfn on subsection basis, since "start_pfn == pfn", we jump
to the next sub-section (pfn+512), and call pfn_valid()-
>pfn_section_valid().
Since section has not been yet deactivded, pfn_section_valid() will
return true, and we will repeat this until the end of the loop.

What should happen instead is:

- we deactivate the {sub}-section before calling
shirnk_{zone,node}_span
- calls to pfn_valid() will now return false for the sections that have
been deactivated, and so we will get the pfn from the next activaded
sub-section, or nothing if the section is empty (section do not contain
active sub-sections).

The example relates to the last loop in shrink_zone_span, but the same
applies to find_{smalles,biggest}_section.

Please, note that we could probably do some hack like replacing:

start_pfn == pfn 

with

pfn < end_pfn

But the way to fix this is to 1) deactivate {sub}-section and 2) let
shrink_{node,zone}_span find the next active {sub-section}.

I hope this makes it more clear.


-- 
Oscar Salvador
SUSE L3

