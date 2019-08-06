Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 051D0C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:38:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C46F62189F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 21:38:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C46F62189F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 73F9A6B0003; Tue,  6 Aug 2019 17:38:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6E5606B0006; Tue,  6 Aug 2019 17:38:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D4DC6B0007; Tue,  6 Aug 2019 17:38:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 358E86B0003
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 17:38:17 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id n1so49034526plk.11
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 14:38:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=D59VcNlhXM/yYkipbpXWg7dwEUxsEgO6FiZhL9Ee+N0=;
        b=cSiPqzMf6F/Zdz3OMGWI5eMM+2BverRKLN/fbM7p2utVBBtY2afqlue86LgMLN9q0E
         vd4vVA1Xs39dR7YXqfn6YH9U+AX6BLad9u467fPCU8duUDJ7Qqr8ICIKSZXAddhMW76a
         3n2itxgakMdONnMHPkgeiaP1wDL/WpvuBCKpPjhD4VQQE7SNOSkC/r5DEiXC3ZRnosRE
         FIYPOQvSZFt4VYLq7PX7T3NgxwxONZpLz7u0SAwBfZMCLG6JyKzTG7Y7cf5LN1bgYMGn
         WtISxCW47EEjGhzuu0UzbwxMJ6ykUDa3LK2+2Kyn5d9dHkYbcAeuAm5M+9VXFr+DLXBg
         VRYw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: APjAAAVKbAbva7WNs+KuGIOxPJ55bsbo9K/SH7qW+5UeuDOIR489fx5T
	FdphwrelhzD8QEgkYDs2iV5UZm4bTWpIgRJ6qbu/aCJnhmpJn8rIRK/q7AiWPonhRuD5jOuXrPQ
	lXPLyHyz/wrZ0l9rvzv/kXHlfjCMzOq7O3WbEosjHJx09ZMhThScb67UPyvEn58s=
X-Received: by 2002:a17:902:9688:: with SMTP id n8mr4952713plp.227.1565127496920;
        Tue, 06 Aug 2019 14:38:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxcLrFcBdMCbel7h9F9535sgasEVFL3vBiVDfHXcz4qiov6kIj5mgiHrlS/iC1NnutLL5r8
X-Received: by 2002:a17:902:9688:: with SMTP id n8mr4952689plp.227.1565127496340;
        Tue, 06 Aug 2019 14:38:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565127496; cv=none;
        d=google.com; s=arc-20160816;
        b=rJHHqUIK3Y9Bfn49JczNu5EwhLYe3VYHEp5fl/q0oQgwMVhl5i4e9NpReRvFgV6bqT
         fZ+jU1Ak9ba6Rm2TK0+p70aEKnQYnHA2RwPlmTNws4PEav8jy1ZdvpeFLC/ei3uZM2Mk
         fVjwkhR37FH+HVNsii3oMAoHIq3OO3FGwO5iN3TbJstLmlMjtqz8etfscxL6fPmKAwIg
         6jbLNk1n1IUkdFApg2s4mSe48IMyOSQHUHr242Om1pJ9CY3fWa2nslWuzuNJMkg2ZhVa
         xPyD/kddWnJ/ls+63AcUG5W9MkwiJrXvkGbo3+geiMaJaqXfHG00PVtTrDzn+PFmALXn
         4T8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=D59VcNlhXM/yYkipbpXWg7dwEUxsEgO6FiZhL9Ee+N0=;
        b=qlrkUNWR+Qsyf49Ra7X5udj2FFbBuYlO/djfwQi5ehmxGXJmMvLYERMALW0TNF/cjJ
         ctWIAvhXsvxQDfsnkWzClKVZHtcdPb+aIqw1XDg3TBUHHbqfwHPiEf7xiEt0GlVhkygU
         SvVVyScVDohYNYQtjiZt7bU8/2RqPIEXEbBPI1rknCX+XnMRN0re3nM00YGU3PZBSCer
         S19N1C7PstlctIfHeDQ42zzC4BWkBowCGGvghQDAY0nrREwH808hp6Gqs1aH0pvvERAn
         QzpGRo9jVp2pWVTK+7P4z1s+9P/IgbuLcN4jfsinc+YqyuSjFcuMPzPfGQcdlCum87Am
         PDCw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from mail105.syd.optusnet.com.au (mail105.syd.optusnet.com.au. [211.29.132.249])
        by mx.google.com with ESMTP id d1si44001255pld.318.2019.08.06.14.38.15
        for <linux-mm@kvack.org>;
        Tue, 06 Aug 2019 14:38:16 -0700 (PDT)
Received-SPF: neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=211.29.132.249;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 211.29.132.249 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from dread.disaster.area (pa49-181-167-148.pa.nsw.optusnet.com.au [49.181.167.148])
	by mail105.syd.optusnet.com.au (Postfix) with ESMTPS id 0DF2C3611A0;
	Wed,  7 Aug 2019 07:38:15 +1000 (AEST)
Received: from dave by dread.disaster.area with local (Exim 4.92)
	(envelope-from <david@fromorbit.com>)
	id 1hv78m-0005E4-4F; Wed, 07 Aug 2019 07:37:08 +1000
Date: Wed, 7 Aug 2019 07:37:08 +1000
From: Dave Chinner <david@fromorbit.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-xfs@vger.kernel.org, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: Re: [RFC] [PATCH 00/24] mm, xfs: non-blocking inode reclaim
Message-ID: <20190806213708.GK7777@dread.disaster.area>
References: <20190801021752.4986-1-david@fromorbit.com>
 <20190806055744.GC25736@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806055744.GC25736@infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Optus-CM-Score: 0
X-Optus-CM-Analysis: v=2.2 cv=P6RKvmIu c=1 sm=1 tr=0 cx=a_idp_d
	a=gu9DDhuZhshYSb5Zs/lkOA==:117 a=gu9DDhuZhshYSb5Zs/lkOA==:17
	a=jpOVt7BSZ2e4Z31A5e1TngXxSK0=:19 a=kj9zAlcOel0A:10 a=FmdZ9Uzk2mMA:10
	a=7-415B0cAAAA:8 a=6Ra6EZb4IHi7eq9aHn8A:9 a=CjuIK1q_8ugA:10
	a=biEYGPWJfzWAr4FL6Ov7:22
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 05, 2019 at 10:57:44PM -0700, Christoph Hellwig wrote:
> Hi Dave,
> 
> do you have a git tree available to look over the whole series?

Not yet, I'll get one up for the next version of the patchset and I
have done some page cache vs inode cache balance testing. That,
FWIW, is not looking good - the vanilla 5.3-rc3 kernel is unable to
maintain a balanced page cache/inode cache working set under steady
state tarball-extraction workloads. Memory reclaim looks to be have
been completely borked from a system balance perspective since I
last looked at it maybe a year ago....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

