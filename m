Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4B4BFC468BC
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 11:04:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D405208E3
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 11:04:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D405208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B06096B026E; Fri,  7 Jun 2019 07:04:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8FC26B026F; Fri,  7 Jun 2019 07:04:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97FAD6B0271; Fri,  7 Jun 2019 07:04:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 478276B026E
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 07:04:29 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y22so2602779eds.14
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 04:04:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=XuiDkb5rNLsM8Gf8zF7JjHy81BNSoLoXBtlVkVh534A=;
        b=XiWrQjn/aMvRYEEgu1Tw+2PPv2f92YzUar29yk9FPA2H+G4NWmVDKHOXZKadwSfi6c
         X2pVz4QT89eUUg2LJxkCIOpVhuKLTPVZvSYNHcHrxW4PsI1hKLD6Lt8toDIWwsGswi8C
         1yecfuSX/sxqeTfykUkbIxkM2/9ApHUFHOmw6O4PYBL54wjRb2u+05VRQcbrTOf+mqXg
         /V20wzD6kxkPCT+GF3H+T8ThAkJDv6B26Tqjg0Aelmwv98yE4mNYUgUW1G5WgXqndmK1
         AkGrvpYgLDFehDcZRMgopRnyLz5Mvb1LIKDNXnXlWaWEFdFSf8M2ur5X+3v/Pfj5u3wH
         LwSA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAXRk46tlDC4CZnAO1PRYAmddqcfk7Fh+/wP3usahiIN8xj77COR
	zFzYqsFlThAQrHalUd0NHfw5VvHeDcqBpdyDJTfnwT97Fg991UOUclgeq2wnAB/yxChJeA+7yMO
	GAb/ii1LGa16wdyIuhF0S+7PSuUBUQ9CbXQ+UphUYkqxB6PpsBnlitzIwy81ocejKGQ==
X-Received: by 2002:a50:9758:: with SMTP id d24mr19331376edb.203.1559905468814;
        Fri, 07 Jun 2019 04:04:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3/ci7op/5bz+yPYLNTldvHa8MpA6rRYZI0Ezz1Du1Bls7Ku24mYXsyFvIrtE8ZCsNOzrm
X-Received: by 2002:a50:9758:: with SMTP id d24mr19331284edb.203.1559905467931;
        Fri, 07 Jun 2019 04:04:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559905467; cv=none;
        d=google.com; s=arc-20160816;
        b=c4UfF/pWQPazR91SGK+7NDw98+SurnhC2vzcI0otaScmO7TUdQRbk6/h+9+2DXD8uK
         lv3DqkZuIijiejvXnjYW54NIBSxVJYQxTqbe4JGwsyS95S7n/1CfVh7+fAiYtwUkxKAs
         lOed+WRRpM+0uiHxuCFRzJdXQANSx+QWx9tX3rmWS3ktWgCO8LtNtdS01Knb/9Rb3ugm
         p1I2l1VNBs5V7AbrNKP3NrOSeYr8rTxezsgaq0/mxMWGFlk2khwVDjj21U34EMdLPp/I
         yOWYcwc2PKFNiI7clP/HXzm70LTw7jwPPFfv015X8jYUiuqBDf7wAFEy7oDkfebvQ28e
         Bltw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=XuiDkb5rNLsM8Gf8zF7JjHy81BNSoLoXBtlVkVh534A=;
        b=Qfxvi37elgGmslM17wzbG5RrdpSPrnjStt8iO3wORH9n8QBNdOE5pWJ5ecLgX/5I52
         X+9QtehFwKRqEZoA8niDTAV2IyjXMBLBhPRUtQTAYVmRUIS2zwbPTz8HyE0XR93QN8F5
         RijkXbicpJJjRrcNyQCRkViFw4hk7ZTnrvsVyWQ01fS39k6RVKDlKox3f8/bz0GLj30k
         UxMq6SuxXmPML/BqoBmJjVsd1g5axAQS9uvmC0dlq5FTPIX3u0/+QQd5g0JYUzP9QjyJ
         /cPbdMLOf0ILi02p5OBt9DcIt+Uoy2xqAGn5QXDMH5PqGOL7k8UaKvI3pGxj1PYReagd
         pmiA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p14si911753ejj.111.2019.06.07.04.04.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 04:04:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0B6BFAE91;
	Fri,  7 Jun 2019 11:04:27 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 41D0F1E3FCA; Fri,  7 Jun 2019 13:04:26 +0200 (CEST)
Date: Fri, 7 Jun 2019 13:04:26 +0200
From: Jan Kara <jack@suse.cz>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org, Jason Gunthorpe <jgg@ziepe.ca>,
	linux-rdma@vger.kernel.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190607110426.GB12765@quack2.suse.cz>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 06-06-19 15:03:30, Ira Weiny wrote:
> On Thu, Jun 06, 2019 at 12:42:03PM +0200, Jan Kara wrote:
> > On Wed 05-06-19 18:45:33, ira.weiny@intel.com wrote:
> > > From: Ira Weiny <ira.weiny@intel.com>
> > 
> > So I'd like to actually mandate that you *must* hold the file lease until
> > you unpin all pages in the given range (not just that you have an option to
> > hold a lease). And I believe the kernel should actually enforce this. That
> > way we maintain a sane state that if someone uses a physical location of
> > logical file offset on disk, he has a layout lease. Also once this is done,
> > sysadmin has a reasonably easy way to discover run-away RDMA application
> > and kill it if he wishes so.
> 
> Fair enough.
> 
> I was kind of heading that direction but had not thought this far forward.  I
> was exploring how to have a lease remain on the file even after a "lease
> break".  But that is incompatible with the current semantics of a "layout"
> lease (as currently defined in the kernel).  [In the end I wanted to get an RFC
> out to see what people think of this idea so I did not look at keeping the
> lease.]
> 
> Also hitch is that currently a lease is forcefully broken after
> <sysfs>/lease-break-time.  To do what you suggest I think we would need a new
> lease type with the semantics you describe.

I'd do what Dave suggested - add flag to mark lease as unbreakable by
truncate and teach file locking core to handle that. There actually is
support for locks that are not broken after given timeout so there
shouldn't be too many changes need.
 
> Previously I had thought this would be a good idea (for other reasons).  But
> what does everyone think about using a "longterm lease" similar to [1] which
> has the semantics you proppose?  In [1] I was not sure "longterm" was a good
> name but with your proposal I think it makes more sense.

As I wrote elsewhere in this thread I think FL_LAYOUT name still makes
sense and I'd add there FL_UNBREAKABLE to mark unusal behavior with
truncate.

> > - probably I'd just transition all gup_longterm()
> > users to a saner API similar to the one we have in mm/frame_vector.c where
> > we don't hand out page pointers but an encapsulating structure that does
> > all the necessary tracking.
> 
> I'll take a look at that code.  But that seems like a pretty big change.

I was looking into that yesterday before proposing this and there aren't
than many gup_longterm() users and most of them anyway just stick pages
array into their tracking structure and then release them once done. So it
shouldn't be that complex to convert to a new convention (and you have to
touch all gup_longterm() users anyway to teach them track leases etc.).

> > Removing a lease would need to block until all
> > pins are released - this is probably the most hairy part since we need to
> > handle a case if application just closes the file descriptor which would
> > release the lease but OTOH we need to make sure task exit does not deadlock.
> > Maybe we could block only on explicit lease unlock and just drop the layout
> > lease on file close and if there are still pinned pages, send SIGKILL to an
> > application as a reminder it did something stupid...
> 
> As presented at LSFmm I'm not opposed to killing a process which does not
> "follow the rules".  But I'm concerned about how to handle this across a fork.
> 
> Limiting the open()/LEASE/GUP/close()/SIGKILL to a specific pid "leak"'s pins
> to a child through the RDMA context.  This was the major issue Jason had with
> the SIGBUS proposal.
> 
> Always sending a SIGKILL would prevent an RDMA process from doing something
> like system("ls") (would kill the child unnecessarily).  Are we ok with that?

I answered this in another email but system("ls") won't kill anybody.
fork(2) just creates new file descriptor for the same file and possibly
then closes it but since there is still another file descriptor for the
same struct file, the "close" code won't trigger.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

