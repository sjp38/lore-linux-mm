Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A96A3C32751
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 20:01:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6985821E73
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 20:01:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="zQWA7F1K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6985821E73
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AC356B0003; Wed,  7 Aug 2019 16:01:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 05EE96B0006; Wed,  7 Aug 2019 16:01:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E8CE36B0007; Wed,  7 Aug 2019 16:01:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B53FA6B0003
	for <linux-mm@kvack.org>; Wed,  7 Aug 2019 16:01:24 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id q11so53827754pll.22
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 13:01:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=R7q4DOl8O4PE+6BWh0cAXRcqIQUKkm71xqz/IGPsB+c=;
        b=PnPjqmKBkh27TxnKTZlMCECRtdnDws6z2rKbcghTk4Pc8RHBsWb7Dm00JhJdR/U0cm
         8Ki6REtb44RKvbunA+BEXg53ZXUzU12dV0JJHfaWB067wjSlYX3hgcQoHPcrUMnV+1fM
         Q2y+PL1RnzrqfESyi720vHyOHVFntJH6hU56EIlEDhVkZCTdoIJ1eSrVuWWg5zMD079N
         Br2aVN4tpt4LqEuJNOD59InznvWR/9iiBP6g4Qa3DhAKU1Balz3e1lSXjrHS5zmvrmcZ
         KYL1yz2NbKPsjMbLN+rWjfo/z0KxnXAXrtkFmTFxjaUCfuD1ShcZNxgINl5kJC3o8ZFC
         mROQ==
X-Gm-Message-State: APjAAAUt0tIpgJYrATyRJSk4Ur8A4dir7mkWQzHi56lU2gwIVMJOAppZ
	sStXLuiMTOAgpzp+bFkwB2lx7SAeg6KWy8WcqwfZu9X9Ge2yPfcXYaEPvqs1V3FkozNEmHX0bfD
	ZDqx5MsnZII2ZYxmk1tleoIP607d0QJdHaHTXSRGM9l9yq4H23OXjE/UK9P3ruPuREg==
X-Received: by 2002:a17:902:d892:: with SMTP id b18mr9130979plz.165.1565208084412;
        Wed, 07 Aug 2019 13:01:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyLDsg68ZLs2/G19yhqDXUo9xATLFgpzQ/YcemeOFTd1zvgNviCW9iXETxPTfzXGMdL0LCh
X-Received: by 2002:a17:902:d892:: with SMTP id b18mr9130926plz.165.1565208083705;
        Wed, 07 Aug 2019 13:01:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565208083; cv=none;
        d=google.com; s=arc-20160816;
        b=uUnXYxVlrx0lS9VbClJoL3vhywV4Ebzp8W1R6jrpoM4Nv+ijHUC+EcOMFXuH5KpS//
         ekWGzjbilkmODDYGsB0wRKvyCx1U2qlULq8CZe0eFRVEdBVevYy1WbtM3ZVAlXYoUF4j
         ps94vndPNExdBJCSXv19L3C40fro1qBMIBgc+PATa0kXLv1yPOMa4ZLyGmGciDdhuzk1
         r3xfJ6Tq+VzP6To+FEuyCly3rXL6p0mR3k/mbbRUFuR/H4o/xRFQTFYAMZLS8jGOZyyf
         pvgjcUhZjXyKSMcsMSWp5Gk6NjuPOtNnSGFFrOOdEUYVl3Yv1qspPxoONVkm3RwL32AI
         0/Fg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=R7q4DOl8O4PE+6BWh0cAXRcqIQUKkm71xqz/IGPsB+c=;
        b=snJQ1eDTCVlkPupOJkbyDdmZrZ6efxBzljKD49O8C9yFkmExpevHDs+Fg1PzdtEWMu
         9TvW+CUApHAbOMK5UhhVRrZHGw6S0XLjk7KhIUq9+0dlkqIvg9BCIWla4S8c3jI5XMJe
         FHYzrTh5BAENazjqLno3RSS5XjdKTLrEsX6jeTjAfA50Hg1yCIF8IEc8lybYdAQO8jRa
         pXm0XOSGhQKFflLUf2+qfDrtmo6lgyUekBWqfy4OGz/wjS4ZLBwydd1tBrbUhSZomdJk
         3g+gxG5/vmYuZj2liyvFvk9v96BllanysaWd8o5IqKbmFES+w9CovlEJeF7hO31ic8j8
         3TFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=zQWA7F1K;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id u15si51473680pgn.178.2019.08.07.13.01.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Aug 2019 13:01:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=zQWA7F1K;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6D7B42229C;
	Wed,  7 Aug 2019 20:01:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1565208083;
	bh=4Y+9zhlp+p8rLuzDnvz16xcsN6RE4cU24OrOaFTWccE=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=zQWA7F1KoIQRCIl1yVyS0BiJUwsrwYEryJKxMHNxcX6ONB8eZ93zxVmeDQ44zmmr7
	 94PMczCgAY0emIRaZfVAe7SJ/fxtD+5a/tCkNgG8bpb7LPhysLSpabBlToJlvBBdXz
	 27kDL9DLZKISnabXM7rW3N8cStMFHWeqYCj5Xb7E=
Date: Wed, 7 Aug 2019 13:01:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: linux-kernel@vger.kernel.org, Alexey Dobriyan <adobriyan@gmail.com>,
 Borislav Petkov <bp@alien8.de>, Brendan Gregg <bgregg@netflix.com>, Catalin
 Marinas <catalin.marinas@arm.com>, Christian Hansen <chansen3@cisco.com>,
 dancol@google.com, fmayer@google.com, "H. Peter Anvin" <hpa@zytor.com>,
 Ingo Molnar <mingo@redhat.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook
 <keescook@chromium.org>, kernel-team@android.com,
 linux-api@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Michal Hocko
 <mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>, minchan@kernel.org,
 namhyung@google.com, paulmck@linux.ibm.com, Robin Murphy
 <robin.murphy@arm.com>, Roman Gushchin <guro@fb.com>, Stephen Rothwell
 <sfr@canb.auug.org.au>, surenb@google.com, Thomas Gleixner
 <tglx@linutronix.de>, tkjos@google.com, Vladimir Davydov
 <vdavydov.dev@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Will Deacon
 <will@kernel.org>, Brendan Gregg <brendan.d.gregg@gmail.com>
Subject: Re: [PATCH v4 1/5] mm/page_idle: Add per-pid idle page tracking
 using virtual indexing
Message-Id: <20190807130122.f148548c05ec07e7b716457e@linux-foundation.org>
In-Reply-To: <20190807100013.GC169551@google.com>
References: <20190805170451.26009-1-joel@joelfernandes.org>
	<20190806151921.edec128271caccb5214fc1bd@linux-foundation.org>
	<20190807100013.GC169551@google.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 7 Aug 2019 06:00:13 -0400 Joel Fernandes <joel@joelfernandes.org> wrote:

> > > 8 files changed, 376 insertions(+), 45 deletions(-)
> > 
> > Quite a lot of new code unconditionally added to major architectures. 
> > Are we confident that everyone will want this feature?
> 
> I did not follow, could you clarify more? All of this diff stat is not to
> architecture code:


My point is that the patchset adds a lot of new code with no way in
which users can opt out.  Almost everyone gets a fatter kernel - how
many of those users will actually benefit from it?

If "not many" then shouldn't we be making it Kconfigurable?

Are there userspace tools which present this info to users or which
provide monitoring of some form?  Do major distros ship those tools? 
Do people use them?  etcetera.

