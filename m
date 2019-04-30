Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FDE6C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 21:21:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5045721743
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 21:21:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5045721743
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D46BA6B0006; Tue, 30 Apr 2019 17:21:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCF796B0008; Tue, 30 Apr 2019 17:21:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B227A6B000A; Tue, 30 Apr 2019 17:21:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 752406B0006
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 17:21:52 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id a5so7824020plh.14
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 14:21:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2hPviv8xRYg+AFMPDLG14mbBxPHiU8+jz24E+VkTzBw=;
        b=KYYP9idjTNuvKVJEHElpLKrKkz+eY26fOMktOLuav2CiNDO/1Xol6iQ9DUTfvSh8b4
         etkctsAe7mo+CJv9I5SGrX1oxxCEptivl/6q/QjnXG0GdQ5PTCRlgr1qRJh4MrxAD5VY
         9V/bC2Wud0NdQyfZQceKgu5BgBQA5Lcu37M777ii83YNyet34RqGW+NoBpAmy821OiNH
         6VXlSLg6ySYOBeiEoxe690XeKD3tloSI0HYCVCaAvGH1Z1ePb30T2Ha3wH95kLtmmenM
         l+s+zkESc7L93aJNz3nmt1MdMvA6CVbkEoWgG/u4pvUH1p4rBTHiXCILfbevqx2As6/Q
         69oA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAUxbSJMdLMw31YyBsoHjy2SgAnod1TKwbUs5o15arYn9sdb6TOn
	BrVw2bnXPU2Y9RQUZM8ugDBdlxLwQ0pM820vEvekE0S0219ynZp+MvwIUYOpNqe0vd8QYV9LYtY
	ftJzrUd3MrhUN3qmnx+zUhcKVQjgNjHfBkmp0hQbHGOYBdi9z9Z/DebjVSRTaTGw=
X-Received: by 2002:a63:2ace:: with SMTP id q197mr68191721pgq.371.1556659312144;
        Tue, 30 Apr 2019 14:21:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvFrDyh1Iu25P7x1Uw4/BDKZKn87SIZhhjePHjLTY5457e8ReYHBLXJUeAVki0bvZMKtWW
X-Received: by 2002:a63:2ace:: with SMTP id q197mr68191644pgq.371.1556659311383;
        Tue, 30 Apr 2019 14:21:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556659311; cv=none;
        d=google.com; s=arc-20160816;
        b=0D/b1PqMI3gWzN6Mc6kJ7303AsUrvgalqXLQHhqGvkzWMHoBoj+LHKxGX6i48vK3Ib
         83eYYMAThVncCPRPIlpoPYObd5w4Md7veTHAbB08zo3QhI0EWKUZxUpWN6TxvF898pHQ
         v3d07+3iSBNIlXuby5LHwWGUqdVibFWpq5NXlfq/fVrQzs0wupj7HEEewNANbwggYqk1
         k3IfHA0V5JiXUftubWeZM7wGkeBehTW7I5yxaWyK6IdXyvYIUEIwtwwp2PeAdZJHMoCQ
         fqXugdQ4uDplOh/+w1dghE/bBYwdTyUax0UGixnhMRMFmdKjuS1UW5z98o0IwI6Olp/J
         KACA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2hPviv8xRYg+AFMPDLG14mbBxPHiU8+jz24E+VkTzBw=;
        b=AUob1048AH854jv57jj3mztsRT24YlM+r7+WAy1VG6plU6LEu0zPSmgbC66IQVZfzR
         /Q6VbWSkHTquWFL7fLir+W+pioRO2mssj0M+uDlwW7hVYZS5iLFS6bbx7MQSvK1VpXDU
         ugRPot7beT94sb2Te/c0O7k0T1BndWXQlWOp4sm+AWom6iwo8Lvit4zp1KMtSRlvv59h
         REfoOJEBTdP9JiSyRhODfdARwn57FEnAaMkX/xZjkPRD55jrRQHUu1lkcjj8o6vhaAbp
         x6hfVZ30SLb8sP1Vle4zpWSJfRp45Y5lOOt3lpkeGUVbfZ8AnSeuMK+jF0yLNuyu2q9T
         TWfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail104.syd.optusnet.com.au (mail104.syd.optusnet.com.au. [211.29.132.246])
        by mx.google.com with ESMTP id x6si23816881pln.74.2019.04.30.14.21.50
        for <linux-mm@kvack.org>;
        Tue, 30 Apr 2019 14:21:51 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.246;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.246 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-171-240.pa.nsw.optusnet.com.au [49.181.171.240])
	by mail104.syd.optusnet.com.au (Postfix) with ESMTPS id 77CA143A20F;
	Wed,  1 May 2019 07:21:48 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hLaCA-0004HS-TP; Wed, 01 May 2019 07:21:46 +1000
Date: Wed, 1 May 2019 07:21:46 +1000
From: Dave Chinner <david@fromorbit.com>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Andreas Gruenbacher <agruenba@redhat.com>, cluster-devel@redhat.com,
	Christoph Hellwig <hch@lst.de>, Bob Peterson <rpeterso@redhat.com>,
	Jan Kara <jack@suse.cz>, Ross Lagerwall <ross.lagerwall@citrix.com>,
	Mark Syms <Mark.Syms@citrix.com>,
	Edwin =?iso-8859-1?B?VPZy9ms=?= <edvin.torok@citrix.com>,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v7 0/5] iomap and gfs2 fixes
Message-ID: <20190430212146.GL1454@dread.disaster.area>
References: <20190429220934.10415-1-agruenba@redhat.com>
 <20190430025028.GA5200@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190430025028.GA5200@magnolia>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=UJetJGXy c=1 sm=1 tr=0 cx=a_idp_d
	a=LhzQONXuMOhFZtk4TmSJIw==:117 a=LhzQONXuMOhFZtk4TmSJIw==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=E5NmQfObTbMA:10
	a=7-415B0cAAAA:8 a=JuDxSlhT3OO6blO4plAA:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Apr 29, 2019 at 07:50:28PM -0700, Darrick J. Wong wrote:
> On Tue, Apr 30, 2019 at 12:09:29AM +0200, Andreas Gruenbacher wrote:
> > Here's another update of this patch queue, hopefully with all wrinkles
> > ironed out now.
> > 
> > Darrick, I think Linus would be unhappy seeing the first four patches in
> > the gfs2 tree; could you put them into the xfs tree instead like we did
> > some time ago already?
> 
> Sure.  When I'm done reviewing them I'll put them in the iomap tree,
> though, since we now have a separate one. :)

I'd just keep the iomap stuff in the xfs tree as a separate set of
branches and merge them into the XFS for-next when composing it.
That way it still gets plenty of test coverage from all the XFS
devs and linux next without anyone having to think about.

You really only need to send separate pull requests for the iomap
and XFS branches - IMO, there's no really need to have a complete
new tree for it...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

