Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 449C1C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 15:24:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F373C20449
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 15:24:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F373C20449
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BC856B0003; Thu, 11 Apr 2019 11:24:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8691D6B000D; Thu, 11 Apr 2019 11:24:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7597D6B000E; Thu, 11 Apr 2019 11:24:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 262E46B0003
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 11:24:18 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s6so3298409edr.21
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 08:24:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=+67s+k+pvedEzDIh8ULcxnC93V9BDsvieDjsFaqYTX4=;
        b=RsjlRvyVLGzTYyLUr/gc5TvKO28htgZQOuQ61QLSWM6cyIA+ADGwozhjOIE0usRjIO
         ofDBGWk/BGm7Z4sGczGEkjGHt48zREdxv1GaID0OZOvjeg6nMwXw2oKiYDfrYnK+r9VM
         PBdlNdDTgoZZsqA7SE+l6/sXv2eGqz13dhH/oiMrESvETcuTBesC9gMICde5RM7DgnFi
         pNCBDz4UGsIeD3cFObfk2h817bWRedCmfFYtuiUos7RFcA9gpYHNeu6AOmCoYh3leX92
         2Qedzrwgz8Dgluo40eOqBtm5Kr6dQxUzhmKf6dvKvrL0JWWq36lcAemtagPZwXUvXcYN
         opCg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUQvyXRuPW+IKehGtXboLOBZs/itZPbxFsDwEOu/FTpd1SJ1o0a
	TrtqPlEtwRj90goY4cYLk8Hwnbgn8kvEoeGLgvoXUHvP60oPrcUjq+wD3ozJtL0muKjMeBRx0kH
	wK/GX/81pjSoNYtwoHgLUxsCZKj2ZyNKH8cMvHBGrZCWS3F+BEEUUygrMBOLzSbk=
X-Received: by 2002:a50:e61a:: with SMTP id y26mr18173221edm.157.1554996257685;
        Thu, 11 Apr 2019 08:24:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2rpK6n6Jn+Bcb/mASMBhUYj/odgiTE/Z9z4jHu2PqhQaWfEwSd2ruaNSELi8ylaDXuJ0D
X-Received: by 2002:a50:e61a:: with SMTP id y26mr18173185edm.157.1554996256987;
        Thu, 11 Apr 2019 08:24:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554996256; cv=none;
        d=google.com; s=arc-20160816;
        b=RMrpJDMqB3i0Hc6Lyg3OaRX22YiVTNdLvX6/rJWWWOiEwKco6duSGqhymE3U48yKS4
         R1gEKrhMAgzqOKirPkEUdyffH6kxczXuyAoPFD1Dp367s1W0BEzRLQTyT9JkgdxmP85R
         fwqo2v/aEsHN0xyUwmogqro1UhuPsPnjBradj5x89TdBv2k6f0O+oGvTlkx4crMhimbF
         5254ulX9S1x5Z2e9gRPGN+//fRnMaQ47QMRCp7q/3Jr+QBeRAUDvUsX/pCFUluNmgbb6
         tvHfPAnfe+rvgOXHaefvg/NemoBAVa/Xx2zuTuZ8+vXyMeiuId50vvRNvniwkqXqOSwT
         r4tQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=+67s+k+pvedEzDIh8ULcxnC93V9BDsvieDjsFaqYTX4=;
        b=OUEFaiWL7zrSIP1T2U5hyS37+eEPQEeIrrgcXau/vlwcdjEPuFwIdpQJHSECeirZtG
         wZGjo/t8+O/hwi5UXEKXALl+D3oEMab7ZxeaUoG3Nsnh/OeJmULrLc2tKpFlkjCBHd8o
         CV0nv6pujtJTHF1uziSg5DRmTaUGwqVK1Z74hUxgl0ijkBFzZIGpQUdQySxsz27DneS2
         xwkkPtFL5DhCIc/B0HU53b5c1u8pVVh3jmmhqZ3uEq/bM/6vtz407SVWB5RnoXfQoxLW
         kx5Bj8MGYaDDGJQp/ZZgl9vYR3DRB0ZMahhWyAPk1jKPLAJ2TbzsaDFNiNE/bqMWWbrh
         CZkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t25si2645276ejt.52.2019.04.11.08.24.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 08:24:16 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 10A4CAD4C;
	Thu, 11 Apr 2019 15:24:16 +0000 (UTC)
Date: Thu, 11 Apr 2019 17:24:15 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Waiman Long <longman@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Jonathan Corbet <corbet@lwn.net>,
	Vladimir Davydov <vdavydov.dev@gmail.com>,
	linux-kernel@vger.kernel.org, cgroups@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>, Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC PATCH 0/2] mm/memcontrol: Finer-grained memory control
Message-ID: <20190411152415.GA10383@dhcp22.suse.cz>
References: <20190410191321.9527-1-longman@redhat.com>
 <20190410195443.GL10383@dhcp22.suse.cz>
 <daef5f22-0bc2-a637-fa3d-833205623fb6@redhat.com>
 <20190411151911.GZ10383@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190411151911.GZ10383@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 11-04-19 17:19:11, Michal Hocko wrote:
> On Thu 11-04-19 10:02:16, Waiman Long wrote:
> > On 04/10/2019 03:54 PM, Michal Hocko wrote:
> > > On Wed 10-04-19 15:13:19, Waiman Long wrote:
> > >> The current control mechanism for memory cgroup v2 lumps all the memory
> > >> together irrespective of the type of memory objects. However, there
> > >> are cases where users may have more concern about one type of memory
> > >> usage than the others.
> > >>
> > >> We have customer request to limit memory consumption on anonymous memory
> > >> only as they said the feature was available in other OSes like Solaris.
> > > Please be more specific about a usecase.
> > 
> > From that customer's point of view, page cache is more like common goods
> > that can typically be shared by a number of different groups. Depending
> > on which groups touch the pages first, it is possible that most of those
> > pages can be disproportionately attributed to one group than the others.
> > Anonymous memory, on the other hand, are not shared and so can more
> > correctly represent the memory footprint of an application. Of course,
> > there are certainly cases where an application can have large private
> > files that can consume a lot of cache pages. These are probably not the
> > case for the applications used by that customer.
> 
> So you are essentially interested in the page cache limiting, right?
> This has been proposed several times already and always rejected because
> this is not a good idea.

OK, so after reading other responses I've realized that I've
misunderstood your intention. You are really interested in the anon
memory limiting. But my objection still holds! I would like to hear much
more specific usecases. Is the page cache such a precious resource it
cannot be refaulted? With the storage speed these days I am quite not
sure. Also there is always way to delegate page cache pre-faulting to a
dedicated cgroup with a low limit protection if _some_ pagecache is
really important.

-- 
Michal Hocko
SUSE Labs

