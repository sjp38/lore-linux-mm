Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84794C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 10:07:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E5872184D
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 10:07:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E5872184D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF3F98E0002; Wed, 30 Jan 2019 05:07:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA4218E0001; Wed, 30 Jan 2019 05:07:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C92B68E0002; Wed, 30 Jan 2019 05:07:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6F3198E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 05:07:21 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c3so9316153eda.3
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 02:07:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=TejQ7VRztGZGbvIvGdhC1Z4L1DJ3m9keRvP5mnoXvPM=;
        b=sGey9WAoRJfB3nMCINj1slLe0QtgzMmQm10F9QQVPmXG4rMdNFYSRSU1AryV5za0wm
         YaFJqVvEpDlAdhGd7hynLq5MLmIs4BI+nOCR0mMOWZ0dcLLu4IfEVk5O6jKPfjbRvQu4
         0xKRlZs2IiVCNgBXl9EunwhSBnP5bWWCsJ+RsagDbtGY7n12AV8FAzIsIIGML15n3LSU
         tVvIrbuZmG2mgWawPgjMKuBVkYFXdLCUpaRphTibsW+0ZeeLEQzz2R4iVe2eCxmY0oCx
         pUK2LWMh+CLB8G+8GH/XEPepyZNCa/SujzCP67uYMIzIjMkys6tXda9Er4RhVMjC8ZbK
         EhIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: AJcUukcEgiqcvIefEVZ8LDsZegdCr2q5OlS2xFmahU6jr3/eG9o54OzZ
	JSptUAJHX3HJOACvAD029SXoIcZyysj4/Uhs9h/Ck+C08krx8vXxe0GgZ9qvViUnRCrap4EqcSb
	Bde+Ep8AyPyYXPAyEYAAuSWYiGfP16fA/VRdHR+Z++lPkn66InAX4wkm+ckgMagDDBA==
X-Received: by 2002:a50:9849:: with SMTP id h9mr27955484edb.36.1548842840954;
        Wed, 30 Jan 2019 02:07:20 -0800 (PST)
X-Google-Smtp-Source: ALg8bN709i0bGhP8awHkhAIy5NRpy5mdGNaTB75DZG1+wAIjO7zwzqwHr2HDDCrC/IpDMXuO51RJ
X-Received: by 2002:a50:9849:: with SMTP id h9mr27955436edb.36.1548842840086;
        Wed, 30 Jan 2019 02:07:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548842840; cv=none;
        d=google.com; s=arc-20160816;
        b=FXMCIZQNVaOboH/GwZ6kWD8c5ZyzLpdXcYYNB2AtyYkrxAUIpd7pXO7kv9BraptYqX
         0W8T04PzWeYc5f4SVzmtLc+WjFZjslsa/vXvhJbmzDsA9s1qkkxL26o9DvB2n6dXXvJu
         ExOVZN9PpiMiO4uZ8QzABQTORHH8DLQTF5m84xvzJVLxsytgcdSuxePedRK+91gyE0cD
         vJu5Yq2o6BDBcAP4DDdIkK2YyuEk5lKTSb4Mq+R7BbZbDLAfUeR+EdaRTKMfAU7BeM40
         8UtJVI4J1y9bQnTCmil9/K2MYtlSEQr+ooXmG1WCgJYCeQ+S2l/x+8Z8XjE5ofNBJyMD
         6tww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=TejQ7VRztGZGbvIvGdhC1Z4L1DJ3m9keRvP5mnoXvPM=;
        b=Iwzm+V+kFYXV3Ol7Lm6cS25RGir7CrmiIo7h0NTCWOVZ+BrGHFd+Ltx1L8uw5ELbUG
         hVyAJ551sgqjrAqtMoU/ulOsiZNqmXCT/ZJ5BvB9qrftFs00wAd+G1M+m4p9JKUvXJtZ
         wECPXAyDLQFIuLwz4NcZWhjpVouT6iOBDAU92+YmOyy15cCxXE6toyhFiP+FC60hAn+F
         aZ1wzOqMUBz6t3I2wYeMrf/6ErJ/WxdaYAW0M1+hW6A02ShX8xpsNWChNATZtHeQJjNZ
         sf+yDGAMl6OIg8gd4Z7y2NBYM9Ezs/jFhtSLHTHKDCveSAQ7sflWH7kk9cazLb2f2HHl
         xkuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p26-v6si71936ejd.280.2019.01.30.02.07.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 02:07:20 -0800 (PST)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4A657ADC9;
	Wed, 30 Jan 2019 10:07:19 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 02EE81E3FFD; Wed, 30 Jan 2019 11:07:18 +0100 (CET)
Date: Wed, 30 Jan 2019 11:07:18 +0100
From: Jan Kara <jack@suse.cz>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>,
	linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH] vfs: Avoid softlockups in drop_pagecache_sb()
Message-ID: <20190130100718.GA30203@quack2.suse.cz>
References: <20190114085343.15011-1-jack@suse.cz>
 <20190129165636.34a1dc779efdbb9eff4bcf8b@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129165636.34a1dc779efdbb9eff4bcf8b@linux-foundation.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 29-01-19 16:56:36, Andrew Morton wrote:
> On Mon, 14 Jan 2019 09:53:43 +0100 Jan Kara <jack@suse.cz> wrote:
> 
> > When superblock has lots of inodes without any pagecache (like is the
> > case for /proc), drop_pagecache_sb() will iterate through all of them
> > without dropping sb->s_inode_list_lock which can lead to softlockups
> > (one of our customers hit this).
> > 
> > Fix the problem by going to the slow path and doing cond_resched() in
> > case the process needs rescheduling.
> > 
> > ...
> >
> > --- a/fs/drop_caches.c
> > +++ b/fs/drop_caches.c
> > @@ -21,8 +21,13 @@ static void drop_pagecache_sb(struct super_block *sb, void *unused)
> >  	spin_lock(&sb->s_inode_list_lock);
> >  	list_for_each_entry(inode, &sb->s_inodes, i_sb_list) {
> >  		spin_lock(&inode->i_lock);
> > +		/*
> > +		 * We must skip inodes in unusual state. We may also skip
> > +		 * inodes without pages but we deliberately won't in case
> > +		 * we need to reschedule to avoid softlockups.
> > +		 */
> >  		if ((inode->i_state & (I_FREEING|I_WILL_FREE|I_NEW)) ||
> > -		    (inode->i_mapping->nrpages == 0)) {
> > +		    (inode->i_mapping->nrpages == 0 && !need_resched())) {
> >  			spin_unlock(&inode->i_lock);
> >  			continue;
> >  		}
> > @@ -30,6 +35,7 @@ static void drop_pagecache_sb(struct super_block *sb, void *unused)
> >  		spin_unlock(&inode->i_lock);
> >  		spin_unlock(&sb->s_inode_list_lock);
> >  
> > +		cond_resched();
> >  		invalidate_mapping_pages(inode->i_mapping, 0, -1);
> >  		iput(toput_inode);
> >  		toput_inode = inode;
> 
> Are we sure there's no situation in which a large number of inodes can
> be in the "unusual state", leading to the same issue?

No, we cannot be really sure that there aren't many such inodes (although
I'd be surprised if there were). But the problem with "unusual state"
inodes is that you cannot just __iget() them (well, you could but it's
breaking the rules and would lead to use-after-free issues ;) and so
there's no easy way to drop the spinlock and then continue the iteration
after cond_resched(). So overall it's too complex to deal with this until
someone actually hits it.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

