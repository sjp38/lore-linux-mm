Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 661AFC2BCA1
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 00:11:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 197B720868
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 00:11:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 197B720868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3DC66B0276; Fri,  7 Jun 2019 20:11:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EE9F6B0278; Fri,  7 Jun 2019 20:11:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DE486B0279; Fri,  7 Jun 2019 20:11:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 529706B0276
	for <linux-mm@kvack.org>; Fri,  7 Jun 2019 20:11:42 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d22so2473284pgg.2
        for <linux-mm@kvack.org>; Fri, 07 Jun 2019 17:11:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9CbAY1HigVPB7K8XVj5rYJfAE+/UpCK4RfaLDRQIyQ4=;
        b=DDjHk2nJvgGd/ijudxVGLayswArNKa/UqMu1ylRgvoMa5BE0qEqCStxoBUi6w487OX
         sE6WLu5qDVXrLwaPbAlbJz1JswqN1L/qzVUgG9Es4TDtRpQusfBDHXosKV3wDDMmbCq3
         zdAorcnHpCbxmHsRX0HBVKDCHhmqn6gQsHSdsEkhI/ex2Ii+Abo5JcGScQ3GITcsEVvs
         U0U9yjOG0S03d86+KZM2sIwgGBD4iakanO9xsCkUA+8wEJN2sxwb87Ru2es4IJg4VvIg
         ONlX60tifwyf4JkrdsS9PZxr9o06YnfP7OVi+aL3+vrev1G87n/vjB4hNX2uqiNKF2dN
         gLnw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAXIW3ThU0ptdZSJa4O0bysAC+XRGXkGGCHvWSbFJ6KfkdMQs1Dq
	yhLicDMrnKS2c1pGQfWC0FGziBpLiTi7FaOVo1byYTwjtHH1KneCI6LDmqLK5XO3GKTqNhCAUHJ
	AmKEIuuIzB36/ZmJGvyEu3v3lbKWgtgHYrg4Ls0lHxJZ6F8/3BwLKg207ArWAYlc=
X-Received: by 2002:a62:bd03:: with SMTP id a3mr4417573pff.209.1559952701977;
        Fri, 07 Jun 2019 17:11:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTPsgn24HH/pkMnEUkz6u/JfwpYfxwC8X1vWelugCezWnGzHBdjcLZIFJ07HIv0U7H3pDh
X-Received: by 2002:a62:bd03:: with SMTP id a3mr4417532pff.209.1559952701158;
        Fri, 07 Jun 2019 17:11:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559952701; cv=none;
        d=google.com; s=arc-20160816;
        b=yhcWhDbbXIRPVKTqpof9fnW3Y/2Pz4L4i7w1Kwb3zZlcUkj8WU6zoL+tvdX5CCVk5i
         UGogSXaKnbS4Ave4J7yDlUZydjQtHx6Rslque4WX0K5BVWzpoxa+GGcsorgkoYsJHydg
         OXwDbiMGIJXf7qos7CRyd7uxWOHTG6LWbRODpXd2T1yF5H9memoEgBV9M/bY0Jd/i80m
         CgSyG+KlQRd1EWGsxgJUDcRrrbPbSbGFPLU5gM59aX0dYWcD+la48VrVWQtGoq0Eh5eW
         xRjayZpz5+jt/GKMFDFIkL82/3gSC+KNKS8I1BRy9a47vxM2HFOVS5mE1hX6+1skAymX
         YJ2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9CbAY1HigVPB7K8XVj5rYJfAE+/UpCK4RfaLDRQIyQ4=;
        b=iSybSlS+uS+8rjmg9oHZYsKgVPK23P77SZV+X5+lM/TGfmC1Lp7M2S4utVLkuQsH8L
         t4ovlRNL130z8fIiPpzjXusvhLi8vrHBDQ1ADgRlH+yUeWy23fbG3xQjJ7tvhvX8KQSw
         R3iQeQhXEg7yJAaWQxAQLmIchNEG1+RkJWb0bJTeKCPMbASKZ7c+r/EkdsizGj3yROy6
         DhXruBCbHcQhyFxClOUkEE9c+pHdhXH/owjkDnD+80ertucMRjJb6or8qLMJtoRDPlGD
         YZWelxRPevX5zHZWOimLOYVAbqxqP1jnAw9Kc80TqZrnyDVxeM9Ra7BZZBpYU3EDKR8S
         Wz7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id d1si3322473pgg.412.2019.06.07.17.11.40
        for <linux-mm@kvack.org>;
        Fri, 07 Jun 2019 17:11:41 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-195-189-25.pa.nsw.optusnet.com.au [49.195.189.25])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id 946BC43E794;
	Sat,  8 Jun 2019 10:11:34 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hZOwO-0001iX-35; Sat, 08 Jun 2019 10:10:36 +1000
Date: Sat, 8 Jun 2019 10:10:36 +1000
From: Dave Chinner <david@fromorbit.com>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Jan Kara <jack@suse.cz>, Dan Williams <dan.j.williams@intel.com>,
	Theodore Ts'o <tytso@mit.edu>, Jeff Layton <jlayton@kernel.org>,
	Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-nvdimm@lists.01.org, linux-ext4@vger.kernel.org,
	linux-mm@kvack.org, Jason Gunthorpe <jgg@ziepe.ca>,
	linux-rdma@vger.kernel.org
Subject: Re: [PATCH RFC 00/10] RDMA/FS DAX truncate proposal
Message-ID: <20190608001036.GF14308@dread.disaster.area>
References: <20190606014544.8339-1-ira.weiny@intel.com>
 <20190606104203.GF7433@quack2.suse.cz>
 <20190606220329.GA11698@iweiny-DESK2.sc.intel.com>
 <20190607110426.GB12765@quack2.suse.cz>
 <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190607182534.GC14559@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0 cx=a_idp_d
	a=K5LJ/TdJMXINHCwnwvH1bQ==:117 a=K5LJ/TdJMXINHCwnwvH1bQ==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=dq6fvYVFJ5YA:10
	a=QyXUC8HyAAAA:8 a=7-415B0cAAAA:8 a=q-LccRbQMXva6PWEi7oA:9
	a=CjuIK1q_8ugA:10 a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 11:25:35AM -0700, Ira Weiny wrote:
> On Fri, Jun 07, 2019 at 01:04:26PM +0200, Jan Kara wrote:
> > On Thu 06-06-19 15:03:30, Ira Weiny wrote:
> > > On Thu, Jun 06, 2019 at 12:42:03PM +0200, Jan Kara wrote:
> > > > On Wed 05-06-19 18:45:33, ira.weiny@intel.com wrote:
> > > > > From: Ira Weiny <ira.weiny@intel.com>
> > > > 
> > > > So I'd like to actually mandate that you *must* hold the file lease until
> > > > you unpin all pages in the given range (not just that you have an option to
> > > > hold a lease). And I believe the kernel should actually enforce this. That
> > > > way we maintain a sane state that if someone uses a physical location of
> > > > logical file offset on disk, he has a layout lease. Also once this is done,
> > > > sysadmin has a reasonably easy way to discover run-away RDMA application
> > > > and kill it if he wishes so.
> > > 
> > > Fair enough.
> > > 
> > > I was kind of heading that direction but had not thought this far forward.  I
> > > was exploring how to have a lease remain on the file even after a "lease
> > > break".  But that is incompatible with the current semantics of a "layout"
> > > lease (as currently defined in the kernel).  [In the end I wanted to get an RFC
> > > out to see what people think of this idea so I did not look at keeping the
> > > lease.]
> > > 
> > > Also hitch is that currently a lease is forcefully broken after
> > > <sysfs>/lease-break-time.  To do what you suggest I think we would need a new
> > > lease type with the semantics you describe.
> > 
> > I'd do what Dave suggested - add flag to mark lease as unbreakable by
> > truncate and teach file locking core to handle that. There actually is
> > support for locks that are not broken after given timeout so there
> > shouldn't be too many changes need.
> >  
> > > Previously I had thought this would be a good idea (for other reasons).  But
> > > what does everyone think about using a "longterm lease" similar to [1] which
> > > has the semantics you proppose?  In [1] I was not sure "longterm" was a good
> > > name but with your proposal I think it makes more sense.
> > 
> > As I wrote elsewhere in this thread I think FL_LAYOUT name still makes
> > sense and I'd add there FL_UNBREAKABLE to mark unusal behavior with
> > truncate.
> 
> Ok I want to make sure I understand what you and Dave are suggesting.
> 
> Are you suggesting that we have something like this from user space?
> 
> 	fcntl(fd, F_SETLEASE, F_LAYOUT | F_UNBREAKABLE);

Rather than "unbreakable", perhaps a clearer description of the
policy it entails is "exclusive"?

i.e. what we are talking about here is an exclusive lease that
prevents other processes from changing the layout. i.e. the
mechanism used to guarantee a lease is exclusive is that the layout
becomes "unbreakable" at the filesystem level, but the policy we are
actually presenting to uses is "exclusive access"...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

