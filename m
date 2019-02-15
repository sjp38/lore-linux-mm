Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BAABBC10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 14:07:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8258E218FF
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 14:07:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8258E218FF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25E268E0002; Fri, 15 Feb 2019 09:07:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20AB48E0001; Fri, 15 Feb 2019 09:07:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FC5B8E0002; Fri, 15 Feb 2019 09:07:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A96B28E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 09:07:56 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id o14so2011869edr.15
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 06:07:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=V8+OciJ34LGUZh9kh6Na2eF+FkItn9FDwwtQKyW+ihc=;
        b=NNJ1v/00xGjURpkvE7Q/hO4i42dYwTZpeQznVbedEOEZCyOzupEPKXQp9VwSfDV+Ql
         2rPvxuCD8x7ZecRJz4nWkRkP+yHeTfFnOFbPTjRedB65+CTtjrAtUqKHxuWLs7Meb0T6
         EePiwy5uKyQoNGhrvvSkQUdO1tfUaQGCmUQ2Ju9ElTqrbufHkTo3EJghn4TnItP3g+ni
         vq7V5W2488MQ/5bH47203TzXAQC4ZPYtaFR2EZNKLu27HEKUUz/TESVLoBs9xR5082Jy
         uiDJXb01C+Qp/3CI5bRLyyWJoAOFDAJqOEUnSObBGztMjcE+TbMvmBJjQNaP+qtxCZBn
         Kr1g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: AHQUAuZiAz/gK6qyf1X8bb2brsOhfbDr0y4cHF/pA7PnziVh0O9luumc
	3kps1UH02FhVLTc4O+OFTG9BPPBSmb0b/xJzUfZr/mTVSfjbPcUxtIjBGN1uJg3bCXvs4918fcg
	fq940HaKebWHeb8oFA2ACm2zYgKNcelUXC9j5JRf84UcxZ/GLvNtxxPAUmwGi+DjhUQ==
X-Received: by 2002:aa7:c981:: with SMTP id c1mr7774837edt.54.1550239676245;
        Fri, 15 Feb 2019 06:07:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZVMydbDRnkccADKXXCNv0lAOG3Xbt7Y4A29Nbt6XaUi/vetIdrkmC4QRkvlVAtwbX58k1Y
X-Received: by 2002:aa7:c981:: with SMTP id c1mr7774787edt.54.1550239675425;
        Fri, 15 Feb 2019 06:07:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550239675; cv=none;
        d=google.com; s=arc-20160816;
        b=gA5o6KKTeOlDztdVKStVYWzzaNSfYKfk6SzzXt3We2spthTWlGaEyCpkHdtRJv2+5I
         +WtNchXRLCdW6Fi9I+XqNvjmEzyBCE2Py3iOFUYNDYcYQoRMRlDxK8vyK20uI8bh8pS6
         wp3VGHEgF57vOjpuIxVaAFfMJ/7322TJjbsLckz6lbvqlFYsueHho4YbIJ2HHPA1pT1r
         7UeadBNeqaN4vhHtuJtq+lyw38FqIai8AtbNbh5LLhApl7CZZhc28j/FF1f2opiFa//a
         jdsUbMPSwfBF4h5zvbedR8qMmvHTOOeU1Q1vRkHuzt3ZJPkOz3u4AIq0MvzCvrBBffo6
         SXqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=V8+OciJ34LGUZh9kh6Na2eF+FkItn9FDwwtQKyW+ihc=;
        b=y1h08d5m3JB3nA4SwOCuqj3f2svMkjKkzySaeQN3V//CEGV89BXXfjneudDT+5xFd8
         k61PzbI4rbvhx/8NGax3k6aovIAy9aqWAmyEgtZeZX86g7hQ3pvDkaYfVBZbq8ZmTW2j
         NtS7pcROuiknmEL0If37+Z5E6tvy05Y7ONqGoILMjIdKsd0Iz4AlPbzUxL3Na9DEdtET
         z98MOmRcaunnDw2zLelcKrqi+jOceEXDh4CCrfLi7FpfUuxblXbHD8EvlO4fD2myncNA
         A89jVRDvpgrDwWSl1V4h8yBrAH0oNyXvnbkcf6SSqswUHiQ5Yn8LTxhqZ0ij7bSbOGHQ
         wOww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i22-v6si2250941ejd.95.2019.02.15.06.07.55
        for <linux-mm@kvack.org>;
        Fri, 15 Feb 2019 06:07:55 -0800 (PST)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6986BA78;
	Fri, 15 Feb 2019 06:07:54 -0800 (PST)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BC1E63F575;
	Fri, 15 Feb 2019 06:07:51 -0800 (PST)
Date: Fri, 15 Feb 2019 14:07:49 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	kasan-dev@googlegroups.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Qian Cai <cai@lca.pw>,
	Vincenzo Frascino <vincenzo.frascino@arm.com>,
	Kostya Serebryany <kcc@google.com>,
	Evgeniy Stepanov <eugenis@google.com>
Subject: Re: [PATCH v2 3/5] kmemleak: account for tagged pointers when
 calculating pointer range
Message-ID: <20190215140748.GE100037@arrakis.emea.arm.com>
References: <cover.1550066133.git.andreyknvl@google.com>
 <16e887d442986ab87fe87a755815ad92fa431a5f.1550066133.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <16e887d442986ab87fe87a755815ad92fa431a5f.1550066133.git.andreyknvl@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 02:58:28PM +0100, Andrey Konovalov wrote:
> kmemleak keeps two global variables, min_addr and max_addr, which store
> the range of valid (encountered by kmemleak) pointer values, which it
> later uses to speed up pointer lookup when scanning blocks.
> 
> With tagged pointers this range will get bigger than it needs to be.
> This patch makes kmemleak untag pointers before saving them to min_addr
> and max_addr and when performing a lookup.
> 
> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>

I reviewed the old series. This patch also looks fine:

Acked-by: Catalin Marinas <catalin.marinas@arm.com>

