Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3846EC10F0B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 04:58:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 01A44217F5
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 04:58:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01A44217F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 74D748E0003; Mon, 25 Feb 2019 23:58:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 725708E0002; Mon, 25 Feb 2019 23:58:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 639718E0003; Mon, 25 Feb 2019 23:58:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 240828E0002
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 23:58:31 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id 143so8755880pgc.3
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 20:58:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=GY0PAZrwR55vybTGEVlyrurQJzw/GPJwO6B897TcmE8=;
        b=LaEavcCvvsVFjkixQkXfSDrL7xhc153FGA2iFNUBrow4CxL0O55aDC3uw6dhWcRH3F
         6gBXW1plp0W9lnyJbWAMFZPFz8kJwX/wwyTqsJzsphjB4QidwS6KutR/5bWXOBkK/nBq
         arW0ynIMjhwrVgiAib1enyfhaWpIxcVa7e8W+AFwJ1gJfho3Vaqx21NJm5By70SU2VRJ
         Eqc0ypDUo2Q0vQBe/5uMPW/Bb59MoeMChms+ZLlaHmokT46TBl+PnemLj+UC7sEYfck+
         wmy2HLJTMJGWJYfmv2kQb0lnjgQka3bYXJN9fu4l3H6P63BE/hHa1I5Bgaj5P1WFWdqk
         g1BA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAuYghlljUYq+pS+wbdcyntxTzKsICjWb8bwKbg1kLeqwdmTtEXMf
	AtoenhUrOpJoGEAXkzfnb6FywW3eVz+51uSSLdqtI7/tnORqZuTV26ocFyb8gmZw54/vknaZ9Hj
	s3OXmb+bNp/jrfnoUWYfL9vSkIsYy1f7Evo2AwZ57mQnfmvMk2uH5Fo7BL5VePAo=
X-Received: by 2002:a63:2004:: with SMTP id g4mr22679928pgg.337.1551157110791;
        Mon, 25 Feb 2019 20:58:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbYCD+ak67dFZ1ZYsuv3G4tYML+S+oSAR6FM+kJv/sQU6JgV7B3vJGx7Do/AWG0HcIf9qbV
X-Received: by 2002:a63:2004:: with SMTP id g4mr22679861pgg.337.1551157109483;
        Mon, 25 Feb 2019 20:58:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551157109; cv=none;
        d=google.com; s=arc-20160816;
        b=p8u83EopV1xbQ8dVhYnUZYsgjc8Fzn6SljHbwq2rs7xzeGDDEC6gHQj3IgzUq3q2jn
         pquUu/opZwcCCtRh/cyks7nuEgaE/VrmzFIqohH/w6/kQ5gJ9/KiYSrVp6IvP1tpNXV/
         qXlazeMPNPYrqbxq5NUAmyVnQ4PNFpOt4hjok5B9x6ZbDaADJ5zOzjXd5TaHVNiymeKO
         3iN183MYSd9ehd0V5Se7zffj8I2uRUu4vbL/z09Ku1BG3Kn6wzb0P7Hk+E3BW3wtK1qT
         W9r1kLF2kFWkr9ZxBN8T967OFL0+BEWQThRXCTHgXU/KKiFUQlGLqZpM98gje50KaYFY
         tcug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=GY0PAZrwR55vybTGEVlyrurQJzw/GPJwO6B897TcmE8=;
        b=HRuZ0+vPcZFg8YZDb/ALu4QjgscMCEma6O+deBL/z6rISDQEG6+Ui3SndEVJxIXQ3W
         Ljp4rxFIA5PB4536UK4yWk82OyOTbhAMKdB01xYUoh0CiNNoSLp+n7vqWPSxWn2MOK3f
         B7RMrMfNc7R9Rp/R7pjTkeaTN1Mb7g1l3+g39zEPana/uyK0wyHKMmOMifPeG344Pxwc
         jiwZpb7evikHiU05NOujE3Z06j+u5mjEQycuFsPM/jkmb5AGqCfqVTgHw9KfckPoVGJB
         q/RNZlJX24lzbqkhwz0WRwAdEA6VnA79+PdSphkt2dcIyBUfwLcBHfVskvKN45/UZMmF
         FuQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id z18si11648011pgf.66.2019.02.25.20.58.28
        for <linux-mm@kvack.org>;
        Mon, 25 Feb 2019 20:58:29 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.131;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail07.adl2.internode.on.net with ESMTP; 26 Feb 2019 15:28:27 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gyUp0-0005x5-6N; Tue, 26 Feb 2019 15:58:26 +1100
Date: Tue, 26 Feb 2019 15:58:26 +1100
From: Dave Chinner <david@fromorbit.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Ming Lei <ming.lei@redhat.com>, Vlastimil Babka <vbabka@suse.cz>,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	linux-xfs@vger.kernel.org, Jens Axboe <axboe@kernel.dk>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Aaron Lu <aaron.lu@intel.com>, Christopher Lameter <cl@linux.com>,
	Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org,
	linux-block@vger.kernel.org
Subject: Re: [PATCH] xfs: allocate sector sized IO buffer via page_frag_alloc
Message-ID: <20190226045826.GJ23020@dastard>
References: <20190225040904.5557-1-ming.lei@redhat.com>
 <20190225043648.GE23020@dastard>
 <5ad2ef83-8b3a-0a15-d72e-72652b807aad@suse.cz>
 <20190225202630.GG23020@dastard>
 <20190226022249.GA17747@ming.t460p>
 <20190226030214.GI23020@dastard>
 <20190226032737.GA11592@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190226032737.GA11592@bombadil.infradead.org>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2019 at 07:27:37PM -0800, Matthew Wilcox wrote:
> On Tue, Feb 26, 2019 at 02:02:14PM +1100, Dave Chinner wrote:
> > > Or what is the exact size of sub-page IO in xfs most of time? For
> > 
> > Determined by mkfs parameters. Any power of 2 between 512 bytes and
> > 64kB needs to be supported. e.g:
> > 
> > # mkfs.xfs -s size=512 -b size=1k -i size=2k -n size=8k ....
> > 
> > will have metadata that is sector sized (512 bytes), filesystem
> > block sized (1k), directory block sized (8k) and inode cluster sized
> > (32k), and will use all of them in large quantities.
> 
> If XFS is going to use each of these in large quantities, then it doesn't
> seem unreasonable for XFS to create a slab for each type of metadata?


Well, that is the question, isn't it? How many other filesystems
will want to make similar "don't use entire pages just for 4k of
metadata" optimisations as 64k page size machines become more
common? There are others that have the same "use slab for sector
aligned IO" which will fall foul of the same problem that has been
reported for XFS....

If nobody else cares/wants it, then it can be XFS only. But it's
only fair we address the "will it be useful to others" question
first.....

-Dave.
-- 
Dave Chinner
david@fromorbit.com

