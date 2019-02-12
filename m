Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5A41C282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:41:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9F960222C7
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:41:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9F960222C7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 251548E0002; Tue, 12 Feb 2019 13:41:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2001C8E0001; Tue, 12 Feb 2019 13:41:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13D0C8E0002; Tue, 12 Feb 2019 13:41:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id DAF1F8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 13:41:14 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id s65so16533736qke.16
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:41:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/AU2PS2waBBBHfOuEsk+KdrvieceqHVwvbvBZ65cUqM=;
        b=RR16VsJ/CI3vnHi7SgnPn9w4av8hSaWFfn6SOGB565yvpmFMHFLpMCknvukhlpYtQu
         MGx1DUV27Qd8Q3Z5iQc1vT01TD1GjSKXzRofwhyGnXV67TrYM+3nUVVuSZRFH5bRQFrh
         oVjd5N01drz6DSAA8ocZtiLEYC9eyzv0JY/4kheyg+j3RAFsDkqSp/dzeR/prEu66hqF
         to/pV+3vm5vInRFqg0sS2f5UN7W0TSdwOJ6zmIcKbncP9lvt8/E4rENJyxPN+JF4wbvl
         BrgsRPHyFF+mYhOtF57WnTCdTXQZhdFy4HqWpvXukqMIR4oWOX24AETHONX0ghA6JfWI
         C4hw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alex.williamson@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=alex.williamson@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYMqYVrZ2MOve6boCVUp7qG58qIPOoi6k7fT04+6ESd+JWdGc5X
	z//F0gD2Zm2EoF8ew/HzPitiuX5XMDq0c4nQC4KHejagNfwzxfuirumDeAL3WtmkgttcjZEp7ok
	UpDT7a674dpOpzggQqywjgC4tJMJeRZG1KhI8hDws14i4cmTfcwi/zpUHlFylwMrfnQ==
X-Received: by 2002:a37:b402:: with SMTP id d2mr2536942qkf.238.1549996874610;
        Tue, 12 Feb 2019 10:41:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibbc8/opO6Pz2Q/qX2Wa0g2vBg1rxkAKJdvn51D1YqFFhhjudtsD85/xgzUcU4E6SxNkOnv
X-Received: by 2002:a37:b402:: with SMTP id d2mr2536905qkf.238.1549996873984;
        Tue, 12 Feb 2019 10:41:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549996873; cv=none;
        d=google.com; s=arc-20160816;
        b=ngOh3rUGeBH/I1o7350yDDQxfBeQp9FSgH4Hn6FFgBjPQupP386wStGrTOvDtTHRIS
         vXtFVR8eAh2Q66eUtkkJFwEm02wLxQDlgWBgfJrQZ+b943EvNI4q+5tvoj0KLTA/Rvp/
         AbkxlA3d4Bi2UyHig528JgKPNG3OFcjNhfLtUZz0P9aQg0YTDGprvhcIofhFA7bHnpqq
         w14dGX+cAhugdPw2WzeuiiHonG+xAH+N8gQ4XmUmqJuZSvO+YQs5eezLkrMG+dxhUCbp
         yUobGWPox/j09LgpVA4Y1wcxNXpDrcinMneeMSDV509+GRWZLkFb1r/vm7IXwae/OLtI
         ZDLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=/AU2PS2waBBBHfOuEsk+KdrvieceqHVwvbvBZ65cUqM=;
        b=xJYRoqTBh0DY4X3GlXBPLzMZDRt/OhxIBwQ+DA3eQHTt9uwLIk9Grbc4Uc8uEc+gIs
         hPO59wgD40+QYifstM4JmG9LQJvOCjPyIOEFuWfe4CQlE5rwmwl+T856s+WFINxqit65
         yvrFEz8q0ZkCGKan2rRC+mHtkg3eE10CyYynFsDxSqzoUlRZvOaJ0HQ7qj8fFvn7W8j3
         Nrpk0Pgp4rf7+N7A7GBkI+kiDpcQ1DD6cXHoB19xQAzLuYxZNHQcI5iZB6TrRBND8M4H
         anPky5TkGve6vwdxyFUbL2dnMV2B0/YkNJFfzZCf9iuYIXYerhLWAm5lMMBiX0ZMgtLz
         pHPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alex.williamson@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=alex.williamson@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t20si8654351qtq.352.2019.02.12.10.41.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 10:41:13 -0800 (PST)
Received-SPF: pass (google.com: domain of alex.williamson@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alex.williamson@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=alex.williamson@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E5D75E6A7D;
	Tue, 12 Feb 2019 18:41:12 +0000 (UTC)
Received: from w520.home (ovpn-116-24.phx2.redhat.com [10.3.116.24])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5B1275D973;
	Tue, 12 Feb 2019 18:41:11 +0000 (UTC)
Date: Tue, 12 Feb 2019 11:41:10 -0700
From: Alex Williamson <alex.williamson@redhat.com>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, akpm@linux-foundation.org,
 dave@stgolabs.net, jack@suse.cz, cl@linux.com, linux-mm@kvack.org,
 kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
 linux-kernel@vger.kernel.org, paulus@ozlabs.org, benh@kernel.crashing.org,
 mpe@ellerman.id.au, hao.wu@intel.com, atull@kernel.org, mdf@kernel.org,
 aik@ozlabs.ru
Subject: Re: [PATCH 1/5] vfio/type1: use pinned_vm instead of locked_vm to
 account pinned pages
Message-ID: <20190212114110.17bc8a14@w520.home>
In-Reply-To: <20190211231152.qflff6g2asmkb6hr@ca-dmjordan1.us.oracle.com>
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
	<20190211224437.25267-2-daniel.m.jordan@oracle.com>
	<20190211225620.GO24692@ziepe.ca>
	<20190211231152.qflff6g2asmkb6hr@ca-dmjordan1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 12 Feb 2019 18:41:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Feb 2019 18:11:53 -0500
Daniel Jordan <daniel.m.jordan@oracle.com> wrote:

> On Mon, Feb 11, 2019 at 03:56:20PM -0700, Jason Gunthorpe wrote:
> > On Mon, Feb 11, 2019 at 05:44:33PM -0500, Daniel Jordan wrote:  
> > > @@ -266,24 +267,15 @@ static int vfio_lock_acct(struct vfio_dma *dma, long npage, bool async)
> > >  	if (!mm)
> > >  		return -ESRCH; /* process exited */
> > >  
> > > -	ret = down_write_killable(&mm->mmap_sem);
> > > -	if (!ret) {
> > > -		if (npage > 0) {
> > > -			if (!dma->lock_cap) {
> > > -				unsigned long limit;
> > > -
> > > -				limit = task_rlimit(dma->task,
> > > -						RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> > > +	pinned_vm = atomic64_add_return(npage, &mm->pinned_vm);
> > >  
> > > -				if (mm->locked_vm + npage > limit)
> > > -					ret = -ENOMEM;
> > > -			}
> > > +	if (npage > 0 && !dma->lock_cap) {
> > > +		unsigned long limit = task_rlimit(dma->task, RLIMIT_MEMLOCK) >>
> > > +
> > > -					PAGE_SHIFT;  
> > 
> > I haven't looked at this super closely, but how does this stuff work?
> > 
> > do_mlock doesn't touch pinned_vm, and this doesn't touch locked_vm...
> > 
> > Shouldn't all this be 'if (locked_vm + pinned_vm < RLIMIT_MEMLOCK)' ?
> >
> > Otherwise MEMLOCK is really doubled..  
> 
> So this has been a problem for some time, but it's not as easy as adding them
> together, see [1][2] for a start.
> 
> The locked_vm/pinned_vm issue definitely needs fixing, but all this series is
> trying to do is account to the right counter.

This still makes me nervous because we have userspace dependencies on
setting process locked memory.  There's a user visible difference if we
account for them in the same bucket vs separate.  Perhaps we're
counting in the wrong bucket now, but if we "fix" that and userspace
adapts, how do we ever go back to accounting both mlocked and pinned
memory combined against rlimit?  Thanks,

Alex

