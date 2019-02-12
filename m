Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9F96C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:44:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C9CE217D9
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 16:44:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C9CE217D9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A6978E0002; Tue, 12 Feb 2019 11:44:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 27C1A8E0001; Tue, 12 Feb 2019 11:44:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16B798E0002; Tue, 12 Feb 2019 11:44:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B3FEC8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 11:44:55 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id m19so2678389edc.6
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 08:44:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=4O1Y4RP95JS27d17ct9edQQL17Rs4/Xf89dgVmP+zv4=;
        b=lVSz+dGuNCpJGAUviqZEH3kAFhuFdjdhHtfGokH7eTcGsK3yPle31MCZm6BQB3QMeV
         /uYP3SdATaXzyVbU9hSCE9wsRkP0S97ZN07dikjlffLqAUQZb+AnhNGOQNMdq1z2tqbl
         yLYRfG4lE23B+0xv3ubQDt57W3Qz3L5s9x1WHgsSppf0PUALOxoXWwTk0Ue3mPssmwt6
         MJjknrOv8tAjja9KHVFa9LfPbfuAfrOm8JaRcFwZZzZ7QzoV4PD7smo7kFOUGqLjwy+J
         QK7p3CAwXRjRETtmNf4dlOiEXPDvOAA6dM6M7Sl1MWVemhy6wyhPmh4Ot8jzc3xexfvH
         vR6Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AHQUAuZIywNo0toccsRNXCHsvqBxqK4Mnk+cF01AvzrFP2o1RqYmKUAI
	Yhmvob56Nj20AKKIRfXW2OkvLBZwGWCDJBet86KgnXmgLvDMJMVjWPLuYR9l3fBNI0AIHoJGhfC
	nIp69v7YmV3niEMP3lZ1tD7LXKc0X3hA0LKKuMlcuNacQ8uQkSD3k6JykNds/EfqmFA==
X-Received: by 2002:a17:906:1199:: with SMTP id n25mr3260792eja.120.1549989895288;
        Tue, 12 Feb 2019 08:44:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZOwN5sm5x4/oQCSyRUxYrlppt0hgJ92mqx/GcI9NCRm6HCSN8KqdjJwxTghJ3wyFD8BYlU
X-Received: by 2002:a17:906:1199:: with SMTP id n25mr3260747eja.120.1549989894371;
        Tue, 12 Feb 2019 08:44:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549989894; cv=none;
        d=google.com; s=arc-20160816;
        b=oMldQZcROG8UohlSMq0bSiZhhxXfEYi1FCrkVUR13Rjjl6i1ze4LxfHVOI4nJ2Omof
         QVyOa897FAJotFDmUvHl2XZfv4X+DsahpO6kKG/ZpxSupRz5WdbNRL3lreOKMkOi6F1b
         4XM0LvRCz3ShersJUzN8IDsfJO+r0SDu/XVGgjiXmQlmBaDrNvjRc2DOWZLekjvVTWZv
         nhKWU7uKxAE9MFNROWCC0+4dk+7KVBGi8tmO3EvWMfENKfdZRF+lrfMbxOLhQfXg4ql2
         tfKr55ywYgQm33ksmXiAlm3pMN7pcyUCqLwCAKvEDznHHathi4BY8Bu3Ya0J96OiCqOn
         u9bA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=4O1Y4RP95JS27d17ct9edQQL17Rs4/Xf89dgVmP+zv4=;
        b=TnOMka/XH2+7sWI3kSV3w7eiU75W+kMReI9F2DJWgb/c0tWtOmkpZRPkFh+2IQtZrY
         g7B2eWhWAtvqac3ezYcQbcUcE11F7hjqxl79jyOsTKbq87WXNPpqtU/Mh6ljEnnvI/fc
         luedMaIfzjtuuP9lJFZJ3LLisptY6ICc4Bo9vgZTu54ZXROQm7+DdPAhoAnjGDz/2D7g
         SnjXH07DZYBvc3KbL7Vx/quTW0aO/adsXnf/1WfDJMvlxhe2xB7HEiH8oIRumDEU0uUL
         W79JD915Ht5C8nupG/ovMZW2lw9tG1BUuV1TKrIPqqIbtQNBBxYLv77hkvHKre2MfN7l
         QOOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u16si1413354edx.384.2019.02.12.08.44.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 08:44:54 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id AB6ADAF50;
	Tue, 12 Feb 2019 16:44:53 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 7FD1F1E09C5; Tue, 12 Feb 2019 17:44:52 +0100 (CET)
Date: Tue, 12 Feb 2019 17:44:52 +0100
From: Jan Kara <jack@suse.cz>
To: Christopher Lameter <cl@linux.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>,
	Dave Chinner <david@fromorbit.com>,
	Doug Ledford <dledford@redhat.com>,
	lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190212164452.GF19076@quack2.suse.cz>
References: <20190211102402.GF19029@quack2.suse.cz>
 <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca>
 <20190211181921.GA5526@iweiny-DESK2.sc.intel.com>
 <20190211182649.GD24692@ziepe.ca>
 <20190211184040.GF12668@bombadil.infradead.org>
 <CAPcyv4j71WZiXWjMPtDJidAqQiBcHUbcX=+aw11eEQ5C6sA8hQ@mail.gmail.com>
 <20190211204945.GF24692@ziepe.ca>
 <CAPcyv4jHjeJxmHMyrbRhg9oeaLK5WbZm-qu1HywjY7bF2DwiDg@mail.gmail.com>
 <01000168e2913f2e-56010847-a10b-407e-b4eb-7730164267de-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000168e2913f2e-56010847-a10b-407e-b4eb-7730164267de-000000@email.amazonses.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 12-02-19 16:36:36, Christopher Lameter wrote:
> On Mon, 11 Feb 2019, Dan Williams wrote:
> 
> > An mmap write after a fault due to a hole punch is free to trigger
> > SIGBUS if the subsequent page allocation fails. So no, I don't see
> > them as the same unless you're allowing for the holder of the MR to
> > receive a re-fault failure.
> 
> Order 0 page allocation failures are generally not possible in that path.
> System will reclaim and OOM before that happens.

But also block allocation can fail in the filesystem or you can have memcgs
set up that make the page allocation fail, can't you? So in principle Dan
is right. Page faults can and do fail...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

