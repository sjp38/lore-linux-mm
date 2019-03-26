Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12A3FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 18:37:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4AEB206DF
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 18:37:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4AEB206DF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 642A06B0003; Tue, 26 Mar 2019 14:37:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F26D6B0005; Tue, 26 Mar 2019 14:37:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4E2A06B0006; Tue, 26 Mar 2019 14:37:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id F02C06B0003
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 14:37:34 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l19so5623498edr.12
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 11:37:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9vp2bYSsRJT3s3itn0wC2NSkUEVs0LwSq/aMujoR+xs=;
        b=JVIi+0nJneDyvmwvPzi9mjbl3Qw6zQEQ8/RTA2ZEFUeupZu7wFH5owIVKnHWkOVmxV
         ObhfvT1A4Xb45ZKRuKVYuMfyzpifwdmWeqeZupgTqqJeVsv1a2kIfmmWBsYj/ywR4Jm7
         b313Yu7oYPXiobUj6GZTT2+bQ96pTU4oTL0lA/XrB6tyjcfiwj86NfPg2RDAWyKGDmKO
         P7y5tkJuz3DhyI/4d4L8rWdZFEuc+esnRvvNDrXMJ51ClSLL9pzV6tdWV53vyGGr2zPq
         tLDK3kCfBa9h4l3F/av24I1ZKdneyKxpQZHazRDNFc9Q/z3LGazGCrpz89vpznztgmOn
         /b5w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWaj40SCrxjXQHOdI5+Jseaz3ppf9QIj4XDUuoUNPuiMfBOiXqP
	ml94whX7MV/nPonGd3lcPaK3ApUlpm1mbMfUiY9OiwD/u8Ebrl9G0F4TwqZ2P6FyosF/KB71TUP
	g+RTPhfq2LxOA520nCijIKJo9LWlyHzpywZ3UqkYycyzhBljkqyrxbVRj75OHyLA=
X-Received: by 2002:aa7:dcca:: with SMTP id w10mr4154636edu.73.1553625454528;
        Tue, 26 Mar 2019 11:37:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzrFaWWUEbkLvm89bgmiNiD/P6W/UhUirB/ku+miKFK938yeFmyz9i88QIGfgXghVXzSIU8
X-Received: by 2002:aa7:dcca:: with SMTP id w10mr4154598edu.73.1553625453709;
        Tue, 26 Mar 2019 11:37:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553625453; cv=none;
        d=google.com; s=arc-20160816;
        b=lhQQXPLioV2i1Zu8NrXmEnYsRewKO6GlInjroYtFjt3hKjq6sVjBoDEt9qqVBZh3+z
         QakXgfK90pOBjaG2GYW8zZRlLkeJW9Wn8jHb7ChkirG/LpTp9S+nSYQf+gtY3dd5vQ49
         1OgAk9NcFF4xmI3u0gM4C0YhxSR0tsxz4WgsUtMJHVBIleVr65hsHT1X85o/A96P7eW8
         5rFvQRAbgxPSRlgKOtHPNllob9nsvDE9sFkAFeuqVV6BF+vMVBbYc+w4I10L22MuOsLi
         sYFOa8peN6FVBkn5cO/OX7cGlqUDWzXFFak51pfjf5Eu6YBV35oAaVxOeWBfxZStaTg9
         K8Cw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9vp2bYSsRJT3s3itn0wC2NSkUEVs0LwSq/aMujoR+xs=;
        b=GeakDJ+m34i87+7GiSGMRrRMvxoM4slKyEqN4Oc3SZdQYIMe59fDFXCVzW2hlBRRzI
         KrdRYHsnVNT52+zvGCulXaChREbIv2nlr72sfBlmlzpodK1lCiPe8i6BAeBFIFjIm9ua
         brg0d15I+rUGm7qZe7Fdzg8OCG5+bI74yJSW411kIaD9VsF2vs6rE6O2/DmQSHVvtRkI
         BF/JRDFu//JpZxCtpGFz8H2FFsK7B1rBqoTeHot7FUlP551XznDOogheA5+7gbveA7JY
         GhpHW8T+qcIeD9sTMdqrOBsCd0X1f/W1Lz3Xm97uxrqJOx5+hQeQ1L0ncAkXPgit7TF7
         c7+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m21si853618edq.234.2019.03.26.11.37.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 11:37:33 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 21C3AAC7E;
	Tue, 26 Mar 2019 18:37:33 +0000 (UTC)
Date: Tue, 26 Mar 2019 19:37:31 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
	akpm@linux-foundation.org, dave.hansen@intel.com,
	keith.busch@intel.com, dan.j.williams@intel.com,
	fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC PATCH 0/10] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190326183731.GV28406@dhcp22.suse.cz>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190326135837.GP28406@dhcp22.suse.cz>
 <43a1a59d-dc4a-6159-2c78-e1faeb6e0e46@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <43a1a59d-dc4a-6159-2c78-e1faeb6e0e46@linux.alibaba.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 26-03-19 11:33:17, Yang Shi wrote:
> 
> 
> On 3/26/19 6:58 AM, Michal Hocko wrote:
> > On Sat 23-03-19 12:44:25, Yang Shi wrote:
> > > With Dave Hansen's patches merged into Linus's tree
> > > 
> > > https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=c221c0b0308fd01d9fb33a16f64d2fd95f8830a4
> > > 
> > > PMEM could be hot plugged as NUMA node now. But, how to use PMEM as NUMA node
> > > effectively and efficiently is still a question.
> > > 
> > > There have been a couple of proposals posted on the mailing list [1] [2].
> > > 
> > > The patchset is aimed to try a different approach from this proposal [1]
> > > to use PMEM as NUMA nodes.
> > > 
> > > The approach is designed to follow the below principles:
> > > 
> > > 1. Use PMEM as normal NUMA node, no special gfp flag, zone, zonelist, etc.
> > > 
> > > 2. DRAM first/by default. No surprise to existing applications and default
> > > running. PMEM will not be allocated unless its node is specified explicitly
> > > by NUMA policy. Some applications may be not very sensitive to memory latency,
> > > so they could be placed on PMEM nodes then have hot pages promote to DRAM
> > > gradually.
> > Why are you pushing yourself into the corner right at the beginning? If
> > the PMEM is exported as a regular NUMA node then the only difference
> > should be performance characteristics (module durability which shouldn't
> > play any role in this particular case, right?). Applications which are
> > already sensitive to memory access should better use proper binding already.
> > Some NUMA topologies might have quite a large interconnect penalties
> > already. So this doesn't sound like an argument to me, TBH.
> 
> The major rationale behind this is we assume the most applications should be
> sensitive to memory access, particularly for meeting the SLA. The
> applications run on the machine may be agnostic to us, they may be sensitive
> or non-sensitive. But, assuming they are sensitive to memory access sounds
> safer from SLA point of view. Then the "cold" pages could be demoted to PMEM
> nodes by kernel's memory reclaim or other tools without impairing the SLA.
> 
> If the applications are not sensitive to memory access, they could be bound
> to PMEM or allowed to use PMEM (nice to have allocation on DRAM) explicitly,
> then the "hot" pages could be promoted to DRAM.

Again, how is this different from NUMA in general?
-- 
Michal Hocko
SUSE Labs

