Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A02E6C10F06
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 14:45:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DB7620657
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 14:45:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DB7620657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92C3F8E0003; Mon, 11 Mar 2019 10:45:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D9C58E0002; Mon, 11 Mar 2019 10:45:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C9AE8E0003; Mon, 11 Mar 2019 10:45:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 24AAD8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 10:45:30 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id o9so2154028edh.10
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 07:45:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=l+70bmUqVAHUvk1TSJTAp5bmdCxhjc87upuAYRQHNPM=;
        b=OU26mfgciy/liwzHhYj8XZEDuOKj9dx/HUuaX500XoQaacLdvvbvGC4/DMjLyJjYbB
         BH94tt0ytdJDzvPZ3o5c3yaZxdJNnTtl3AKszvGrszujDOoFry+lUt4eZGDkZSeZO3Ut
         kHAn2gwjot2Co6wBjpQV0JVRpswPxMsIEKqp95dvTMF9iAcdwluS8NzpDg91EgkMxRez
         bls55PhT0NaMfYc3x3U4MWpUV56yYH3v1FtV3wDKMlCIx4gigjzhVDRaUhch7uUZzFsE
         oIojDml4e9Ye/EdGLWfgz5FxFx+hRoyNr9gO5gKDq5Ufoe+dSK9CQN8KtSjGppBEgW0r
         xAiw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAW7aSU+/FYAj31NM3fhj3LQhvsZ+R+R8WL5rR0I8nxM7tWWK5jW
	93pNugG5d5DUBFitM/yN9DxT9shMOth9Els3v6yOo4Dyo1vTwjX9sfy9rkOdR5jQNj5J/0hUIxb
	WsOnNM6tFxzO9gqxfKWGVS1TJqW016rgNpXcRy5oJT4i4eAKSIsry9ECK/5ik1qWcYw==
X-Received: by 2002:a50:978e:: with SMTP id e14mr42541600edb.234.1552315529723;
        Mon, 11 Mar 2019 07:45:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqykPWXvdJhBmKPDt0RK50I/U2qU0xoYPaRR/g9f4LYq/AzFBY+qlwglUVpCcT4/l6tU6Edq
X-Received: by 2002:a50:978e:: with SMTP id e14mr42541540edb.234.1552315528720;
        Mon, 11 Mar 2019 07:45:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552315528; cv=none;
        d=google.com; s=arc-20160816;
        b=qLJDHe/N5yUqm1jHsPRM8Z4B2u3SRDZagdeOS4ctmsR0Gj0dBuU4NDXJrtjRxsab4y
         CGBfaL0tRRdxefjTILIPN9HJtt22q9CSfKYvOoIXfsf+UULSzh+ePj4dD0aAawggiop1
         sFfWlQDbvvJd0BZ+fZGFd/6NaW6zOIk2win2d72ASBErzZbS7xjvXrEjElmNVQa+p0Rg
         A91loEYUMTt9gP7TceQM4maYexOuovROva9LQMp5DWjtXxdjz1vR4+d96m7gVmPu8CjW
         aLVxaOErRimGpUh5LwPPgH/ZiG/T1yQ8tZw5vEvJh2hWgL1rYEqqQK/phLTDJFQdOdsx
         YMLA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=l+70bmUqVAHUvk1TSJTAp5bmdCxhjc87upuAYRQHNPM=;
        b=Fq9ONJjsmZv88MFHJwmEriOt1NpiXCIQrr7MHg1AG6ON9mAMOjoB6LRBBG68RMtShn
         BuVw/LLvJyIFLpHTVhVZMKkIX4bvWer7KT+FF3HJoKQLP+Gr4jRrAvdEFFAdlO0Rq1uL
         R8mHJ+HcNNXi93m6is+oboIFeGkhFG+u+bafJLrexrVbCjpBHF7xyjCy4UKyNMiIpayp
         AIQxQ13Nb6i2O8fNs8yh0cU+Gp2Nr2GlnIL1i+ScNAI7w+bITL+8+S18SHy5u9XZyseP
         ss8puSTk7UXx6gu1ICg8CwsNRsnmrhZUYKu9Bsjob9w6sjtgUKapG/G4ljM2OoXdetgL
         6f0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l26si544117ejs.214.2019.03.11.07.45.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 07:45:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E1BFAAFBB;
	Mon, 11 Mar 2019 14:45:27 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 594E51E426A; Mon, 11 Mar 2019 15:45:27 +0100 (CET)
Date: Mon, 11 Mar 2019 15:45:27 +0100
From: Jan Kara <jack@suse.cz>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Jerome Glisse <jglisse@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Jason Wang <jasowang@redhat.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
	Jan Kara <jack@suse.cz>
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
Message-ID: <20190311144527.GM11553@quack2.suse.cz>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190306092837-mutt-send-email-mst@kernel.org>
 <15105894-4ec1-1ed0-1976-7b68ed9eeeda@redhat.com>
 <20190307101708-mutt-send-email-mst@kernel.org>
 <20190307190910.GE3835@redhat.com>
 <20190307193838.GQ23850@redhat.com>
 <20190307201722.GG3835@redhat.com>
 <20190307212717.GS23850@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190307212717.GS23850@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 07-03-19 16:27:17, Andrea Arcangeli wrote:
> > driver that GUP page for hours/days/weeks/months ... obviously the
> > race window is big enough here. It affects many fs (ext4, xfs, ...)
> > in different ways. I think ext4 is the most obvious because of the
> > kernel log trace it leaves behind.
> > 
> > Bottom line is for set_page_dirty to be safe you need the following:
> >     lock_page()
> >     page_mkwrite()
> >     set_pte_with_write()
> >     unlock_page()
> 
> I also wondered why ext4 writepage doesn't recreate the bh if they got
> dropped by the VM and page->private is 0. I mean, page->index and
> page->mapping are still there, that's enough info for writepage itself
> to take a slow path and calls page_mkwrite to find where to write the
> page on disk.

There are two problems:

1) What to do with errors that page_mkwrite() can generate (ENOMEM, ENOSPC,
EIO). On page fault you just propagate them to userspace, on set_page_dirty()
you have no chance so you just silently loose data.

2) We need various locks to protect page_mkwrite(), possibly do some IO.
set_page_dirty() is rather uncertain context to acquire locks or do IO...

									Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

