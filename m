Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17C63C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 14:51:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB30F20881
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 14:51:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB30F20881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AE356B0003; Wed, 15 May 2019 10:51:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65EA46B0006; Wed, 15 May 2019 10:51:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 526466B0007; Wed, 15 May 2019 10:51:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 04A226B0003
	for <linux-mm@kvack.org>; Wed, 15 May 2019 10:51:55 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d15so392768edm.7
        for <linux-mm@kvack.org>; Wed, 15 May 2019 07:51:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=hTMYy1EaK3LKS3t54o0/p3Sni3y6a5O4w65M/yOf9YI=;
        b=EQV+2ktWcGYX3q2FrmIni6FhriLtzot0mRL0a11RQ1PJpWqOAdycItWeJWbGy/hBpJ
         WAcQoHiu4cF9B+DKveYlj+LeXSqrasL0IOf45X/qXMCWx+MDS7hojhzjm+4yazY6I0Rq
         YGgEGEXhECN30G71K5WNAftj/YSbcWjfhB3Z8ujB76acnRYL/PT/9bs2AdlLic5fEPLA
         p2okB7mupmiBtGTr/orvoeF7vmxqu710R8WRQ3VHLAnp7Sgtsm+jyzYWVhNb3iK4J+2G
         Fj8t0AneJudxshxzjNvMebYrrwWbPb9IQ5rXvkMP/g0Fr2vIfQyv/yHKXXukbuoP6Pob
         OADA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWP45oyCa0WOJ58YRE/f1M+wVoKNwNZxna5Dzx5EYOkRegARxa2
	8P4twpsuJehnfyvAybecjXFjQ2lbMaIlzJynzpm2BDaYfLG8VhNQ4yRl4x2Konyc4QI92muOKHE
	qmN/w3l3fZwrgOFp0Cc4PTdgf4OHQAW5ewEs2P9SiT3h34fdZof4th+mhcOka/N0=
X-Received: by 2002:a17:906:1856:: with SMTP id w22mr34005540eje.130.1557931914578;
        Wed, 15 May 2019 07:51:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYMjQz01kttTIYDcP1q8O2kONBFQL9y6pFZqduME3IKusjSRgiEWMiCfl7nMZLPL3r8mbT
X-Received: by 2002:a17:906:1856:: with SMTP id w22mr34005462eje.130.1557931913698;
        Wed, 15 May 2019 07:51:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557931913; cv=none;
        d=google.com; s=arc-20160816;
        b=bJTrU/7T4B4UXXtWn2kjiLhgR8RLxCuvxpMbYgp91JPn3g++bKS8s9haZOAg+9Tux5
         w7kxfWpMrYF/mONqZaJ6yy6hMxw2yY9Hb4z1xT8oTuBt48MOrzN/onAeuT0gJ6ZfzmV0
         T2cmWE2MY4IrpCF2UqxUCVjhmkrGTEDcCuLyDbgZGvAVPzKVNW0S1/MOVzsOc8O0v2aL
         PXGoW3UZb6ej68Gxi576Cr/481nVKOIofMls3kswuU3fqxicPUSY7bjzv40ZkE06Opjf
         AgjwiRrzjJ1cWQHwQ6/19qayPZNZ2PTBT/w5b8MiCxZd/6EwSEVMlW5CTfjDnkhhLJjS
         8s3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=hTMYy1EaK3LKS3t54o0/p3Sni3y6a5O4w65M/yOf9YI=;
        b=S2DBdCAj0YZt9Y/eOUbIjIFiX5WuSzSBcGoVWLUhqKycs/2E9HNt9EvFOTT//gcwzt
         DsTaABLX9BiF4sbvfxiu13/iKzrGQ893UC+X/wHl4shpYnxP5tCq8fEf+mg/uk1X/m5W
         SPFHFroWP0/vUzfdEBY/lyLyMz/cqBzmkchPPy4Pw+PwzeUMUecdNWWjuwh5fDPTwyrz
         GaW3vOGSbboQS1oknmABUwqttdVRDIYSeZw0wDJqfaLhfDwkcCmXftI2JBOwOBqVboZu
         P9d9hyykoF3A2StNouBtzdZsSVgWWBSXXSHIRKlyqvRBUtnB4NA3OgG2Xp9gFmDmXqPG
         N4+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g17si1513499ejd.378.2019.05.15.07.51.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 07:51:53 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 281DAAFDD;
	Wed, 15 May 2019 14:51:53 +0000 (UTC)
Date: Wed, 15 May 2019 16:51:51 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Oleksandr Natalenko <oleksandr@redhat.com>
Cc: linux-kernel@vger.kernel.org, Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH RFC v2 0/4] mm/ksm: add option to automerge VMAs
Message-ID: <20190515145151.GG16651@dhcp22.suse.cz>
References: <20190514131654.25463-1-oleksandr@redhat.com>
 <20190514144105.GF4683@dhcp22.suse.cz>
 <20190514145122.GG4683@dhcp22.suse.cz>
 <20190515062523.5ndf7obzfgugilfs@butterfly.localdomain>
 <20190515065311.GB16651@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190515065311.GB16651@dhcp22.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc Suren and Minchan - the email thread starts here 20190514131654.25463-1-oleksandr@redhat.com]

On Wed 15-05-19 08:53:11, Michal Hocko wrote:
[...]
> I will try to comment on the interface itself later. But I have to say
> that I am not impressed. Abusing sysfs for per process features is quite
> gross to be honest.

I have already commented on this in other email. I consider sysfs an
unsuitable interface for per-process API. Not to mention this particular
one is very KSM specific while the question about setting different
hints on memory of a remote process is a more generic question. As
already mentioned there are usecases where people would like to say
that a certain memory is cold from outside of the process context (e.g.
monitor application). So essentially a form of a user space memory
management. And this usecase sounds a bit similar to me and having a
common api sounds more sensible to me.

One thing we were discussing at LSFMM this year was a way to either
provide madvise_remote(pid, addr, length, advice) or a fadvise
alternative over /proc/<pid>/map_vmas/<range> file descriptors
(essentially resembling the existing map_files api) to achieve such a
functionality. This is still a very rough idea but the api would sound
much more generic to me and it would allow much wider range of usecases.

But maybe I am completely wrong and this is just opens a can of worms
that we do not want.
-- 
Michal Hocko
SUSE Labs

