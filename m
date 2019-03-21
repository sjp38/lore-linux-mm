Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E619C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:19:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC48F218E2
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:19:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC48F218E2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49D2C6B0003; Thu, 21 Mar 2019 10:19:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 44D706B0006; Thu, 21 Mar 2019 10:19:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33AEB6B0007; Thu, 21 Mar 2019 10:19:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0848C6B0003
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:19:21 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id l187so11579052qkd.7
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 07:19:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=hZnmTHqGZr4Cm16N5CUJmnlZngUG6FdlWCfshDf8XZQ=;
        b=ok3zTQQ9UhFamIbJBZwXNCK0UeJHYLvQK/MZUTRB+/Uqa99Q5GuvnUwsqQAguZK9Wi
         ub5PE65vSfQQEI9gwJ5kihDlYBCOwTCwyVA7Ud5/LhzcKYOgN1PikREyV5LOKKsPItdI
         +kQF3r5nQGj2+ISaxPAdo9g7Rvq0CKoZt9ZUP9+oxsEPtybncUutgC/r9ygy030kK3o9
         lbLbZCR/OMAswBv9U4nOhnnqHceeI83yZAFJasvXcKk0mOIjZWfOYB6ta3PmjqJWMd70
         a1oFpfN25+NeRyp2fPzFONjkGKp2WcTybeGMRobqNNEzhY1g7GFWFMhshIK1OjmS4Jqr
         Rf0g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWAIFNA/o9ikH8qV20uXOUWsq8LXM9cikO5H5LiTKxhl3mbQ5se
	8do2I+rxj3u/EJ4kbZS7JgcVLHO5T364hUebJnS7Cd31xo8NV7JtIbDb9W7jQoceM34xj5ZlmRb
	+x/tCxlWN+dvcXnLDQvmOh5o24WOZgiKWXYg1GWnx5c9by17nZ0Mjmdig0tbWJQaqoQ==
X-Received: by 2002:ac8:2acc:: with SMTP id c12mr3267600qta.108.1553177960829;
        Thu, 21 Mar 2019 07:19:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFTURFW+YtHvPCdv+2qxE60WazRJ58cuSClL6TnnaaiyeTjFQXykYpYbCUhtDAKv4SLQ7H
X-Received: by 2002:ac8:2acc:: with SMTP id c12mr3267543qta.108.1553177960200;
        Thu, 21 Mar 2019 07:19:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553177960; cv=none;
        d=google.com; s=arc-20160816;
        b=PswF2LulAN3sJIxEfqcgZRHdk/o0njEfoWoNcgdbAHk4mXvojs1GDjSy2byAyPbPmc
         PLcKk3S5pktkIM0ANXc6TpP3SnJMtAWsRDmf7pq9txwsdWxgWp4hwFb9boXizdi4mx2t
         cDARxklxDsC+sFj/LS6Pmc4clIUAy01nvpWttNATyH/Yv58/uA17hM58hoPS7iazNMIf
         97xlVrNqBbJW/IasyCSs4in6j3RO2fqhhrE/pb1l3KJ/JUGT+MbbdBWUcGMK3pK8zLRE
         9Al5xecrzZeCWykmYXKJIMCzuyLUwYGGAulrM4WANWhGeY1XFn1roVMj46tTNZQuMiVr
         n25Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=hZnmTHqGZr4Cm16N5CUJmnlZngUG6FdlWCfshDf8XZQ=;
        b=JP32pWGpJ8dRuvM6+bCMEFdsVqPSn5sUAgotkTj/i87n2lhTB5l8B0tD61hN3/QIlZ
         mLnhXpFXbuCD4+h9rSy3HFjOuZlmHDAiIFIztGrnubvnJiPWlvmij7uDEYMc24oWD3KL
         fEgaANxldD4dOdnXebcyjWGKxg3DBdTYrIoLV8QHsBryhPHK2Nr3/tnZ4mf475eUR4hA
         bBcx/5MEibE48SNJ61UZzOU8sjGI8jDq9TLSTa9yAUtTPJoX2lQ8slSJ/TqoRqScedi4
         RLA6EafUruThLmY1scSXDb1Xarw70uDUVK2v72sc36mqEup5DP7qdG0ggmw2q7y7uqtJ
         ZQVg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p199si597211qke.210.2019.03.21.07.19.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 07:19:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bhe@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=bhe@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 571403082E23;
	Thu, 21 Mar 2019 14:19:19 +0000 (UTC)
Received: from localhost (ovpn-12-72.pek2.redhat.com [10.72.12.72])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id B0F4819C57;
	Thu, 21 Mar 2019 14:19:18 +0000 (UTC)
Date: Thu, 21 Mar 2019 22:19:15 +0800
From: Baoquan He <bhe@redhat.com>
To: Michal Hocko <mhocko@kernel.org>,
	William Kucharski <william.kucharski@oracle.com>
Cc: Matthew Wilcox <willy@infradead.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Oscar Salvador <osalvador@suse.de>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>, rppt@linux.vnet.ibm.com,
	richard.weiyang@gmail.com, linux-mm@kvack.org
Subject: Re: [PATCH 1/3] mm/sparse: Clean up the obsolete code comment
Message-ID: <20190321141915.GZ18740@MiWiFi-R3L-srv>
References: <20190320111959.GV19508@bombadil.infradead.org>
 <20190320122011.stuoqugpjdt3d7cd@d104.suse.de>
 <20190320122243.GX19508@bombadil.infradead.org>
 <20190320123658.GF13626@rapoport-lnx>
 <20190320125843.GY19508@bombadil.infradead.org>
 <20190321064029.GW18740@MiWiFi-R3L-srv>
 <20190321092138.GY18740@MiWiFi-R3L-srv>
 <3FFF0A5F-AD27-4F31-8ECF-3B72135CF560@oracle.com>
 <20190321103521.GO8696@dhcp22.suse.cz>
 <EAFD8223-BEED-4985-8CD4-D3410A5898A6@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <EAFD8223-BEED-4985-8CD4-D3410A5898A6@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 21 Mar 2019 14:19:19 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/21/19 at 05:19am, William Kucharski wrote:
> 
> 
> > On Mar 21, 2019, at 4:35 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > 
> > I am sorry to be snarky but hasn't this generated way much more email
> > traffic than it really deserves? A simply and trivial clean up in the
> > beginning that was it, right?

Yeah, I'd like to do like this. Will arrange patch and post a new
version. Sorry about the mail bomb to CCed people.

Yet I also would like to hear any suggestion from people who intend to
improve. Discussions make me know more the status of errno than before.

Thank you all for sharing.

> 
> That's rather the point; that it did generate a fair amount of email
> traffic indicates it's worthy of at least a passing mention in a
> comment somewhere.

We header files to put errno. Only changing in kernel may cause
difference between it and userspace. I will list each returned value in
code comment and tell what they are meaning in this function, that could
be helpful. Thanks.

usr/include/asm-generic/errno-base.h 
include/uapi/asm-generic/errno-base.h

