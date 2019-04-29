Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC2ABC04AA6
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 13:15:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8CFF02173E
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 13:15:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8CFF02173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6FEC6B0003; Mon, 29 Apr 2019 09:15:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D1E136B0005; Mon, 29 Apr 2019 09:15:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C349A6B0007; Mon, 29 Apr 2019 09:15:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7179A6B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 09:15:55 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s4so3861683eda.4
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 06:15:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7gTeKKjyC5xRehCGJ3fDVsp6EDCweAatZ/YC0G+ZU0U=;
        b=iKmOLdY7HwzAUh+gEoe2b1krCjHlo/olcjVlStYPNFJ2tbtc/8bU9gDi6dwl6iqX8g
         ULz61QfvR7bCyXlUXLGfvS0cqxjLDt93alXcSQy1PVDSzwgXKfdOD8sGuXe8hFiCnu8q
         BexfTkVQw2RopeWIv5E+dN/0v+ZGU9iMf+0tVfoaVRPTZXPYNebfqnmg403NjZQ/Rsnr
         X7Uqxe9ZZowB3istRVHcqYOYWVcv0K+NL72czMj7d1P2CHSMOY/c5LPO9ASm6SJbdGS/
         ML26EdISJXvCMJqWnfNqLOOeaK/rzaNPf0cElWLukzdPP3xriP1gYfP6U37MDInhvFBX
         dhPQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVkDXwbQpmhFXQMKeT0WpndDKBzw2W2Wlc//ukk9QS1n8Dy+LZR
	WHGjCiFyBM5tsrveLpgz7GMEj71Hq5pX17+q7zdKd4A7JRMPR6iyQIPzitVfZ6rtAXh869T5PsH
	TIU+onG/yD70vxuce47Qr4AbG/Vu+4+SeCls82kjBvGwXMyWltN8BZE73cgmniyg=
X-Received: by 2002:a17:906:d18e:: with SMTP id c14mr5851178ejz.13.1556543754994;
        Mon, 29 Apr 2019 06:15:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7uvdPdhZ+s7qthclqHcA95/lYI3qGYyPkIeJKS06I84t974gbMKl/IGuDpJIgZWXjf5Ba
X-Received: by 2002:a17:906:d18e:: with SMTP id c14mr5851128ejz.13.1556543754037;
        Mon, 29 Apr 2019 06:15:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556543754; cv=none;
        d=google.com; s=arc-20160816;
        b=I/yGhiq14QJTiInRckN8ctI/hURRvRo0Xiz5CnkIlY/LtlQhULR7tWVAJojCvr8/eS
         GvM2pTpFLH7pc/6kh5gHXlwmDEoZU1k0AEiqb8/Xjef+XEVGhc84/XrgKXU6IbsDRzzq
         JNn33rdYIkB8iAkdGrIIKT7t+A69V3tinSmiNAG+9rJy9puSV8wyeMJQcTDyIC1lLReP
         81Ft1netM0RdWvXuFfrLuEwV750zhoW0/+AjO/qqhp6hpoj6aulgI67WM8OpWJfyn+rH
         vJIeKR7Uy/fHxCXQVIb4J/AwHGBBs+7leqrvghMHW/LGa/OrLElnYoYgfa5L0aeFqnGP
         xlFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7gTeKKjyC5xRehCGJ3fDVsp6EDCweAatZ/YC0G+ZU0U=;
        b=pbDxpZNC+LvQqLm/yn04xCW0RaM4elmBKlSRCKVUhiWjbFSRPTHXeqI7N1JnTMqG8E
         EJaqfDblwhW4z4oXJhRcjI6VC1EA9z9ZcGG3bQ3GFC0n/gOn2p4CBkFcs3fWfLx4OL6r
         IZUkY18vyi04toT4hahz9XaDX61jZubGl1EQhSChI/3mUUHRsRnnoztOuWWHVom4kx2p
         qc7gKbec346hQs8SnRNHvMyBvd4deLRCim2hKSmqwDYXRjIthPNiZfH54FrcUwtGh/x6
         1yutoQejcs5ho0rbtp+EgJFFaI+4txBjytFt+Gc63TEXpof+bwrfJNAvFVbZwZFHR8iD
         FxjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w49si108657eda.30.2019.04.29.06.15.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Apr 2019 06:15:54 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1E2D5AD31;
	Mon, 29 Apr 2019 13:15:53 +0000 (UTC)
Date: Mon, 29 Apr 2019 09:15:49 -0400
From: Michal Hocko <mhocko@kernel.org>
To: Jiri Slaby <jslaby@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Johannes Weiner <hannes@cmpxchg.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org,
	Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: make it work on sparse non-0-node systems
Message-ID: <20190429131549.GL21837@dhcp22.suse.cz>
References: <359d98e6-044a-7686-8522-bdd2489e9456@suse.cz>
 <20190429105939.11962-1-jslaby@suse.cz>
 <20190429112916.GI21837@dhcp22.suse.cz>
 <465a4b50-490c-7978-ecb8-d122b655f868@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <465a4b50-490c-7978-ecb8-d122b655f868@suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 29-04-19 13:55:26, Jiri Slaby wrote:
> On 29. 04. 19, 13:30, Michal Hocko wrote:
> > On Mon 29-04-19 12:59:39, Jiri Slaby wrote:
> > [...]
> >>  static inline bool list_lru_memcg_aware(struct list_lru *lru)
> >>  {
> >> -	/*
> >> -	 * This needs node 0 to be always present, even
> >> -	 * in the systems supporting sparse numa ids.
> >> -	 */
> >> -	return !!lru->node[0].memcg_lrus;
> >> +	return !!lru->node[first_online_node].memcg_lrus;
> >>  }
> >>  
> >>  static inline struct list_lru_one *
> > 
> > How come this doesn't blow up later - e.g. in memcg_destroy_list_lru
> > path which does iterate over all existing nodes thus including the
> > node 0.
> 
> If the node is not disabled (i.e. is N_POSSIBLE), lru->node is allocated
> for that node too. It will also have memcg_lrus properly set.
> 
> If it is disabled, it will never be iterated.
> 
> Well, I could have used first_node. But I am not sure, if the first
> POSSIBLE node is also ONLINE during boot?

I dunno. I would have to think about this much more. The whole
expectation that node 0 is always around is simply broken. But also
list_lru_memcg_aware looks very suspicious. We should have a flag or
something rather than what we have now.

I am still not sure I have completely understood the problem though.
I will try to get to this during the week but Vladimir should be much
better fit to judge here.
-- 
Michal Hocko
SUSE Labs

