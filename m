Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DBD4C31E45
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 03:08:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1ED1C2073F
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 03:08:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1ED1C2073F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ACF848E0003; Thu, 13 Jun 2019 23:08:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A806A8E0002; Thu, 13 Jun 2019 23:08:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 971318E0003; Thu, 13 Jun 2019 23:08:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 61C5C8E0002
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 23:08:13 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x18so748262pfj.4
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 20:08:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/+fko4Aj3rJ5d20VyKwO7ie8N8MdaHUZgWsv1+S7BjE=;
        b=UYCLKAvcwL7IAmJfn9F9bAyh0MVHTwhCmEUY9mA++w6DQnVglpP+n9iFi94euSmcHn
         TCzXJvwwZm4QptS3Rgcu5dvgHQEPC0YBq9NT1bKVpXjDv+Rw2b/6TN0lWEMNaIMCdvhW
         1l/1RHezIDP0HoLcYwLiHetghWPp31Qz35mHu+2b8TXVuz/UJlLzt8hHQT7jnMZ3WebP
         CctphAJ2Tc8gfCEY0Z4EKwiZMqNtLcs6QpodAXewMgqlPcGH+gxM4ajcr1gTkwdhc8Qv
         mjV483pSQCgcmX9UibkrAsdDFD7DOiFO8PYOsy0HgdJkPV8ARLd9q60X5AiF/y+mXjq+
         QQ+g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXxje8LQpenngNP8MRcx83H6HcV2rbPlS+K3XwKslNlBH0YiLzx
	HmcT9tXi6pahr/j+4fFnDOAr5q8aNtw6JI3LXCar5TWe7eO8ccIb/7LjeAI7rzKOMpnWDU0PphP
	SSTdH6/3guYe1mmV81e4zJ0Ff8STzEauma1zNuorAD/3puf+fTUNspRjBRqCXhCM=
X-Received: by 2002:a65:51cb:: with SMTP id i11mr32627059pgq.390.1560481692962;
        Thu, 13 Jun 2019 20:08:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxp7n3PMa1hPFG1DAQ7V9ZklwN8G1jKyNRMn18+2O3Iqa2VHevA9kwcKy17tUSlLMCv8t1F
X-Received: by 2002:a65:51cb:: with SMTP id i11mr32627020pgq.390.1560481692254;
        Thu, 13 Jun 2019 20:08:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560481692; cv=none;
        d=google.com; s=arc-20160816;
        b=kkuMJAfP4rla9duRWU5zd5UIG4qnjvOXxaDaFo6V03nSw3f+AOQTb27nYEF4zrglJ0
         dxqQ85LlrcBFLb2603wB+L+RUqIWUW4dywVRgkEwbNCl3Fi09zz4AVexspSk3/TS8djv
         aQFWBCqWp8vXaome/Sdq2ukLZmUhbRoGQlKTawTGTZibhono9yy0N5lGMtbxnD/MlD/R
         CZBbQhVKcJXr+zWmZkPRh2WXWTS269+mi1lVXbz2J3T5mueySH6bQ5NC076pi12mn3JD
         xm5iR+qkOUVIGrFcEvFSQzMESR1/AtkdHRzU7aoqhjqiQBsHpCdDPIv6eMIxzXLDT0aR
         9knA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/+fko4Aj3rJ5d20VyKwO7ie8N8MdaHUZgWsv1+S7BjE=;
        b=zbFOa3RSwTeA7Vh697GP8Cjnf1Sa9AsCdeDptFOS44Jb7yZJ9POSQYL36aRRrzTD94
         1KWXTGmRB9AEbkSHj34d6OGtAcpOLVS8GtCtdO2XFPvRXni8c52WoliOqCpgJZfFuTsW
         rwaeE4yEDKfwh9pa7lONaj+k/pBYJ/DqMePkTNaeyDVzrc4LKOwdthe3IH0n6ld4XkmX
         /MS7X+dDH9jwf1DFlqtpq7r/qlXLZ66cP4EqtekBXBiDJFXGnk9T/XeJDtjI8Dm2k3rp
         2X0x5lu7EQPbw4tsm6dzz14Cf+GFkhAK1o3VAcHaI3XlJKz4s7oh0JGiR57QfNp8bjVR
         Bshw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail106.syd.optusnet.com.au (mail106.syd.optusnet.com.au. [211.29.132.42])
        by mx.google.com with ESMTP id b188si1130959pfa.8.2019.06.13.20.08.11
        for <linux-mm@kvack.org>;
        Thu, 13 Jun 2019 20:08:12 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.42;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.42 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-189-25.pa.nsw.optusnet.com.au [49.195.189.25])
	by mail106.syd.optusnet.com.au (Postfix) with ESMTPS id ACCE93DD56B;
	Fri, 14 Jun 2019 13:08:09 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hbcYa-0005cJ-7D; Fri, 14 Jun 2019 13:07:12 +1000
Date: Fri, 14 Jun 2019 13:07:12 +1000
From: Dave Chinner <david@fromorbit.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org, linux-rdma@vger.kernel.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190614030712.GO14363@dread.disaster.area>
References: <20190607110426.GB12765@quack2.suse.cz>
 <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
 <20190608001036.GF14308@dread.disaster.area>
 <20190612123751.GD32656@bombadil.infradead.org>
 <20190613002555.GH14363@dread.disaster.area>
 <20190613152755.GI32656@bombadil.infradead.org>
 <20190613211321.GC32404@iweiny-DESK2.sc.intel.com>
 <20190613234530.GK22901@ziepe.ca>
 <20190614020921.GM14363@dread.disaster.area>
 <20190614023107.GK32656@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190614023107.GK32656@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=D+Q3ErZj c=1 sm=1 tr=0 cx=a_idp_d
	a=K5LJ/TdJMXINHCwnwvH1bQ==:117 a=K5LJ/TdJMXINHCwnwvH1bQ==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=dq6fvYVFJ5YA:10
	a=7-415B0cAAAA:8 a=8i7XV5XKZheqFIjFUW4A:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 07:31:07PM -0700, Matthew Wilcox wrote:
> On Fri, Jun 14, 2019 at 12:09:21PM +1000, Dave Chinner wrote:
> > If the lease holder modifies the mapping in a way that causes it's
> > own internal state to screw up, then that's a bug in the lease
> > holder application.
> 
> Sounds like the lease semantics aren't the right ones for the longterm
> GUP users then.  The point of the longterm GUP is so the pages can be
> written to, and if the filesystem is going to move the pages around when
> they're written to, that just won't work.

And now we go full circle back to the constraints we decided on long
ago because we can't rely on demand paging RDMA hardware any time
soon to do everything we need to transparently support long-term GUP
on file-backed mappings. i.e.:

	RDMA to file backed mappings must first preallocate and
	write zeros to the range of the file they are mapping so
	that the filesystem block mapping is complete and static for
	the life of the RDMA mapping that will pin it.

IOWs, the layout lease will tell the RDMA application that the
static setup it has already done  to work correctly with a file
backed mapping may be about to be broken by a third party.....

-Dave.
-- 
Dave Chinner
david@fromorbit.com

