Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2772EC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 01:19:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA0DB2177E
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 01:19:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA0DB2177E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 781998E0002; Thu, 14 Feb 2019 20:19:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 731008E0001; Thu, 14 Feb 2019 20:19:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 647088E0002; Thu, 14 Feb 2019 20:19:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C3FD8E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 20:19:26 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id x134so6220324pfd.18
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 17:19:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=HvRDIw0zoie/jzUxLAc1QB/FaRPcQgXHGlFWf8fbir4=;
        b=hAi3aZ6EYV4C11WjqlKamNVBdf+bu/wbcZlmXF/kGGBs965dCSAuy6WXnHKWto615L
         QqwI3KSANAxVj5SxChvKOpJSzIgAx/IXbyMUzWQLCXMUCHbzWTvvnVHgR7i+W/SBLAvw
         OtCVEShocFUAKNQoBZyePAJqe8bfupISQd4N6XS4BH7mkekzICsOZWCK9ue8iVp2uA1G
         bmIMwWxri9BTShgpgX4ueJEV3d/OANpkXVcLtEmbiO3oHGF2QsLTJ9RaHBDtyUse1m12
         uOsmJyA/Ki+DKZRtZuz7aQMs3XOd0ZdXza/NYCdP3Kx7kd8st8zy0E5ttEDTs21G4l1G
         AvhQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.129 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAuYZ2uScvAh0WeC8UM2oe7cKVSCfxs29RzTTUOQdpQWx0bo6MD9l
	N6A9xA+o0r7juRUv9rY3lCY7JA0LQmuHLzXfbwTo+PopAl3ECbUBNdcs5+J/vPaZXpAgtvvs1eT
	EbaXq61Xa8/tIENYS1O5Wf+e5Mw92ifN+U+xTkouhXa00F6QTfhiHdRP9SBDKs5c=
X-Received: by 2002:a62:5301:: with SMTP id h1mr7037581pfb.17.1550193565693;
        Thu, 14 Feb 2019 17:19:25 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbwFZkjJsAGAv1W6w13vX2NEgb5DaZtHzZK8rn6e+fBva3YiHmyQ21Y4rxNidX4Cn+XvT2O
X-Received: by 2002:a62:5301:: with SMTP id h1mr7037532pfb.17.1550193564782;
        Thu, 14 Feb 2019 17:19:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550193564; cv=none;
        d=google.com; s=arc-20160816;
        b=NCMen4Ph8sAFxTZ01fvBnckhO0dtv9Vf7vZBMtnfPqakQ8/Qfq7tceFuZtLYh0gC5I
         6ymcmXXhExt5ICiHunuJeI+pkGMN3O0vjHvGdXwKpFRfyef/x6r/1G+6OggA+Bi8IbNN
         lv6m/lXXCscixK0VtpwMZ5s6d4VgPrSslynfPEVSdbAF7Owh1SZbRxxP2HgzONtxpiP+
         p2IC18/gQ1GQgzHDhEvaqdrJSy8H3ftsV4VxudZpFwyuMY2YJzghbyybZ78LJoVsRmTB
         kUTInSOIxdMo/rnE5J2n3EaW/s4uusfu5dsxrChB8gBY09Q8b2FwgVKBag9fZw1Ov517
         YmNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=HvRDIw0zoie/jzUxLAc1QB/FaRPcQgXHGlFWf8fbir4=;
        b=U1aIGma+65nK6jRzhOfwq6nimx7JwoEzHjnSXy26TqLkOEcGALq4CVRvNYwzA7ZUxs
         IW5SY7E4vvUFUIAZ1gqd5vlQVK9w0+qZdu5ezR3GRZN2B47KIJIRA6vmSr+9I7Vgia5W
         ry672Gr73XCOXVinsFmu48TE8T8okCm7/cm88pxRN8hXzVcnrjYzwgtdfziHfFZO0Vjv
         x9qJiyZghz8/8FO7vrc/smMzgBd+QO3DECWhiXKh07ys1mQsA22sBxExPxmlObq4xqZu
         OQSHOcfuISi7W6Z0BMCYvBhydEhD7dv4nPn2Sp3VB0bl5+ONc5v2Hx3t+tqgqjWoqxkE
         1HuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.129 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id p31si4069838pgb.440.2019.02.14.17.19.23
        for <linux-mm@kvack.org>;
        Thu, 14 Feb 2019 17:19:24 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.129 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.129;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.129 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail06.adl2.internode.on.net with ESMTP; 15 Feb 2019 11:49:22 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1guS9x-0006wx-E8; Fri, 15 Feb 2019 12:19:21 +1100
Date: Fri, 15 Feb 2019 12:19:21 +1100
From: Dave Chinner <david@fromorbit.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>,
	Christopher Lameter <cl@linux.com>,
	Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	lsf-pc@lists.linux-foundation.org,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Linux MM <linux-mm@kvack.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@kernel.org>
Subject: Re: [LSF/MM TOPIC] Discuss least bad options for resolving
 longterm-GUP usage by RDMA
Message-ID: <20190215011921.GS20493@dastard>
References: <01000168c8e2de6b-9ab820ed-38ad-469c-b210-60fcff8ea81c-000000@email.amazonses.com>
 <20190208044302.GA20493@dastard>
 <20190208111028.GD6353@quack2.suse.cz>
 <CAPcyv4iVtBfO8zWZU3LZXLqv-dha1NSG+2+7MvgNy9TibCy4Cw@mail.gmail.com>
 <20190211102402.GF19029@quack2.suse.cz>
 <CAPcyv4iHso+PqAm-4NfF0svoK4mELJMSWNp+vsG43UaW1S2eew@mail.gmail.com>
 <20190211180654.GB24692@ziepe.ca>
 <20190214202622.GB3420@redhat.com>
 <20190214205049.GC12668@bombadil.infradead.org>
 <20190214213922.GD3420@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190214213922.GD3420@redhat.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2019 at 04:39:22PM -0500, Jerome Glisse wrote:
> On Thu, Feb 14, 2019 at 12:50:49PM -0800, Matthew Wilcox wrote:
> > On Thu, Feb 14, 2019 at 03:26:22PM -0500, Jerome Glisse wrote:
> > > On Mon, Feb 11, 2019 at 11:06:54AM -0700, Jason Gunthorpe wrote:
> > > > But it also doesnt' trucate/create a hole. Another thread wrote to it
> > > > right away and the 'hole' was essentially instantly reallocated. This
> > > > is an inherent, pre-existing, race in the ftrucate/etc APIs.
> > > 
> > > So it is kind of a // point to this, but direct I/O do "truncate" pages
> > > or more exactly after a write direct I/O invalidate_inode_pages2_range()
> > > is call and it will try to unmap and remove from page cache all pages
> > > that have been written too.
> > 
> > Hang on.  Pages are tossed out of the page cache _before_ an O_DIRECT
> > write starts.  The only way what you're describing can happen is if
> > there's a race between an O_DIRECT writer and an mmap.  Which is either
> > an incredibly badly written application or someone trying an exploit.
> 
> I believe they are tossed after O_DIRECT starts (dio_complete). But

Yes, but also before. See iomap_dio_rw() and
generic_file_direct_write().

> regardless the issues is that an RDMA can have pin the page long
> before the DIO in which case the page can not be toss from the page
> cache and what ever is written to the block device will be discarded
> once the RDMA unpin the pages. So we would end up in the code path
> that spit out big error message in the kernel log.

Which tells us filesystem people that the applications are doing
something that _will_ cause data corruption and hence not to spend
any time triaging data corruption reports because it's not a
filesystem bug that caused it.

See open(2):

	Applications should avoid mixing O_DIRECT and normal I/O to
	the same file, and especially to overlapping byte regions in
	the same file.  Even when the filesystem correctly handles
	the coherency issues in this situation, overall I/O
	throughput is likely to be slower than using either mode
	alone.  Likewise, applications should avoid mixing mmap(2)
	of files with direct I/O to the same files.

-Dave.
-- 
Dave Chinner
david@fromorbit.com

