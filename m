Return-Path: <SRS0=SJ39=PZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE1ABC43612
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 17:20:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9180A20851
	for <linux-mm@archiver.kernel.org>; Thu, 17 Jan 2019 17:20:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9180A20851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1EAD08E000B; Thu, 17 Jan 2019 12:20:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 172338E0002; Thu, 17 Jan 2019 12:20:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 013958E000B; Thu, 17 Jan 2019 12:20:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C4FFF8E0002
	for <linux-mm@kvack.org>; Thu, 17 Jan 2019 12:20:12 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id u20so9682083qtk.6
        for <linux-mm@kvack.org>; Thu, 17 Jan 2019 09:20:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=Nz3Z7thQCVhQrXLgFx8SbhFu06+rZQUBfHpodnBBGfQ=;
        b=mB5pfYpFVrvvgWBkUi6CCkcjgUaTFlG+OINMh58q5O48s06wz90qx1p2Xso3tYWgIa
         5pFJX6RfyThtezEDPYlDK0Wdr1Qw3APTPOBpEaekL8PrOWUg1jL/n9SfF7GMPwGUWJeA
         RkTSkAULWCy2UU7FVJp+FObly1Ll17PMhQIuLQw/hg7zwccKUXu0RAzweNIrxCVE5/ZR
         heh+AI+9eViua4+t9XruTFyiq9tI8hmc1VpJP9lXUBhHGdPDJcsbT+NEge3+iTDNdKMM
         +r2YUSdMbP/IFt3iNsVbUfch5VpvaXx6Az0V+cMuL1PWbQq3XQgXUvIuMLFHeky4nCxS
         tmEg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukcKpgBnALxfX9ngwwXr6fC5IV2ekBBv/SOMDTUpu54vW5qwYxtv
	thp5ockF3amLvPx4XIbaHmMeY/ORpv1F8eFmGPRcOUfUhEztN1gphJchOqmner6WlS20cm+bvSo
	KSk4y18ZjU8XER21pTFTObTvEApadLOFVcm0oz6zQFzhDdtV0fQmyV3s2+RZM0LAGEA==
X-Received: by 2002:a37:9906:: with SMTP id b6mr11707522qke.208.1547745612544;
        Thu, 17 Jan 2019 09:20:12 -0800 (PST)
X-Google-Smtp-Source: ALg8bN53XqC0M8lj9INz9YOYKM6R5sPe3aABPCdHVJHKKvGUd5D7qw1jTnodSx1caBmeMWqMVvtw
X-Received: by 2002:a37:9906:: with SMTP id b6mr11707479qke.208.1547745611903;
        Thu, 17 Jan 2019 09:20:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547745611; cv=none;
        d=google.com; s=arc-20160816;
        b=ERoWuTODLug7NwY+hA18ojCu6j69FN2/j/gWQO12hudJF2reuwrGTedOMEmjEGVdr/
         eSqS1bMhLVrdwApZ31KjX65uuttkj/Dy5KVaOvw/KBNi7ytVQQnaQPH9Zue5WuRvtMPW
         rB29o2EbTdTEXFwymXZXZcpx12tfzfEVC8+DSXw4zRHveOgf3XeCtrDIkrMfpV/RMIbj
         gq6F9jLUhVidXdoLPC+cz7U/7MqzZmfbmC/XBU+vmlKfW9KPfln+OglH9udswR8xDWLz
         fvk4BcrKNddyMKyilBgTSHKBYkyj1YImk9snTJM4uUw499ZQMjOA0K/Urf0skuQWdx0f
         zBDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=Nz3Z7thQCVhQrXLgFx8SbhFu06+rZQUBfHpodnBBGfQ=;
        b=I4HoOaknX9C1o1cmPQhCuTYk5DpNiC3QvQ90JNx6gVzyCy9Zeqf3Tmf7zknke49/da
         8+MYESD8JyqZDA1K6BGhuoFL4lEyjYyeUFmo0bJpaaaGk1V/xax9IctcT+4E8dsXrcsr
         BxnXhar1V8MleivmDBx3WmUV3e67BklabUEnQKok8TxQj31M6MH25keZw8WI87pgZB8M
         KSmYQXuGsB1ynqQaOdsZSG3yjZ2G8L1/N1xuGlcjW8cIA3Wme+bNSRcQjYevXKSq5tX4
         EfP19HQii/+5Xk3eSwVWEfDheT54U3iLGNZ1by3kcz7XuUOQCmNdu8G0dx+Wx6Soxr1c
         JFYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o44si808697qtc.134.2019.01.17.09.20.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Jan 2019 09:20:11 -0800 (PST)
Received-SPF: pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 553A681DED;
	Thu, 17 Jan 2019 17:20:10 +0000 (UTC)
Received: from segfault.boston.devel.redhat.com (segfault.boston.devel.redhat.com [10.19.60.26])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A702B61B63;
	Thu, 17 Jan 2019 17:20:07 +0000 (UTC)
From: Jeff Moyer <jmoyer@redhat.com>
To: Keith Busch <keith.busch@intel.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>,  thomas.lendacky@amd.com,  fengguang.wu@intel.com,  dave@sr71.net,  linux-nvdimm@lists.01.org,  tiwai@suse.de,  zwisler@kernel.org,  linux-kernel@vger.kernel.org,  linux-mm@kvack.org,  mhocko@suse.com,  baiyaowei@cmss.chinamobile.com,  ying.huang@intel.com,  bhelgaas@google.com,  akpm@linux-foundation.org,  bp@suse.de
Subject: Re: [PATCH 0/4] Allow persistent memory to be used like normal RAM
References: <20190116181859.D1504459@viggo.jf.intel.com>
	<x49sgxr9rjd.fsf@segfault.boston.devel.redhat.com>
	<20190117164736.GC31543@localhost.localdomain>
X-PGP-KeyID: 1F78E1B4
X-PGP-CertKey: F6FE 280D 8293 F72C 65FD  5A58 1FF8 A7CA 1F78 E1B4
Date: Thu, 17 Jan 2019 12:20:06 -0500
In-Reply-To: <20190117164736.GC31543@localhost.localdomain> (Keith Busch's
	message of "Thu, 17 Jan 2019 09:47:37 -0700")
Message-ID: <x49pnsv8am1.fsf@segfault.boston.devel.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Thu, 17 Jan 2019 17:20:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190117172006.Ngpd1XuatYS80SAUPr9xAWLfbn-5wYHoo-9-KARExLA@z>

Keith Busch <keith.busch@intel.com> writes:

> On Thu, Jan 17, 2019 at 11:29:10AM -0500, Jeff Moyer wrote:
>> Dave Hansen <dave.hansen@linux.intel.com> writes:
>> > Persistent memory is cool.  But, currently, you have to rewrite
>> > your applications to use it.  Wouldn't it be cool if you could
>> > just have it show up in your system like normal RAM and get to
>> > it like a slow blob of memory?  Well... have I got the patch
>> > series for you!
>> 
>> So, isn't that what memory mode is for?
>>   https://itpeernetwork.intel.com/intel-optane-dc-persistent-memory-operating-modes/
>> 
>> Why do we need this code in the kernel?
>
> I don't think those are the same thing. The "memory mode" in the link
> refers to platforms that sequester DRAM to side cache memory access, where
> this series doesn't have that platform dependency nor hides faster DRAM.

OK, so you are making two arguments, here.  1) platforms may not support
memory mode, and 2) this series allows for performance differentiated
memory (even though applications may not modified to make use of
that...).

With this patch set, an unmodified application would either use:

1) whatever memory it happened to get
2) only the faster dram (via numactl --membind=)
3) only the slower pmem (again, via numactl --membind1)
4) preferentially one or the other (numactl --preferred=)

The other options are:
- as mentioned above, memory mode, which uses DRAM as a cache for the
  slower persistent memory.  Note that it isn't all or nothing--you can
  configure your system with both memory mode and appdirect.  The
  limitation, of course, is that your platform has to support this.

  This seems like the obvious solution if you want to make use of the
  larger pmem capacity as regular volatile memory (and your platform
  supports it).  But maybe there is some other limitation that motivated
  this work?

- libmemkind or pmdk.  These options typically* require application
  modifications, but allow those applications to actively decide which
  data lives in fast versus slow media.

  This seems like the obvious answer for applications that care about
  access latency.

* you could override the system malloc, but some libraries/application
  stacks already do that, so it isn't a universal solution.

Listing something like this in the headers of these patch series would
considerably reduce the head-scratching for reviewers.

Keith, you seem to be implying that there are platforms that won't
support memory mode.  Do you also have some insight into how customers
want to use this, beyond my speculation?  It's really frustrating to see
patch sets like this go by without any real use cases provided.

Cheers,
Jeff

