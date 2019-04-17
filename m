Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AABDCC282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 15:39:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7078421773
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 15:39:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7078421773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0028F6B0005; Wed, 17 Apr 2019 11:39:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF4FA6B0006; Wed, 17 Apr 2019 11:39:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DBD186B0007; Wed, 17 Apr 2019 11:39:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 898F76B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 11:39:27 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i17so903707eds.21
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 08:39:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=o/2klouQRbkTrBQxRFAmTnWA/zIk/OTOCQ7hor2s13s=;
        b=chshZHLdFQGJavEGyaKUl2tGCR+urCV/HGyTmv7fd5Hc9/4DcpjDJ9fp4/4nuZkZhE
         lxoyt9FWygMHAw8Arq05wrwCad2pe+pEgUFI62vVQNa9q83/wLLGzXZZmj/C7W0+oc3M
         YCHtZdc5OFlVCKPMCFUd5sfjD442CI3Uj4HindPzYqvJHzHouyjO3/EwAjh7hweKOdcW
         Dl5+0XMj0ybC7eFVegg3HtTqCAlHMo2iOe+9J1SbMj0qx/GZG4PyCuzU1bBg4ozyxPo8
         Yfqnfw29Ur5SW8iGI0/jTGxJVGOt8vNkRaiP3uTkTs8kVROzVUst0pmpTB0nKFECNpyW
         6W1g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVIYXOJ4CDRHPN6dhn3jHTZCPSs9+KLOPqS1auMSexCFf7xItlQ
	TJC+mnIV4IkOgLb2mm3IMWVxqAxkPvUYgIfxfwvw+PQoeuUiNECEUQkdUumENq7leBZRLI6PBYi
	9MfogCDl5VdzjD5LdPstA05P3NsKdt6Aq9FgHEVzvbvLnyO71m140IHFO1tB+qfc=
X-Received: by 2002:a17:906:3654:: with SMTP id r20mr32741783ejb.155.1555515567117;
        Wed, 17 Apr 2019 08:39:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyxHlS8hzNASJQsjNBAmX5U+cBNJeUpAToGNcJobo5QKMM07ZBpmGg7RFLZoppcWac5OPWb
X-Received: by 2002:a17:906:3654:: with SMTP id r20mr32741729ejb.155.1555515566406;
        Wed, 17 Apr 2019 08:39:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555515566; cv=none;
        d=google.com; s=arc-20160816;
        b=iYNj5qhG8i62DBwwIGrFvEh00iy0aL/t3NTtbMUo6s6U9Q1gqB+oC9G5cmsdpMKpeY
         lEgnsP8u+0zLNYaALW2Y7kutZuW4TDsjiKXc2OSBkcpzlW/EOYpeMCqUsCMOZ8/gHhwo
         6MSCc1RdYCJSO85s9JzSDwW/RaY/qZ6g1Oeq/Se8udfpAhYJUUp6Y/QZ40SzMzDcW7GX
         Vb5tthHTxwLGtaDpdIHEWTJsXwZFNwcWiUGZmufc6rd28RzMOFHLgPfDu4gV2tuz9Y61
         WWcKfMd78GNvvL9xmT+lXLtbZKa0axEgzngjDME8cwjzMo7iYfo13bhCDaQcSSnFRLoK
         JJQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=o/2klouQRbkTrBQxRFAmTnWA/zIk/OTOCQ7hor2s13s=;
        b=fIOx6gEpnXg58PflaffSyX7Z8xXWAqrqaPyBnrNTYLggA1ZqgktlVcOaYF2evAZliM
         n/ftuAZ7XrA5zvd+XPaSV3cqEthm8lXIN/sk9Qtl2xRNILcceA98enpFFY4qIV4WVvjA
         xvY/LE8JJqmu+2vTw3m7eqwzDp97mDQKpwHMUDsYgXKpf8BjrGI+8oNMu9JbU83NOQ4o
         tFs+s7+JuZaeNiK2T3/GMBBkp7jgez7nvAg0yu16yaEhw7mlZotXFuIu32L8d+Jy8jt0
         L0xTLYPMXrGB46WDPXrcxLcuLNjsw6tH3HnPtXj6h3n/v7v5KT7YoY9yyTakB2ogPTL3
         4zzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r15si12467918ejb.120.2019.04.17.08.39.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 08:39:26 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6ABD6ADAA;
	Wed, 17 Apr 2019 15:39:25 +0000 (UTC)
Date: Wed, 17 Apr 2019 17:39:23 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Keith Busch <keith.busch@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>,
	Yang Shi <yang.shi@linux.alibaba.com>, mgorman@techsingularity.net,
	riel@surriel.com, hannes@cmpxchg.org, akpm@linux-foundation.org,
	dan.j.williams@intel.com, fengguang.wu@intel.com, fan.du@intel.com,
	ying.huang@intel.com, ziy@nvidia.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190417153923.GO5878@dhcp22.suse.cz>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
 <a0bf6b61-1ec2-6209-5760-80c5f205d52e@intel.com>
 <20190417092318.GG655@dhcp22.suse.cz>
 <20190417152345.GB4786@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190417152345.GB4786@localhost.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 17-04-19 09:23:46, Keith Busch wrote:
> On Wed, Apr 17, 2019 at 11:23:18AM +0200, Michal Hocko wrote:
> > On Tue 16-04-19 14:22:33, Dave Hansen wrote:
> > > Keith Busch had a set of patches to let you specify the demotion order
> > > via sysfs for fun.  The rules we came up with were:
> > 
> > I am not a fan of any sysfs "fun"
> 
> I'm hung up on the user facing interface, but there should be some way a
> user decides if a memory node is or is not a migrate target, right?

Why? Or to put it differently, why do we have to start with a user
interface at this stage when we actually barely have any real usecases
out there?

-- 
Michal Hocko
SUSE Labs

