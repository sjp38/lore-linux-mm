Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2CA5C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 07:53:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A548B2084D
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 07:53:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A548B2084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 581416B000E; Thu, 13 Jun 2019 03:53:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5591B6B0010; Thu, 13 Jun 2019 03:53:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 449196B0266; Thu, 13 Jun 2019 03:53:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id E9EB16B000E
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 03:53:39 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d27so29732466eda.9
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 00:53:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=oGvbP6qCBzG9TV7lWUqJlpKLXarG0nshnBnGIEIh+XQ=;
        b=ERH4Z3yzrw0sZJJs8hwhYkMaMEAftatt7rMvzR0UxIBEDpTXGBugeEryeRoVSLrzG3
         a+bBK+zZNMpbYe2S/nIDVVfZBbSDZtBZx6bWFKvLKVHyndSuqYgPyBw+3+L21XEtsL5o
         jOsk3FVrfSArbihYeddS58hxmU4MFB2ymOvHhxzeTHQFU5MZf0i7TYjzJq0EdwRWyn7I
         PJ6aGHP1SXfxn9hG8+oddo34F5D3wNFL5XPF6GcRtPvbSryI6UFjiZrR6BoiBatVjuzD
         crQCfywWyuKKrpnH3S0yjsCwE/tN4gkQfaVVlYzWlNvfjDNaMWpZ4Vv/rJqGo6KaCKsk
         0laA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Gm-Message-State: APjAAAXkYfBz5rrY55jXS/GhwL2DYZ2KtgAjBmJlK41CysnSqYyLJgzJ
	B5um7XvF2Ix6uIKpsyQsWOKFK2V2nWZQGpre433JtfrlyyuG/RUxsAOCKX8zSMWd1UkMBn5ZP4f
	+AJel/nRE8ss0io+rI2ID+nyPNscX0+KtDRHsKjMxxmm6zo/+zAnxUWGRWi934c30lA==
X-Received: by 2002:a05:6402:1212:: with SMTP id c18mr31344935edw.7.1560412419419;
        Thu, 13 Jun 2019 00:53:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3tkKQiRsOdUPMzAsvkIeO01DmOnUGVb5SDt7nD10M12ZuIUjXYCFb2BKLW5p/jlYBdKR+
X-Received: by 2002:a05:6402:1212:: with SMTP id c18mr31344902edw.7.1560412418707;
        Thu, 13 Jun 2019 00:53:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560412418; cv=none;
        d=google.com; s=arc-20160816;
        b=mQ1BFhJSU2Vtnc7SP2y764NnDT2QsSsPVd+vzgdye3+gz7v2fcGw0IlWSGh+K3myN1
         8YtHqR/uxGpsFIXUxu+eGF+nHkf9zeTNMSn9NJLG33IXP8Sz8oAOZAKRuVSA1vP15rrd
         X5BNC5pv0jEfa/OYYwH71Xqsixc+kew8Lm9bjJDWoKiE0rfjOtyadTpGGdHsdMbdjftb
         v/5uqCZnjEwlue3XTKh+cXVeVL8QRs0OJQsR8s/6KdCyshwyCH6ezPk6OjNHHWGEkW6V
         SsTNHrZVSQuPw34mDkHdWXUf5H51idQMw5bIqouCtRci1eraYuF8PKJyBmXEMLfpVFBI
         4J2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=oGvbP6qCBzG9TV7lWUqJlpKLXarG0nshnBnGIEIh+XQ=;
        b=IKlF933wGrJdQlBhneXlp4EA5NdiwUWinpWyz0eocqGfsA9P/wVf46Mx5ql0ZbvA2v
         k1CjItxnME2bCJy7J/6wsq/EKwspuzKhoeJPyh7kQnXWYSl0/qykS18yji8YAjEGEy2I
         n0jRM5dkr/4S5tVltxab+pvszQRzrUoPF4/wPDRAOyvXhs6DPwR691IVPbgBOBLxk1ky
         cP5MAxwmivWxytuSYaHDMXWUikd03+p5mbBuPC3uajEcREfxOdXyA9rCTu46/IYTsWa9
         7Zj190oOdAKkWd35t2eSw04UJO8sFgOykuYstG9kkXGzoAl3W6We0OCOgSrYytdwbZst
         a2UQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j20si1561527ejt.117.2019.06.13.00.53.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 00:53:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jack@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=jack@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B6CC4AD1E;
	Thu, 13 Jun 2019 07:53:37 +0000 (UTC)
Received: by quack2.suse.cz (Postfix, from userid 1000)
	id 4A7821E4328; Thu, 13 Jun 2019 09:53:33 +0200 (CEST)
Date: Thu, 13 Jun 2019 09:53:33 +0200
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
Message-ID: <20190613075333.GC26505@quack2.suse.cz>
References: <20190606195114.GA30714@ziepe.ca>
 <20190606222228.GB11698@iweiny-DESK2.sc.intel.com>
 <20190607103636.GA12765@quack2.suse.cz>
 <20190607121729.GA14802@ziepe.ca>
 <20190607145213.GB14559@iweiny-DESK2.sc.intel.com>
 <20190612102917.GB14578@quack2.suse.cz>
 <20190612114721.GB3876@ziepe.ca>
 <20190612120907.GC14578@quack2.suse.cz>
 <20190612191421.GM3876@ziepe.ca>
 <20190612221336.GA27080@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190612221336.GA27080@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 12-06-19 15:13:36, Ira Weiny wrote:
> On Wed, Jun 12, 2019 at 04:14:21PM -0300, Jason Gunthorpe wrote:
> > On Wed, Jun 12, 2019 at 02:09:07PM +0200, Jan Kara wrote:
> > > On Wed 12-06-19 08:47:21, Jason Gunthorpe wrote:
> > > > On Wed, Jun 12, 2019 at 12:29:17PM +0200, Jan Kara wrote:
> > > > 
> > > > > > > The main objection to the current ODP & DAX solution is that very
> > > > > > > little HW can actually implement it, having the alternative still
> > > > > > > require HW support doesn't seem like progress.
> > > > > > > 
> > > > > > > I think we will eventually start seein some HW be able to do this
> > > > > > > invalidation, but it won't be universal, and I'd rather leave it
> > > > > > > optional, for recovery from truely catastrophic errors (ie my DAX is
> > > > > > > on fire, I need to unplug it).
> > > > > > 
> > > > > > Agreed.  I think software wise there is not much some of the devices can do
> > > > > > with such an "invalidate".
> > > > > 
> > > > > So out of curiosity: What does RDMA driver do when userspace just closes
> > > > > the file pointing to RDMA object? It has to handle that somehow by aborting
> > > > > everything that's going on... And I wanted similar behavior here.
> > > > 
> > > > It aborts *everything* connected to that file descriptor. Destroying
> > > > everything avoids creating inconsistencies that destroying a subset
> > > > would create.
> > > > 
> > > > What has been talked about for lease break is not destroying anything
> > > > but very selectively saying that one memory region linked to the GUP
> > > > is no longer functional.
> > > 
> > > OK, so what I had in mind was that if RDMA app doesn't play by the rules
> > > and closes the file with existing pins (and thus layout lease) we would
> > > force it to abort everything. Yes, it is disruptive but then the app didn't
> > > obey the rule that it has to maintain file lease while holding pins. Thus
> > > such situation should never happen unless the app is malicious / buggy.
> > 
> > We do have the infrastructure to completely revoke the entire
> > *content* of a FD (this is called device disassociate). It is
> > basically close without the app doing close. But again it only works
> > with some drivers. However, this is more likely something a driver
> > could support without a HW change though.
> > 
> > It is quite destructive as it forcibly kills everything RDMA related
> > the process(es) are doing, but it is less violent than SIGKILL, and
> > there is perhaps a way for the app to recover from this, if it is
> > coded for it.
> 
> I don't think many are...  I think most would effectively be "killed" if this
> happened to them.

Yes, I repeat we are in a situation when the application has a bug and
didn't propely manage its long term pins which are fully under its control.
So in my mind a situation similar to application using memory it has
already freed. The kernel has to manage that but we don't really care
what's left from the application when this happens.

That being said I'm not insisting this has to happen - tracking associated
"RDMA file" with a layout lease and somehow invalidating it on close of a
leased file is somewhat ugly anyway. But it is still an option if exposing
pins to userspace for lsof to consume proves even worse...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

