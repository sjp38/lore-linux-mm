Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 609AEC10F14
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 13:42:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B0F820693
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 13:42:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B0F820693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 912C16B0007; Tue, 23 Apr 2019 09:42:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 899486B0008; Tue, 23 Apr 2019 09:42:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73BE86B000A; Tue, 23 Apr 2019 09:42:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 212996B0007
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 09:42:28 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id j9so3632034eds.17
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 06:42:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=CUxIXFnocJydptOGBP61OJ1zwduQcoA6qUjBz1+cU5c=;
        b=ddThBMj1I9sLhizg+oUR/hu6QrPEnWNSxeqGy69Pb5N2BJI/6kmdPFOen6O9QtTzPB
         DNtSAQPrrPfDVGkBrZ1fT23O4R9/WwYI+cDXgQFjpBl9qMQb9Xao59AooqwnPo0I7WjU
         +Ez41gjL9JvEGvxgwVqv8efPA/S35ipEAXmdO1BITu9c8xQaGfDJm6oroTRQqOlexMaK
         e25Iq19iPAXpREYLgN1ri3tff21MjAdPMPFJyEamlVbz9Wt6kRF7HsFSRQiO2UrW2/o6
         CiFGqype27yjYGYPpJibgaVAAr5SEjzAG4wt/QsO+HeCQNm7SR92nAiNKmjSlnK7Tfhq
         N+0Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXE3/ko9v4LrsQyMvB5ejTSwJcpPluWdYrvBSXkHGJw0xQ3OugU
	TinhiI94R5oyUc3NhHbmHxngGSq+W2t6JJgEjoy0ftD0C7BfR2We01WNzDfSGj+5kpbqDzqu/RS
	tYGYWUVinFwmHgsgzx5ow3tRMCJjI56N7FpRKgOqjUkD62busF2k+ym7UfZOdsow=
X-Received: by 2002:aa7:da18:: with SMTP id r24mr16452848eds.161.1556026947662;
        Tue, 23 Apr 2019 06:42:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzY+CH5aWVoXEnASdwmDkwbEKllQCKwWfeKP/rWUJpOz8M3Oj9EF+OE3Egz4VpOTt6YrQ6x
X-Received: by 2002:aa7:da18:: with SMTP id r24mr16452792eds.161.1556026946616;
        Tue, 23 Apr 2019 06:42:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556026946; cv=none;
        d=google.com; s=arc-20160816;
        b=SooD3mcPwpv4Pq/QvV6gn3Oh7eMMQ2e48tERCnLu4guey6OKlVmebzM6XdM55dRTtT
         Vmpbqxp83HwDn61WDaudVmKBLCf7HK/0S2UkzB6xIox9Ulpa331kerLQOGxD0tpGJC01
         hoVsZIG2bm+rWHs7Gx+CDMC968iG6x+fthXf0iVcraIEOC/Iv7gqWJSj6iYkNP6O8mzb
         WmHvAaOeb77IeoksglItILHII2SuzwXU9/puas0PtrLPhWL23WYlRhtLMo4717NbbzhC
         Sv3rB24P2VnjOB4pFST9EgO5e3AQAo9AKtKiM5gxrSjpSHj9D5rOIp2nUYTk6XiqOUZE
         7lHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=CUxIXFnocJydptOGBP61OJ1zwduQcoA6qUjBz1+cU5c=;
        b=YQqjGGdlgzvdYaw7xA2kxxET5nZic7rcF3ivdWtQ1WsbLU9qyp1bsUFXmq7nwpZJdd
         rvHX2Yn9NqRh5JSUeEZyTBtehZoodA4KnfnpCcZbAgvrPJgdeRHvIUojLCEDZwjggEmz
         tm4xmtm2c+XEZxTtQ3SrucnmwKy+XmdxAZFpze9UYctlfbmqDOV74X0aLG0hV5iZZwU5
         6tTwgwU4hFpeaL0EAvnaB1obIA/BrOuagH3uSLD2NfETKMutqK8xMcIOzcnjBXBDDOV0
         nXYUMVo4npuhuF750/EA/wQ4WrEDI/+53n4s3uVBMtZb1xwrq6pWbIB04h1c3AwIpipw
         pppA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g51si1819573eda.343.2019.04.23.06.42.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 06:42:26 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6E9C4ACAC;
	Tue, 23 Apr 2019 13:42:25 +0000 (UTC)
Date: Tue, 23 Apr 2019 15:42:22 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michel Lespinasse <walken@google.com>,
	Laurent Dufour <ldufour@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	Andi Kleen <ak@linux.intel.com>, dave@stgolabs.net,
	Jan Kara <jack@suse.cz>, aneesh.kumar@linux.ibm.com,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	mpe@ellerman.id.au, Paul Mackerras <paulus@samba.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>,
	Will Deacon <will.deacon@arm.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	sergey.senozhatsky.work@gmail.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>,
	David Rientjes <rientjes@google.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Ganesh Mahendran <opensource.ganesh@gmail.com>,
	Minchan Kim <minchan@kernel.org>,
	Punit Agrawal <punitagrawal@gmail.com>,
	vinayak menon <vinayakm.list@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	zhong jiang <zhongjiang@huawei.com>,
	Haiyan Song <haiyanx.song@intel.com>,
	Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
	Mike Rapoport <rppt@linux.ibm.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	haren@linux.vnet.ibm.com, Nick Piggin <npiggin@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	linuxppc-dev@lists.ozlabs.org, x86@kernel.org
Subject: Re: [PATCH v12 00/31] Speculative page faults
Message-ID: <20190423134222.GL25106@dhcp22.suse.cz>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <CANN689F1h9XoHPzr_FQY2WfN5bb2TTd6M3HLqoJ-DQuHkNbA7g@mail.gmail.com>
 <20190423104707.GK25106@dhcp22.suse.cz>
 <20190423124148.GA19031@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190423124148.GA19031@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 23-04-19 05:41:48, Matthew Wilcox wrote:
> On Tue, Apr 23, 2019 at 12:47:07PM +0200, Michal Hocko wrote:
> > On Mon 22-04-19 14:29:16, Michel Lespinasse wrote:
> > [...]
> > > I want to add a note about mmap_sem. In the past there has been
> > > discussions about replacing it with an interval lock, but these never
> > > went anywhere because, mostly, of the fact that such mechanisms were
> > > too expensive to use in the page fault path. I think adding the spf
> > > mechanism would invite us to revisit this issue - interval locks may
> > > be a great way to avoid blocking between unrelated mmap_sem writers
> > > (for example, do not delay stack creation for new threads while a
> > > large mmap or munmap may be going on), and probably also to handle
> > > mmap_sem readers that can't easily use the spf mechanism (for example,
> > > gup callers which make use of the returned vmas). But again that is a
> > > separate topic to explore which doesn't have to get resolved before
> > > spf goes in.
> > 
> > Well, I believe we should _really_ re-evaluate the range locking sooner
> > rather than later. Why? Because it looks like the most straightforward
> > approach to the mmap_sem contention for most usecases I have heard of
> > (mostly a mm{unm}ap, mremap standing in the way of page faults).
> > On a plus side it also makes us think about the current mmap (ab)users
> > which should lead to an overall code improvements and maintainability.
> 
> Dave Chinner recently did evaluate the range lock for solving a problem
> in XFS and didn't like what he saw:
> 
> https://lore.kernel.org/linux-fsdevel/20190418031013.GX29573@dread.disaster.area/T/#md981b32c12a2557a2dd0f79ad41d6c8df1f6f27c

Thank you, will have a look.

> I think scaling the lock needs to be tied to the actual data structure
> and not have a second tree on-the-side to fake-scale the locking.  Anyway,
> we're going to have a session on this at LSFMM, right?

I thought we had something for the mmap_sem scaling but I do not see
this in a list of proposed topics. But we can certainly add it there.

> > SPF sounds like a good idea but it is a really big and intrusive surgery
> > to the #PF path. And more importantly without any real world usecase
> > numbers which would justify this. That being said I am not opposed to
> > this change I just think it is a large hammer while we haven't seen
> > attempts to tackle problems in a simpler way.
> 
> I don't think the "no real world usecase numbers" is fair.  Laurent quoted:
> 
> > Ebizzy:
> > -------
> > The test is counting the number of records per second it can manage, the
> > higher is the best. I run it like this 'ebizzy -mTt <nrcpus>'. To get
> > consistent result I repeated the test 100 times and measure the average
> > result. The number is the record processes per second, the higher is the best.
> > 
> >   		BASE		SPF		delta	
> > 24 CPUs x86	5492.69		9383.07		70.83%
> > 1024 CPUS P8 VM 8476.74		17144.38	102%
> 
> and cited 30% improvement for you-know-what product from an earlier
> version of the patch.

Well, we are talking about
45 files changed, 1277 insertions(+), 196 deletions(-)

which is a _major_ surgery in my book. Having a real life workloads numbers
is nothing unfair to ask for IMHO.

And let me remind you that I am not really opposing SPF in general. I
would just like to see a simpler approach before we go such a large
change. If the range locking is not really a scalable approach then all
right but from why I've see it should help a lot of most bottle-necks I
have seen.
-- 
Michal Hocko
SUSE Labs

