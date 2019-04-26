Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4C3AC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 05:25:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4E432084F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 05:25:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4E432084F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D2586B0005; Fri, 26 Apr 2019 01:25:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3816A6B0006; Fri, 26 Apr 2019 01:25:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 271226B000D; Fri, 26 Apr 2019 01:25:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E09726B0005
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 01:25:23 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id j9so902439eds.17
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 22:25:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=C+p7fomEgPNJYoFX151pymwK7KQuUXLVfehBIWkBdmk=;
        b=igE1bmOSspNaHqu/aVdS/5bSP1h6gIAZ5nAkaVZ6UzNf22lemepVfvSvdVX7FXY70l
         19WduqaGXR+dd6idueFbjPL0d2gQ8A1PbxpfZJZ7ebLRLEo5cgFxfBQBLClF+KTvVwQV
         3mAgFQy6dnYc+if8GDBJ7NlegRivrJ45IMcVCzbs5eYPDZ7KivsUSTKTxYexEcm0ZmqK
         kKUWPIpXKu90+wvSddGC+As3zG+KJYaSa98p/2/Udo2U+0M3FHukPFUyL1NsLGRsPBS2
         0hzZuwJPugHpPQPa2lBZgEKpUSPeb1STgrRwJVGVhA4f2QZQdL+pIGyDzi16MT419TuH
         145g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXsje6M93E3wmlugivb27vOcAWupBeL8vrfVgH+YrRMgrfWIJGi
	CODNOcewspH2hSc8YPDdjGQ1FV6L7Od0DSZvbXVYfmJPBIpQZqDJx1Hq6zaKk8lmMrc6Us0Q03i
	SAk2xN/QnpvG3sg2kWwoLA3onl8fkWn/neIBkF1QCudAm8keDY8k9IvmvTvK2gWs=
X-Received: by 2002:a50:eb42:: with SMTP id z2mr26911238edp.56.1556256323482;
        Thu, 25 Apr 2019 22:25:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJCoA18ifNULRzhzGGCx3AU6MvDeGFoFIVaceLJUNg4EICLJGcq0YPV+SDFvezUqKp13gI
X-Received: by 2002:a50:eb42:: with SMTP id z2mr26911197edp.56.1556256322745;
        Thu, 25 Apr 2019 22:25:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556256322; cv=none;
        d=google.com; s=arc-20160816;
        b=NZY8s6oFCu/v8vXIKirC9iv6WvacRY/Vo83YHuj0G0rRqp2EHG5zQJXjy7X+toiHIY
         vSOVBK/c/JRl7pPjJRIiMgEL3N5xgu6Oz2vUlux88Ne+YEvxycvrJuwFWYuZyPHMI+vy
         8zCD1wGNu13dXkqoS2FDAO524UKhzr3PQhXf4l/mMakITYJjG3d9Z0/ahdMTnR7Nru5C
         42P0eYfEufMVoBB9pcWw7OmaCctIwnYs1Me9IK3fpkQdTkDmHVQ/hFUJDdzUM+NLxntU
         xKXwJTLUbjaTt6Ex3smKP5j1iCN3+uz3z96OSTIznxX0j028NwzfEw5MTTtgrJC8RoaT
         xTsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=C+p7fomEgPNJYoFX151pymwK7KQuUXLVfehBIWkBdmk=;
        b=a6Bh98azW/kywP/G31mheNzL+TBf6qk/UqC7vNTIim4WlH9kxxkznPTsS+Vra0zWjT
         0eRfxBEzbYkLT3mPBhMuKFVJ+jjBLNsW50eGu1Gxa0MlLB3zGgkKxikWU0K6Y5ZpG3aP
         9ppPgiAoYsvMQ0vh5aLBCTxgKaNrNNxtmUkWxF1ifcPbTHqKfFRC0Lst/787TrhSEqzD
         XXWRUcE5Eqdv9Or/y29/1tx8nhdBg2fjydquRvOS5nEIzhiq6MOlF4/y1uqJl7RVDBDz
         BCQgzNXOCYNirb+fjQ/umy0tzcLRk+6UrRi3IsNhqE3SFhT49YdBsE9QVyB5GMCAA7Iw
         d75w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i4si420252edg.192.2019.04.25.22.25.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 22:25:22 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DC3ACAD2B;
	Fri, 26 Apr 2019 05:25:21 +0000 (UTC)
Date: Fri, 26 Apr 2019 07:25:20 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Matthew Garrett <mjg59@google.com>
Cc: linux-mm@kvack.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH V2] mm: Allow userland to request that the kernel clear
 memory on release
Message-ID: <20190426052520.GB12337@dhcp22.suse.cz>
References: <CACdnJuup-y1xAO93wr+nr6ARacxJ9YXgaceQK9TLktE7shab1w@mail.gmail.com>
 <20190424211038.204001-1-matthewgarrett@google.com>
 <20190425121410.GC1144@dhcp22.suse.cz>
 <20190425123755.GX12751@dhcp22.suse.cz>
 <CACdnJuutwmBn_ASY1N1+ZK8g4MbpjTnUYbarR+CPhC5BAy0oZA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACdnJuutwmBn_ASY1N1+ZK8g4MbpjTnUYbarR+CPhC5BAy0oZA@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-04-19 13:39:01, Matthew Garrett wrote:
> On Thu, Apr 25, 2019 at 5:37 AM Michal Hocko <mhocko@kernel.org> wrote:
> > Besides that you inherently assume that the user would do mlock because
> > you do not try to wipe the swap content. Is this intentional?
> 
> Yes, given MADV_DONTDUMP doesn't imply mlock I thought it'd be more
> consistent to keep those independent.

Do we want to fail madvise call on VMAs that are not mlocked then? What
if the munlock happens later after the madvise is called?

-- 
Michal Hocko
SUSE Labs

