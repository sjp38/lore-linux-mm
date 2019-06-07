Return-Path: <SRS0=5PTg=UG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5B3DC2BCA1
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 10:46:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99832212F5
	for <linux-mm@archiver.kernel.org>; Fri,  7 Jun 2019 10:46:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99832212F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4353E6B0266; Fri,  7 Jun 2019 06:46:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C0096B0269; Fri,  7 Jun 2019 06:46:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 262BA6B026A; Fri,  7 Jun 2019 06:46:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C928F6B0266
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 06:46:38 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f15so2558622ede.8
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 03:46:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RECYSjvI9ZfDczF+NT4WqhV0GfP/e9d47hPtBnGHBTk=;
        b=C2ZAGRPBKtO8fTcJI6znQRMRax3EpiyjVjzktjTEEFScmrFqsZT/RS1LfqkTf7G64s
         BBXrch9hrgqp6RnSQB3ZM7Tf0wNLZQ2GoHWPa6WO8Mb12+pPn2iCO9+59fmmp9BECJU4
         TnNK8iS53IbByOEEJQP+/MabaHC/qiqmLZsKhbIs4XsZihRyAd12QGOsNE0xT27au5bM
         B1mVx1ZUz0uQwVF1ouClDa4Q3px1W16peotQYDBw6yf/7JrKpL9XeQVj1PqU1a90VrW6
         OoWEdseZIE6Px1eQ69397rS4819ASSi0wnM66oOBnp6AI2XGh3fvDNLSbQ3cpctyEe+u
         Dscg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAV7p4g5rgkhZ1sY433Kh7FhaUQU+0kbVk/UhfFTIuReckSkicKZ
	hBEbJXuthPOSoikf4WXUMPq3/7GoTFg3KBNg2fJvBtOjTnk1F1CxNOGyiWHDhzX5g3/jn0ZsAet
	RWCJCPjd4t45LMmi7TiaLpyccXpnUPG/Tk2ad0b0mn02ZitkELzVFPnZipwv1zAWTDw==
X-Received: by 2002:a17:906:60c7:: with SMTP id f7mr46056675ejk.107.1559904398353;
        Fri, 07 Jun 2019 03:46:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9ZYMbiwYthKtwsDU4pW1bdillM+ORqffLuJeVqeJDO9P+ygP3TAPH58tN3c8Tj7vI3yDt
X-Received: by 2002:a17:906:60c7:: with SMTP id f7mr46056614ejk.107.1559904397108;
        Fri, 07 Jun 2019 03:46:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559904397; cv=none;
        d=google.com; s=arc-20160816;
        b=OF8PWBcT2XxvKqnmzaDHAC9xQ5nhN4iJ0N/25HcDrriOdYs270aoj1+PG/+0pNLmAr
         JNtVKw+3DvBycuL0p8ODvD7nOwSNkCUAaXBxiqs3NP4Qmw77o2w+d+b8ZanW/5007N/e
         kEenEZMm+yr2zPs/Auav7/sV6lozaPI3iRaXkz8KDTjI1PZVDKfMTLo0ahWx0ZLUagVu
         ChnQoKoCufWv1PtAjZSbeJckkgUCwvn6Qi4zvRDu40NRmXJVbn7pAHJeglspDSc7nApA
         iSfFzfga8OQP7YOIB9cnYguPhzOPwWPhziop7ckyS2UJIQBhgEsSjMSlhFqSIN0DWP77
         NdgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RECYSjvI9ZfDczF+NT4WqhV0GfP/e9d47hPtBnGHBTk=;
        b=eL9OTfjJopKOR85bgLqfMMfDwIBgffc1z6Z/BHg9AsCSvqoABKZ97DNvGOkSnns1U3
         70onsZUaeNF0hAsojyFm1nJ2uh4OnVEUSKuWk4upXNEAavKwNpyr8zgHZHAEBSBMf36R
         gevTEGvufc0KheE+xF+8UOkSMzraFrTMFjB1vOeUMX/PsXWJbmm46KXIEahG1dCSAnSS
         vhSiUVCyRnIOihW6fIMJKCJEg/g9m3J6QJeHqN0K8VAvW05NzLpXQvq84dDZ3qwozkW5
         rsXaBuKwzZtASDb0XZjLUq0kxrgrbKQpBOQ0lK8SDhiHxb/Vcwtx0VTAb8ixPfMEgo22
         V9LA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q9si154831ejm.144.2019.06.07.03.46.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Jun 2019 03:46:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 471C9AF0A;
	Fri,  7 Jun 2019 10:46:36 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id DDD771E3FCA; Fri,  7 Jun 2019 12:36:36 +0200 (CEST)
Date: Fri, 7 Jun 2019 12:36:36 +0200
From: Jan Kara <jack@suse.cz>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	Dave Chinner <david@fromorbit.com>,
	Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190607103636.GA12765@quack2.suse.cz>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606195114.GA30714@ziepe.ca>
 <20190606222228.GB11698@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606222228.GB11698@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 06-06-19 15:22:28, Ira Weiny wrote:
> On Thu, Jun 06, 2019 at 04:51:15PM -0300, Jason Gunthorpe wrote:
> > On Thu, Jun 06, 2019 at 12:42:03PM +0200, Jan Kara wrote:
> > 
> > > So I'd like to actually mandate that you *must* hold the file lease until
> > > you unpin all pages in the given range (not just that you have an option to
> > > hold a lease). And I believe the kernel should actually enforce this. That
> > > way we maintain a sane state that if someone uses a physical location of
> > > logical file offset on disk, he has a layout lease. Also once this is done,
> > > sysadmin has a reasonably easy way to discover run-away RDMA application
> > > and kill it if he wishes so.
> > > 
> > > The question is on how to exactly enforce that lease is taken until all
> > > pages are unpinned. I belive it could be done by tracking number of
> > > long-term pinned pages within a lease. Gup_longterm could easily increment
> > > the count when verifying the lease exists, gup_longterm users will somehow
> > > need to propagate corresponding 'filp' (struct file pointer) to
> > > put_user_pages_longterm() callsites so that they can look up appropriate
> > > lease to drop reference - probably I'd just transition all gup_longterm()
> > > users to a saner API similar to the one we have in mm/frame_vector.c where
> > > we don't hand out page pointers but an encapsulating structure that does
> > > all the necessary tracking. Removing a lease would need to block until all
> > > pins are released - this is probably the most hairy part since we need to
> > > handle a case if application just closes the file descriptor which
> > > would
> > 
> > I think if you are going to do this then the 'struct filp' that
> > represents the lease should be held in the kernel (ie inside the RDMA
> > umem) until the kernel is done with it.
> 
> Yea there seems merit to this.  I'm still not resolving how this helps track
> who has the pin across a fork.

Yes, my thought was that gup_longterm() would return a structure that would
be tracking filp (or whatever is needed) and that would be embedded inside
RDMA umem.

> > Actually does someone have a pointer to this userspace lease API, I'm
> > not at all familiar with it, thanks
> 
> man fcntl
> 	search for SETLEASE
> 
> But I had to add the F_LAYOUT lease type.  (Personally I'm for calling it
> F_LONGTERM at this point.  I don't think LAYOUT is compatible with what we are
> proposing here.)

I think F_LAYOUT still expresses it pretty well. The lease is pinning
logical->physical file offset mapping, i.e. the file layout.

> > 
> > And yes, a better output format from GUP would be great..
> > 
> > > Maybe we could block only on explicit lease unlock and just drop the layout
> > > lease on file close and if there are still pinned pages, send SIGKILL to an
> > > application as a reminder it did something stupid...
> > 
> > Which process would you SIGKILL? At least for the rdma case a FD is
> > holding the GUP, so to do the put_user_pages() the kernel needs to
> > close the FD. I guess it would have to kill every process that has the
> > FD open? Seems complicated...
> 
> Tending to agree...  But I'm still not opposed to killing bad actors...  ;-)
> 
> NOTE: Jason I think you need to be more clear about the FD you are speaking of.
> I believe you mean the FD which refers to the RMDA context.  That is what I
> called it in my other email.

I keep forgetting that the file with RDMA context may be held by multiple
processes so thanks for correcting me. My proposal with SIGKILL was jumping
to conclusion too quickly :) We have two struct files here: A file with RDMA
context that effectively is the owner of the page pins (let's call it
"context file") and a file which is mapped and on which we hold the lease and
whose blocks (pages) we are pinning (let's call it "buffer file"). Now once
buffer file is closed (and this means that all file descriptors pointing to
this struct file are closed - so just one child closing the file descriptor
won't trigger this) we need to release the lease and I want to have a way
of safely releasing remaining pins associated with this lease as well.
Because the pins would be invisible to sysadmin from that point on. Now if
the context file would be open only by the process closing the buffer file,
SIGKILL would work as that would close the buffer file as a side effect.
But as you properly pointed out, that's not necessarily the case. Walking
processes that have the context file open is technically complex and too
ugly to live so we have to come up with something better. The best I can
currently come up with is to have a method associated with the lease that
would invalidate the RDMA context that holds the pins in the same way that
a file close would do it.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

