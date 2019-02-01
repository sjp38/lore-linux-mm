Return-Path: <SRS0=aBqT=QI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DF17C282D8
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 21:02:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A0DFF2084C
	for <linux-mm@archiver.kernel.org>; Fri,  1 Feb 2019 21:02:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A0DFF2084C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 19E368E0002; Fri,  1 Feb 2019 16:02:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14BBE8E0001; Fri,  1 Feb 2019 16:02:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 061DD8E0002; Fri,  1 Feb 2019 16:02:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A40428E0001
	for <linux-mm@kvack.org>; Fri,  1 Feb 2019 16:02:35 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x15so3354577edd.2
        for <linux-mm@kvack.org>; Fri, 01 Feb 2019 13:02:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=gHsXDjL9X/1Jo4FWZRLueeQ9s8tedCa/nQhpTsJjl5o=;
        b=HvZyVv5RaHUP4l0Smg+mg81iIDF0FocA12LjtrI23NjZLqMd+rhRiKddEo9jcjffSU
         cFrfEiGqOPDGT7NQ5oluFUvEKlmCHO64I/y6ijHUn0xEocWrOL7nlLfaonnQnDrfJNwS
         5JkGeVqzqx6MZULxQP2J2RjVgjZlImRQfzIcar7SUpxzGVDCTUmLsxpqLjiBYsE1ssXb
         FdcdgoUH5J6AMNTjVMNQZOGZusBG4RusZiTIadK5Ar3rj/wR4TyW0vtkQQcY7/3KEPTI
         5j307TFZ5aecGaisoV5lq9XvY4QFHVryVaEeLGUOu9u4eEjr01oYXft4bRDozEwarv7D
         9/ig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AJcUukeLNtk4b6l6EB43+VmNKbE8lxI2driTx4+7wRTKKPjINDucYFfG
	TwyG0unnX0JxkKRHDLdwz2RWhiN6ezUa21WqdMYHZAwpk4NdUGSYQuHwRsnDYQ65DTg+ycBiXx6
	mYIH/QJZ1UFzEk692M0aNfW1nSr0jBm8TiD7NCOatQgT0oneC9x7mAJNsI813MCXNLw==
X-Received: by 2002:a17:906:1b12:: with SMTP id o18-v6mr36232922ejg.65.1549054955228;
        Fri, 01 Feb 2019 13:02:35 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7vyy+UMencGoHKS2o7xuBTmadAUD4NINZukV6n1IsPpD5DwZ3K4MSEZSRdq3e6GChC9/jJ
X-Received: by 2002:a17:906:1b12:: with SMTP id o18-v6mr36232886ejg.65.1549054954216;
        Fri, 01 Feb 2019 13:02:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549054954; cv=none;
        d=google.com; s=arc-20160816;
        b=bKfGJybZWsfrw72f86ospD7J0aqxTwA18WKNpdZCIBujFbsrqMadQGfDnLjh7NRv3h
         OqjWvswuPOsiFMyyYJDLCZcihZavnzeLA7d8KXCTHaS/jIrBQrYNXEmGi0TEC33R7DQb
         1jOMCgbIOXDrI61QLlR8lwlEvykr3RAmAYpl0SwqJItfxkE9ko9rMF0kl4ABamYf4FFj
         A3Mx39OocuAYC9tZahkIBu9e93SK7aO59obANmSoZlyYzuqEesUTTQuQT2fnXqQo3Jzt
         jXvdqrAElCwXCd7Q0EGxMSjkf5nQtJPYcm47GbXdi4lxmzYhD1/sjSX1FnzCIfLPVvME
         RTxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=gHsXDjL9X/1Jo4FWZRLueeQ9s8tedCa/nQhpTsJjl5o=;
        b=MSpBtuNsyUx4i0jqzQVX+FW7ZvDgW5HI1fttxmRnFGpO+bTUmqxA5PKcXTI8i0Z5/5
         BVlHArt3Do8Y2zMfT/B/oBVdXMPEFEEfVWddtaIcKl/+Ne6qpE+RWJDkVMQKySjIjAAV
         6Q3lNy9gzk2EnTKKvYGezKsqi/fyHYmJhvG20pzMPfDAkI1a0KQtGFyzSapfC4G5T7DU
         26IVumeDRhRYvSRYpS1ymUdcbUNd/+x1JEs8/tZp/T0C10I54HSI0QbQaqPNWf2S5QgG
         DW87EtAH7eik8RJNo9mtRDTPrcs8Tu0aGaxTrVMyxNVNzv54wQid+P59ctaZ5uZh5JeM
         aEKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v4si4267250edy.314.2019.02.01.13.02.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Feb 2019 13:02:33 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E61D1ADF1;
	Fri,  1 Feb 2019 21:02:32 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id EA6941E1574; Fri,  1 Feb 2019 22:02:30 +0100 (CET)
Date: Fri, 1 Feb 2019 22:02:30 +0100
From: Jan Kara <jack@suse.cz>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Jan Kara <jack@suse.cz>, Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Matthew Wilcox <mawilcox@microsoft.com>,
	Ross Zwisler <zwisler@kernel.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>, kvm@vger.kernel.org,
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v4 0/9] mmu notifier provide context informations
Message-ID: <20190201210230.GA11643@quack2.suse.cz>
References: <20190123222315.1122-1-jglisse@redhat.com>
 <20190131161006.GA16593@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190131161006.GA16593@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 31-01-19 11:10:06, Jerome Glisse wrote:
> 
> Andrew what is your plan for this ? I had a discussion with Peter Xu
> and Andrea about change_pte() and kvm. Today the change_pte() kvm
> optimization is effectively disabled because of invalidate_range
> calls. With a minimal couple lines patch on top of this patchset
> we can bring back the kvm change_pte optimization and we can also
> optimize some other cases like for instance when write protecting
> after fork (but i am not sure this is something qemu does often so
> it might not help for real kvm workload).
> 
> I will be posting a the extra patch as an RFC, but in the meantime
> i wanted to know what was the status for this.
> 
> Jan, Christian does your previous ACK still holds for this ?

Yes, I still think the approach makes sense. Dan's concern about in tree
users is valid but it seems you have those just not merged yet, right?

								Honza

-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

