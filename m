Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84A62C282D9
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 09:23:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4CDCF20882
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 09:23:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4CDCF20882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D79D88E0002; Wed, 30 Jan 2019 04:23:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D292E8E0001; Wed, 30 Jan 2019 04:23:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C40418E0002; Wed, 30 Jan 2019 04:23:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A3C18E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 04:23:13 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id w1so27675715qta.12
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 01:23:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=VbAkpVm6aUtjplh15xW+8XFpBdphGmpE5hR4xv/5y9w=;
        b=VfcOZf/wNKRLsC7queBLts1nzUL12huz9FWxm5uquoIIuhmr9erc6QNmKPDpAyWESt
         l+YfA7GvDxLq9muZrZCc9ZuoREl6T1oMNoPDiOeZmDEv796LURWUo27NHC6tJl/PJp3F
         yoYfN7hiS8tCVRjpXRoK9Q0uR1vb9EMs1AOsRPmeBejud7HMiOb16bWh/fDQUXi/eZN3
         VeJgzZ1wDuUYGbEoEafqEtajs/wNiFP1GN60BdO8OTTjRJlqx6fLMocalfcl/i8wFwuK
         ElLSW7lGWQKcw8w9bD1M4xi7JWFXea+X53Gg3iphDzc/BWJRbrbuOQdDVg3KHQ+oX8Dw
         1JSA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukclau6VYV8NBmZkv9/a++7baDs0/uDh7JCm5yseWwIWihaX0rfs
	o62pq5AigJGklsZI+O616H9JhhgQ7CYrygaQQrA9Dx68tyUP7J7orIvWOezjpfAo+zGwE3XYRua
	kGiAzOAgTzCidDQkA+QwnXJ/z7sYFL4kvJ7RpNWtmFjBt6yNhmQICnB7/VN4a89AlJQ==
X-Received: by 2002:a37:68a:: with SMTP id 132mr27583345qkg.89.1548840193338;
        Wed, 30 Jan 2019 01:23:13 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4O+BZtG92PfWTaPRGWjdeYi48X17CkKQi5ihVno5HJiBdQ/BX+iLEjJl6cvHb0SrlhDljP
X-Received: by 2002:a37:68a:: with SMTP id 132mr27583314qkg.89.1548840192690;
        Wed, 30 Jan 2019 01:23:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548840192; cv=none;
        d=google.com; s=arc-20160816;
        b=Jb+7VjMj1WHEVpVeEBPJ6rZMOrvTWxYHQ+3/3cPx1vXiMPEHBcGQsscoZHTs6FzZzM
         s9/O+jWz65+UWRbktqstw5CjNlaWnsWJVis7EzGpjwbnrJsptKQmLv0Q0SiFrrEdVN7S
         CsiDcoFitotmQbbk9AAcArH4+4FvdosaIDcFL2ZFm+OEw3+iB98UpDvpw6y+mFyAWOHg
         XaVdLbM5cJ+hA/XrmLeNpablwcOEWv+f61pR21eOHtN8vFEfJcSimlPVi9t7Mff0afqI
         Z9o9Npr+yz79VwY+HGaDlhtGLLvT3Qc8loQFbC09lEBUe5wEkM2dOfauIGY2bWlhF/+v
         8+DA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=VbAkpVm6aUtjplh15xW+8XFpBdphGmpE5hR4xv/5y9w=;
        b=HjGOkh7eEK9ww2GsRERKJO+2aAXyNe/qXOXTRlCzGB+GZyf1GNmL7XCIMK+ZG8dHC/
         Ss90BHPLmrIWqhQIniv3PXEJir69VxqBxgdFjQwdZoWY5SaFbhUKkrd/m0rfqyYdlJpf
         /3K2CFhgSmqqGVV906MAj6aO3TuaOSrENRtUbks90EtccRDxc1bHsUU5Rx1bHn/Mc8VQ
         Tj4RHnruNomRk5MQcOC5zkF3WhDudjaBmx6A4BqsX3m5uUtW/7Yn3EgbgD4ftkj8cUg2
         jJsa/nYaJD44SEjVp8NLVPW3CF6YjJ7ij/cgJRSoQ5uZeUGJS9wwe+Me9X/k5xIbXJKn
         gFBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b129si675914qke.179.2019.01.30.01.23.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 01:23:12 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9AEF98AE6F;
	Wed, 30 Jan 2019 09:23:11 +0000 (UTC)
Received: from xz-x1 (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 256A71A7CE;
	Wed, 30 Jan 2019 09:23:04 +0000 (UTC)
Date: Wed, 30 Jan 2019 17:23:02 +0800
From: Peter Xu <peterx@redhat.com>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
	lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Blake Caldwell <blake.caldwell@colorado.edu>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>,
	Vlastimil Babka <vbabka@suse.cz>,
	David Rientjes <rientjes@google.com>,
	Andrei Vagin <avagin@gmail.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>
Subject: Re: [LSF/MM TOPIC]: userfaultfd (was: [LSF/MM TOPIC] NUMA remote THP
 vs NUMA local non-THP under MADV_HUGEPAGE)
Message-ID: <20190130092302.GA25119@xz-x1>
References: <20190129234058.GH31695@redhat.com>
 <20190130081336.GC17937@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190130081336.GC17937@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 30 Jan 2019 09:23:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 10:13:36AM +0200, Mike Rapoport wrote:
> Hi,
> 
> (changed the subject and added CRIU folks)
> 
> On Tue, Jan 29, 2019 at 06:40:58PM -0500, Andrea Arcangeli wrote:
> > Hello,
> > 
> > --
> > 
> > In addition to the above "NUMA remote THP vs NUMA local non-THP
> > tradeoff" topic, there are other developments in "userfaultfd" land that
> > are approaching merge readiness and that would be possible to provide a
> > short overview about:
> > 
> > - Peter Xu made significant progress in finalizing the userfaultfd-WP
> >   support over the last few months. That feature was planned from the
> >   start and it will allow userland to do some new things that weren't
> >   possible to achieve before. In addition to synchronously blocking
> >   write faults to be resolved by an userland manager, it has also the
> >   ability to obsolete the softdirty feature, because it can provide
> >   the same information, but with O(1) complexity (as opposed of the
> >   current softdirty O(N) complexity) similarly to what the Page
> >   Modification Logging (PML) does in hardware for EPT write accesses.
>  
> We (CRIU) have some concerns about obsoleting soft-dirty in favor of
> uffd-wp. If there are other soft-dirty users these concerns would be
> relevant to them as well.
> 
> With soft-dirty we collect the information about the changed memory every
> pre-dump iteration in the following manner:
> * freeze the tasks
> * find entries in /proc/pid/pagemap with SOFT_DIRTY set
> * unfreeze the tasks
> * dump the modified pages to disk/remote host
> 
> While we do need to traverse the /proc/pid/pagemap to identify dirty pages,
> in between the pre-dump iterations and during the actual memory dump the
> tasks are running freely.
> 
> If we are to switch to uffd-wp, every write by the snapshotted/migrated
> task will incur latency of uffd-wp processing by the monitor.
> 
> We'd need to see how this affects overall slowdown of the workload under
> migration before moving forward with obsoleting soft-dirty.
> 
> > - Blake Caldwell maintained the UFFDIO_REMAP support to atomically
> >   remove memory from a mapping with userfaultfd (which can't be done
> >   with a copy as in UFFDIO_COPY and it requires a slow TLB flush to be
> >   safe) as an alternative to host swapping (which of course also
> >   requires a TLB flush for similar reasons). Notably UFFDIO_REMAP was
> >   rightfully naked early on and quickly replaced by UFFDIO_COPY which
> >   is more optimal to add memory to a mapping is small chunks, but we
> >   can't remove memory with UFFDIO_COPY and UFFDIO_REMAP should be as
> >   efficient as it gets when it comes to removing memory from a
> >   mapping.
> 
> If we are to discuss userfaultfd, I'd like also to bring the subject of COW
> mappings.
> The pages populated with UFFDIO_COPY cannot be COW-shared between related
> processes which unnecessarily increases memory footprint of a migrated
> process tree.
> I've posted a patch [1] a (real) while ago, but nobody reacted and I've put
> this aside.
> Maybe it's time to discuss it again :)

Hi, Mike,

It's interesting to know such a work...

Since I really don't have much context on this, so sorry if I'm going
to ask a silly question... but I'd say when reading this I'm thinking
of KSM.  I think KSM does not suite in this case since when doing
UFFDIO_COPY_COW it'll contain hinting information while KSM was only
scanning over the pages between processes which seems to be O(N*N) if
assuming there're two processes.  However, would it make any sense to
provide a general interface to scan for same pages between any two
processes within specific range and merge them if found (rather than a
specific interface for userfaultfd only)?  Then it might even be used
by KSM admins (just as an example) when the admin knows exactly that
memory range (addr1, len) of process A should very probably has many
same contents as the memory range (addr2, len) of process B?

Thanks,

-- 
Peter Xu

