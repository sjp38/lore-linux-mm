Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1470AC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 15:11:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB20620828
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 15:11:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB20620828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1798B6B0003; Tue, 19 Mar 2019 11:11:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12A656B0006; Tue, 19 Mar 2019 11:11:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 018106B0007; Tue, 19 Mar 2019 11:11:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B1E696B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 11:11:02 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x13so8283803edq.11
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 08:11:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pZCNFnus42w6WrpKnslEAwDmE+6y3RkKMJuCJKaNotw=;
        b=ob8GOLHEoSgiivBdX4F1X6QkoPCvaIGxIIqndNpC0P9Zq/80PFsVJkVvNH1BLuriWD
         iQCO3Dx92o+ecYVHNkVkqcF1cqa3r00pNRQI6s+PdndLPJdvAX87aYKP/LQE9gaDmvV/
         VhsNJBnK9NFoKOZlGaYwrQhZi4NDxS72r0fq7qfLkJWlnqPpuoJWG2L86FBYTJhShK4F
         w/mnh+rrA0OSXlmla3xTxMZCyvhBX5JDORXbHGZgSnmXXFs9sFsOdpH05S2n0sSY1lqv
         eLEHE6v6OFop12Eb/tj0PvEpw7tFGkbMQKuNcE0g7oJpO3BeCtoXh7OISsyRrXUq59Lc
         yj7w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWE+W+03FK9CSFardpe/uJ2CMmdI226J5A0Jud5R1ZrAiahv0nW
	NeLW4oBJ5YJvNDyDaL+W3hiZkF7gsJJh38KCWE9AB+KYt8Kj1/Ve8gbCxY54PrigbeA/Dp3XBKa
	KQMCH/GOil+PR3YkHzAzYeb4KLPNVBhXe8RaP0k1InHWCE24FLGdOS1Rq7E3xrh7LGw==
X-Received: by 2002:a17:906:63d1:: with SMTP id u17mr10046410ejk.6.1553008262192;
        Tue, 19 Mar 2019 08:11:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdyxi8CRR9E/IGkSEtRYcSBxUxlyt1sQpkp95MQ1ip/PteN3EApvBhJNDjuSJW6aoGT0Ia
X-Received: by 2002:a17:906:63d1:: with SMTP id u17mr10046371ejk.6.1553008261238;
        Tue, 19 Mar 2019 08:11:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553008261; cv=none;
        d=google.com; s=arc-20160816;
        b=ZtUtbnwbWnmkyG8yMHKqIAxabqEmjvkVkUbKdT636IPuuNq0KuTbbYgyqqJaqV8xwb
         bCblE4pWdYiDP0PomAqR0HzDGxNL7dEesWK5PuxUFwkMhadAhpI7Lg0hT4u3RlIjo3V3
         uGSaFOKlJGZ7NudTKTSJXvzqi0hgSvg4+/ZcUmufkgM7T2BfniEEwxFCC0G96hGNMYNH
         UQkuUVhbj9XT28gOyk4YwgXWAWv2mE2MHwNPdn+RLOBzSksKaop/kfRIFGVKTNA5ct/r
         PhwFzNMZ+hqEUAdAGikhSaUl2SH41lskPuJFDdR7ONHzbT8s2zYMnt8ULFyxMsrqZcoP
         hP0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pZCNFnus42w6WrpKnslEAwDmE+6y3RkKMJuCJKaNotw=;
        b=briAWdAGhB5KDOuTvF8LCBIh8Es6hj5KUsT1hq1o4J7y/hwoPKkmtLpd7zkfqPiitq
         w2uF6ckKopFLLlmA4qDUWCDsHKZwNzb/M5Wgy9TAGg0OZ3NwB7ql6T+mYsKhWUMUxJue
         2BTiTO4gnRsofAWwGVCvcursgtq0OqBArljW8OFzXzNvC4k+LHimOjSQ0TeYTgCh09Wo
         64qK7oSM8SyAepyR129Pz9+q1NU8rSTq498ky3CigU4l/dKgWqmuHbrgTpuONYmV2ciT
         x2QUPmwHow6kDk8H5RjU1E1ihWGIQQ+QVnDf3vo1fFNgOgdsgHj9HJUZjJBsxVx9X9Cu
         bL+A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id z8si3107129edh.43.2019.03.19.08.11.01
        for <linux-mm@kvack.org>;
        Tue, 19 Mar 2019 08:11:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 464574607; Tue, 19 Mar 2019 16:10:50 +0100 (CET)
Date: Tue, 19 Mar 2019 16:10:50 +0100
From: Oscar Salvador <osalvador@suse.de>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Yang Shi <shy828301@gmail.com>, Cyril Hrubis <chrubis@suse.cz>,
	Linux MM <linux-mm@kvack.org>, linux-api@vger.kernel.org,
	ltp@lists.linux.it, Vlastimil Babka <vbabka@suse.cz>,
	kirill.shutemov@linux.intel.com
Subject: Re: mbind() fails to fail with EIO
Message-ID: <20190319151050.7ym3kdmhec7bf2ky@d104.suse.de>
References: <20190315160142.GA8921@rei>
 <CAHbLzkqvQ2SW4soYHOOhWG0ShkdUhaiNK0_y+ULaYYHo62O0fQ@mail.gmail.com>
 <20190319132729.s42t3evt6d65sz6f@d104.suse.de>
 <20190319142639.wbind5smqcji264l@kshutemo-mobl1>
 <20190319144130.lidqtrkfl75n2haj@d104.suse.de>
 <20190319145233.rcfa6bvx6xyv64l3@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319145233.rcfa6bvx6xyv64l3@kshutemo-mobl1>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 05:52:33PM +0300, Kirill A. Shutemov wrote:
> On Tue, Mar 19, 2019 at 03:41:33PM +0100, Oscar Salvador wrote:
> > On Tue, Mar 19, 2019 at 05:26:39PM +0300, Kirill A. Shutemov wrote:
> > > That's all sounds reasonable.
> > > 
> > > We only need to make sure the bug fixed by 77bf45e78050 will not be
> > > re-introduced.
> > 
> > I gave it a spin with the below patch.
> > Your testcase works (so the bug is not re-introduced), and we get -EIO
> > when running the ltp test [1].
> > So unless I am missing something, it should be enough.
> 
> Don't we need to bypass !vma_migratable(vma) check in
> queue_pages_test_walk() for MPOL_MF_STRICT? I mean user still might want
> to check if all pages are on the right not even the vma is not migratable.

Yeah, I missed that.
Then, I guess that we have to put the check into queue_pages_pte_range as well,
and place it right before migrate_page_add().
So, if it is not placed in the node and is not migreatable, we return -EIO.

-- 
Oscar Salvador
SUSE L3

