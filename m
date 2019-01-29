Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18917C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:21:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C9A222175B
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:21:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C9A222175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7EBDC8E0002; Tue, 29 Jan 2019 11:21:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7C21F8E0001; Tue, 29 Jan 2019 11:21:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B1B68E0002; Tue, 29 Jan 2019 11:21:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3DCDA8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:21:20 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id s70so22384265qks.4
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:21:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Wn4mNasI+VoafuDA+rRPeKct8MR8jc/exxAizE97c18=;
        b=kH1eYKQV1bXYY1tHuaNYXvA65Jz8u8mUj1piimKsdSkxsuw8vMQt7HLn86EHocBVMu
         i40nm6Wtq9x0I+XgMRR8a64fSA8Sf6Fmgx+O9PdxX1t06xWTSA8LL58dS5UDUt1bOcb2
         ZHHAOS0KyPsiPTYR7IXE2Roei4zDxvcHuiXxw2wuOAWroJrj4gzSHD3EeP/JqqBTkSA6
         Wwvb8fe8HGwKt0RLPNt4wPWqY7gDc82y+V0q1X3ZYjbXsWq0X0NqSI09qht0ii6/Tb7y
         HLRvCEGa0m2gldftZ1XpDhvaxCMdxpCEVi9wSwbSjfOL8g+mATJKz6NeSwT3XP78J5gt
         qRRw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukf2xfdlTSIukHQcAJCI6A3Y+sFNMk2GXYEan7LBOtKi+lThtsaB
	DP2HsWC+c3iaxpn29Ke64u2SOqfYZLTr3C1g0qIfEYanITj6NsMZFPrik2dzoBBUyfSgRZtAGev
	jMRRWRqxF+Ahn5ztW4pGQs+hQm5Cma0fd2VS2R7NdLpgxR05qZ6d2b1YIB0Iq9rNuvg==
X-Received: by 2002:ac8:2e6a:: with SMTP id s39mr26705842qta.355.1548778879956;
        Tue, 29 Jan 2019 08:21:19 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5CDrF3L02ZTyXMUtcn/7sT7uA8fOXUTz7Co0rwd+UemFclaQgJRfNGDG7/C7XcJ57SuINJ
X-Received: by 2002:ac8:2e6a:: with SMTP id s39mr26705794qta.355.1548778879127;
        Tue, 29 Jan 2019 08:21:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548778879; cv=none;
        d=google.com; s=arc-20160816;
        b=ys9JluTPZy7RaUZ+5cTNDMZe3bq/WLqxUwQF2HGsyE6lTyTWEmI2dAcTcKei/C/RsN
         EfReLLIt67L9Qw2a4kauqroFG+mIHlV8apIPsh8HAmRBVOkYDz+JdWSjX4BuMfhkMVZ4
         wmjcOSqPzqblSyB/P7AChLD+eP9EVxn1tRoG08WHKQ5ZpbRKyLedlhjUD2CkKb7N0dgM
         Tn9LCk1RsYu02KWW242Bs5HL8cY8ElUSYHzs3/AHFKCFPPf8lWmtPRQ48RKVgtHbE826
         rjeAK38nR8ZyePG5Ty0yMhkxSoIg5MOyRdFgqPSgoCS3XWzOdTcuo1pECDu4q12INBjt
         8e1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=Wn4mNasI+VoafuDA+rRPeKct8MR8jc/exxAizE97c18=;
        b=s0Iml1A0SAm/yaNs8thaUKW9SWggkUUQMeO4k9m4yviazsnqyxIEEpf+/9SVAoUUCx
         PbOg52CaSWLUL8/yj1o4F349nMalem3t2TqoXa4zuneZLwBJieWsT/YR+RSZAK7yOmXP
         QisJPtE5XeXS39B3rFzkMyrFZfTIqSxBACf2eUjl4lzl7rg2M7+duEA/PXXhQtvDSteb
         DFMSzFhg0I0yxHLFBkcr9XR20lqEd4B9O/PS60LYo5DvJEg3GFBueLMGesAeM91wEQN/
         xzZbwB+YKiuDmzxmfIA/xpOgb5fSOycGSU+K8D676Us+Bf/TLUY00do0AQsbQfIP2PKh
         zdaA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p64si168874qka.149.2019.01.29.08.21.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 08:21:19 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BFE45CD243;
	Tue, 29 Jan 2019 16:21:17 +0000 (UTC)
Received: from redhat.com (ovpn-123-178.rdu2.redhat.com [10.10.123.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 39DC219743;
	Tue, 29 Jan 2019 16:21:15 +0000 (UTC)
Date: Tue, 29 Jan 2019 11:21:13 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: linux-mm@kvack.org, Ralph Campbell <rcampbell@nvidia.com>,
	Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>,
	kvm@vger.kernel.org, Matthew Wilcox <mawilcox@microsoft.com>,
	linux-rdma@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Dan Williams <dan.j.williams@intel.com>,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	Michal Hocko <mhocko@kernel.org>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ross Zwisler <zwisler@kernel.org>, linux-fsdevel@vger.kernel.org,
	Paolo Bonzini <pbonzini@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>
Subject: Re: [PATCH v4 8/9] gpu/drm/i915: optimize out the case when a range
 is updated to read only
Message-ID: <20190129162112.GA3194@redhat.com>
References: <20190123222315.1122-1-jglisse@redhat.com>
 <20190123222315.1122-9-jglisse@redhat.com>
 <154833175216.4120.925061299171157938@jlahtine-desk.ger.corp.intel.com>
 <20190124153032.GA5030@redhat.com>
 <154877159986.4387.16328989441685542244@jlahtine-desk.ger.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <154877159986.4387.16328989441685542244@jlahtine-desk.ger.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 29 Jan 2019 16:21:18 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 04:20:00PM +0200, Joonas Lahtinen wrote:
> Quoting Jerome Glisse (2019-01-24 17:30:32)
> > On Thu, Jan 24, 2019 at 02:09:12PM +0200, Joonas Lahtinen wrote:
> > > Hi Jerome,
> > > 
> > > This patch seems to have plenty of Cc:s, but none of the right ones :)
> > 
> > So sorry, i am bad with git commands.
> > 
> > > For further iterations, I guess you could use git option --cc to make
> > > sure everyone gets the whole series, and still keep the Cc:s in the
> > > patches themselves relevant to subsystems.
> > 
> > Will do.
> > 
> > > This doesn't seem to be on top of drm-tip, but on top of your previous
> > > patches(?) that I had some comments about. Could you take a moment to
> > > first address the couple of question I had, before proceeding to discuss
> > > what is built on top of that base.
> > 
> > It is on top of Linus tree so roughly ~ rc3 it does not depend on any
> > of the previous patch i posted.
> 
> You actually managed to race a point in time just when Chris rewrote much
> of the userptr code in drm-tip, which I didn't remember of. My bad.
> 
> Still interested to hearing replies to my questions in the previous
> thread, if the series is still relevant. Trying to get my head around
> how the different aspects of HMM pan out for devices without fault handling.

HMM mirror does not need page fault handling for everything and in fact
for user ptr you can use HMM mirror without page fault support in hardware.
Page fault requirement is more like a __very__ nice to have feature.

So sorry i missed that mail i must had it in a middle of bugzilla spam
and deleted it. So here is a paste of it and answer. This was for a
patch to convert i915 to use HMM mirror instead of having i915 does it
own thing with GUP (get_user_page).

> Bit late reply, but here goes :)
>
> We're working quite hard to avoid pinning any pages unless they're in
> the GPU page tables. And when they are in the GPU page tables, they must
> be pinned for whole of that duration, for the reason that our GPUs can
> not take a fault. And to avoid thrashing GPU page tables, we do leave
> objects in page tables with the expectation that smart userspace
> recycles buffers.

You do not need to pin the page because you obey to mmu notifier ie
it is perfectly fine for you to keep the page map into the GPU until
you get an mmu notifier call back for the range of virtual address.

The pin from GUP in fact does not protect you from anything. GUP is
really misleading, by the time GUP return the page you get might not
correspond to the memory backing the virtual address.

In i915 code this is not an issue because you synchronize against
mmu notifier call back.

So my intention in converting GPU driver from GUP to HMM mirror is
just to avoid the useless page pin. As long as you obey the mmu
notifier call back (or HMM sync page table call back) then you are
fine.

> So what I understand of your proposal, it wouldn't really make a
> difference for us in the amount of pinned pages (which I agree,
> we'd love to see going down). When we're unable to take a fault,
> the first use effectively forces us to pin any pages and keep them
> pinned to avoid thrashing GPU page tables.

With HMM there is no pin, we never pin the page ie we never increment
the refcount on the page as it is useless to do so if you abide by
mmu notifier. Again the pin GUP take is misleading it does not block
mm event.

However Without pin and still abiding to mmu notifier you will not
see any difference in thrashing ie number of time you will get a mmu
notifier call back. As really those call back happens for good reasons.
For instance running out of memory and kernel trying to reclaim or
because userspace did a syscall that affect the range of virtual address.

This should not happen in regular workload and when they happen the pin
from GUP will not inhibit those either. In the end you will get the exact
same amount of trashing but you will inhibit thing like memory compaction
or migration while HMM does not block those (ie HMM is a good citizen ;)
while GUP user are not).

Also we are in the process of changing GUP and GUP will now have more
profound impact to filesystem and mm (inhibiting and breaking some of
the filesystem behavior). Converting GPU driver to HMM will avoid those
adverse impact and it is one of the motivation behind my crusade to
convert all GUP user that abide by mmu notifier to use HMM instead.


> So from i915 perspective, it just seems to be mostly an exchange of
> an API to an another for getting the pages. You already mentioned
> the fast path is being worked on, which is an obvious difference.
> But is there some other improvement one would be expecting, beyond
> the page pinning?

So for HMM i have a bunch of further optimization and new feature.
Using HMM would make it easier for i915 to leverage those.

> Also, is the requirement for a single non-file-backed VMA in the
> plans of being eliminated or is that inherent restriction of the
> HMM_MIRROR feature? We're currently not imposing such a limitation.

HMM does not have that limitation, never did. It seems that i915
unlike other driver does allow GUP on file back page, while other
GPU driver do not. So i made the assumption the i915 did have that
limitation without checking the code.


> > I still intended to propose to remove
> > GUP from i915 once i get around to implement the equivalent of GUP_fast
> > for HMM and other bonus cookies with it.
> > 
> > The plan is once i have all mm bits properly upstream then i can propose
> > patches to individual driver against the proper driver tree ie following
> > rules of each individual device driver sub-system and Cc only people
> > there to avoid spamming the mm folks :)
> 
> Makes sense, as we're having tons of changes in this field in i915, the
> churn to rebase on top of them will be substantial.

I am posting more HMM bits today for 5.1, i will probably post another i915
patchset in coming weeks. I will try to base it on for-5.1-drm tree as i am
not only doing i915 but amd too and it is easier if i can do all of them in
just one tree so i only have to switch GPU not kernel too for testing :)

> 
> Regards, Joonas
> 
> PS. Are you by any chance attending FOSDEM? Would be nice to chat about
> this.

No i am not going to fosdem :(

Cheers,
Jérôme

