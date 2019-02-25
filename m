Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85505C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 04:37:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3218A20842
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 04:37:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3218A20842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99AFD8E016F; Sun, 24 Feb 2019 23:37:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94A978E016E; Sun, 24 Feb 2019 23:37:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 83A298E016F; Sun, 24 Feb 2019 23:37:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3CC5D8E016E
	for <linux-mm@kvack.org>; Sun, 24 Feb 2019 23:37:01 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 17so6231465pgw.12
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 20:37:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=tN3BfcNAG7/gTMmXAXmwnnVuFF3XZLq1EcuioJPLCUQ=;
        b=sz6qV3jALn1twQUkcOROjyjODTgmOLidfwKsmD1/CEtg4sTusg6eqnng3EikWtFyy2
         KoFuCvVU4YE/PaxcZ6L0sWacrVamCtlf4r+WGN3xdugwmLxMOvgjC3h04TJir8oR9OFW
         OSwFlTw6GyN+M/i4R7mPjIw7nmCImllseO47fAl/vPT1idxG/zHiRXUuH0nD0cKXXvgT
         XXX9+dUumBUva82YdZpBzmoBMYEqmB4K3LP7aFjT0bxyBN7QrEAHvrasyyYRA2u8O2+A
         lEWxKHrB530A3yEk80EL8OGZ0zGGnDm5j77ce2LF3wgIr3TVKE89Yxw3/cuW5diadFZh
         XiUw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.143 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAubmCpMf6HHPJyAmhvjNTCXhqGB+FZ3d4QJ7jsgMie/DFtkRUdZv
	TQLsLFZMTTGC91BCI+Z0hYlxd8+iuEeNV6POwqzOg1br85QfCD0tacoNMfMwUAXNIhRSIDCDqMv
	O41Dv/0rM7WFgs5e2W8AwAWKibp6yh16BJ/WSCQb+c5gGOXaDL/6GyK2pG4L6Bwk=
X-Received: by 2002:a63:6841:: with SMTP id d62mr17194837pgc.133.1551069420850;
        Sun, 24 Feb 2019 20:37:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ6dIRAQ4Z8O+iYu4TOb0d+Vs5RsB6JDzGmEVfch5z7yDfJ/96J+xcEj17Gu3snM1Y6SN1F
X-Received: by 2002:a63:6841:: with SMTP id d62mr17194793pgc.133.1551069419829;
        Sun, 24 Feb 2019 20:36:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551069419; cv=none;
        d=google.com; s=arc-20160816;
        b=t/sedvHKvBLIy8dz/smFKmo61mycjAiJqabLzl0gvWRb5uodS4YS80Iu3bZ6KsOrJo
         hYZHC2dsT17NqYr1TOZtre3IjQpkHMQGAfK8PlvwUPTrtjzJUiWl6K+AqC75UOxDq/ZI
         i/PV2c8lVGrxAszYUvCgtHAKaam7PbztsU3AerVzSFQwB5WavJHUzNpWutnHGTRL0o8d
         HtJA6B83xxoZeaPJdYh0JheDST+iHx5fDVbY2CY9ddatDJof1YDHYcDhoOdEk8gcMLpd
         WbTozU1f5lnUSVE5slhpOzKMraVkIP2kJNEYor41QaZilNPM2NhUvRYa/WLoUKuqii81
         ODAQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=tN3BfcNAG7/gTMmXAXmwnnVuFF3XZLq1EcuioJPLCUQ=;
        b=IPNMgTzLlj2pCA/I/aGtwCAUcxMn/QgAGKOkSQoK/bkkN3ozxqfLoIV9QF83Z4NsMH
         GuDQibocroBXdtRv0lAfq+rmhWxj0yhV+PyrVRJrHLBL3zAwkGzqYyQW1Mx/xZrApB6n
         rUXHS/ZcEJfEm+pO9y73kkaz60UHzIL2p5NgXNEx74q4HM6SWufCvVdBJnZrZmbP017S
         1bpOc+Vvsot4BN+KsboCEr0tNVzz8b7XjZYrIrF6d/GkC13X7NY8cKNlFrCYXtGAeY6b
         E3xyw/KFOhNOJoLcpZAqUhBPCC+aF+w49wPhUt9XU2nzU/UHNLSQcUpjHAIoQvpmp35Z
         3B8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.143 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail03.adl6.internode.on.net (ipmail03.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id x5si8443586plv.26.2019.02.24.20.36.58
        for <linux-mm@kvack.org>;
        Sun, 24 Feb 2019 20:36:59 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.143 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.143;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.143 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail03.adl6.internode.on.net with ESMTP; 25 Feb 2019 15:06:58 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gy80W-0004WM-Bw; Mon, 25 Feb 2019 15:36:48 +1100
Date: Mon, 25 Feb 2019 15:36:48 +1100
From: Dave Chinner <david@fromorbit.com>
To: Ming Lei <ming.lei@redhat.com>
Cc: "Darrick J . Wong" <darrick.wong@oracle.com>, linux-xfs@vger.kernel.org,
	Jens Axboe <axboe@kernel.dk>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Dave Chinner <dchinner@redhat.com>, Christoph Hellwig <hch@lst.de>,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Aaron Lu <aaron.lu@intel.com>, Christopher Lameter <cl@linux.com>,
	Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org,
	linux-block@vger.kernel.org
Subject: Re: [PATCH] xfs: allocate sector sized IO buffer via page_frag_alloc
Message-ID: <20190225043648.GE23020@dastard>
References: <20190225040904.5557-1-ming.lei@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190225040904.5557-1-ming.lei@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 25, 2019 at 12:09:04PM +0800, Ming Lei wrote:
> XFS uses kmalloc() to allocate sector sized IO buffer.
....
> Use page_frag_alloc() to allocate the sector sized buffer, then the
> above issue can be fixed because offset_in_page of allocated buffer
> is always sector aligned.

Didn't we already reject this approach because page frags cannot be
reused and that pages allocated to the frag pool are pinned in
memory until all fragments allocated on the page have been freed?

i.e. when we consider 64k page machines and 4k block sizes (i.e.
default config), every single metadata allocation is a sub-page
allocation and so will use this new page frag mechanism. IOWs, it
will result in fragmenting memory severely and typical memory
reclaim not being able to fix it because the metadata that pins each
page is largely unreclaimable...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

