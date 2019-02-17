Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 623DFC43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 21:54:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDAE02146E
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 21:54:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="D/nfPrYe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDAE02146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6482E8E0002; Sun, 17 Feb 2019 16:54:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D2988E0001; Sun, 17 Feb 2019 16:54:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4730F8E0002; Sun, 17 Feb 2019 16:54:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0305E8E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 16:54:08 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id g188so10560161pgc.22
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 13:54:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=hW6qubX20Gip4JuCPw9oiQx7hX8cH1JQ7TKmCE4msZo=;
        b=bWNPG/yQIK8RKKeEIgAwEu6Uo3jn1Fyo/7Qq5uk0vXd4d0J5kApL5egGg4qysI/SiA
         SyJkC8/rqctocDeV9zrDoZShE0NAJpJ4qDAfec8zyqlMckg1G1GT9Jlk+R8ncLSRvUBz
         /25Q9EAVpsR/jU7e7jp6jAwz8YaHrfCrwmcUx0ERpOmN/6/NFhJseIENKiBTzmTdJd2m
         DRx8QJy+IQg8sfp/2ZVp471gEdLoMl6N5D8q1MHLEFx/cpHHAdf+d2eMEo5poeSzkp/m
         mI/GVjA6ZnCV/WH0HrLeov0/QsIgQtTyl8D9+OxMEconmgEsfBuGXWGGBqWjHty710GX
         dYgg==
X-Gm-Message-State: AHQUAuYwwYtpQb18yQJWoh6KGgUlaFs9McG51Qm+jKJOl1GTNN4/I1Ni
	wFZdD7b+W6C3HM4g4l/lh/DN5c9YkeirNmWHaN74bjtJ3/so0Jw/alK1ryyEzp0H+weykST6DA9
	X8UlFcSOfwK3x9E2RYVS6g+77eqphssPc74UOmnc9RMzh875HARx4lkVLjD6erdcX6hcUK+C573
	nNbZUugZk+/R9siNKDVa0ub0Br5URvy0rJ/h4OqZpEvSPpGQNJdHlK8b04fFHZUc1ColRRGcbe+
	6OKXOYtagEcvWjqRtkbi98cHiuN2+aZsboUrn41mihu12YVceXxpl4XtOANQpUP7lfZpyxGQhT5
	texufTs0eeELPKjPD+66HWaIIq74tzDMSzUDf0bYFvecY7SNdIc3rY7blkzSAulRVcF+foZxwaa
	u
X-Received: by 2002:a17:902:7608:: with SMTP id k8mr21453342pll.245.1550440447501;
        Sun, 17 Feb 2019 13:54:07 -0800 (PST)
X-Received: by 2002:a17:902:7608:: with SMTP id k8mr21453287pll.245.1550440446486;
        Sun, 17 Feb 2019 13:54:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550440446; cv=none;
        d=google.com; s=arc-20160816;
        b=B0uefocxvtd8cb7MjRYsExRLNAesbDVBBsT0Fe4Crb5UXQ05dYPSVAwoGJ/mQ1QW3V
         l9XJzXOez5G1OkIue4KTbvBJrzDhQMczuzn7lUhAzVLbtHTs1wVdvt0Z9M0ihOhmK+rK
         jwM/yFEhx3n+nPyPRq+LNp+CY8DebweCIFvDx9eUF5jCnnLNx1SoS07yKavmK3ObRBx6
         IJQO/4t5lp8KdJ3PKtalSH1yO4fAsiVTguWuzeR/2V/VqCyffhbF/nLJ1XTZDErt1mMM
         lQgFZ07xJkpLQBu17HEzH/ZjJ7c/SS7HVPv67SsldirGlYwYpjNL10d1PmbU2jzDZSLx
         q91g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=hW6qubX20Gip4JuCPw9oiQx7hX8cH1JQ7TKmCE4msZo=;
        b=slspizC7eN3kQQEl3IV/9ininVqPDNAr/JGSEn0UhEqmPQrJUMUNvSEkA8LCYKLAac
         tmdqDb2GLljMpE1QNrPL6KHRC48yR8AdrUMFsc4CeBJ9OJ6bYDXUCH3ETf/bFIE2okqW
         R0jZpIeKumNw+ONzo7+0lFkAHOvmaxfvo2zfbZ+YBppBX/sb7pDS5GnQoFlLdLpeE8wf
         05ldu/zL/S0u1+QDQNDcydPl/YecRB0Zuf8zq68V/hYqfkDvSQV9NpNqFntWkEj9/aeE
         9pUOZ29SXlqDk70kITAxAI2KpUzyw7Pf8Vf2oPVOtu9AXLgpSCy465MLIYZIOpBmp2HX
         5aUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="D/nfPrYe";
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 1sor18782977pfy.19.2019.02.17.13.54.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Feb 2019 13:54:06 -0800 (PST)
Received-SPF: pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="D/nfPrYe";
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=hW6qubX20Gip4JuCPw9oiQx7hX8cH1JQ7TKmCE4msZo=;
        b=D/nfPrYeTZKEN5WDI6JSvs0O5r2yUucnnn1hx+RWvXKtfJyzNydti7mMt1ZtP1htvy
         5Mvu/OPRa4pjzetHuwxx9rI22VVDeMW9InIaViqAHIbRwaHci2UYQLKg+FqTRHQ9DE+R
         8AewzcuNGQ6avRpeIAuEKjHpPKEms0t7XqDJLF0HVI9m+/9KzMCeVqdFvwENPly/xLnS
         vZk6USEEv/f8g98ppyJda3WuaOj6eVRh5PuKIEtb++hi7P/XJO39gZf9Ogf7Ki9vSDBS
         xSZu1Q+sGASRgCPuCVj88kntgJ0CUIdWkSTzT/tEmB/wJGIKayY4ihv3xvEsMlpV3J2S
         LCuw==
X-Google-Smtp-Source: AHgI3IbTj0OPZK6xw2609G3xTCnaF0nBVw6zIVkDn5dgiAAdBvMSXoHmdy9PjVqVJVKrz8tdsh9RiA==
X-Received: by 2002:a62:8a57:: with SMTP id y84mr20816497pfd.197.1550440445603;
        Sun, 17 Feb 2019 13:54:05 -0800 (PST)
Received: from localhost ([203.219.252.113])
        by smtp.gmail.com with ESMTPSA id l184sm12344561pfc.41.2019.02.17.13.54.04
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Feb 2019 13:54:04 -0800 (PST)
Date: Mon, 18 Feb 2019 08:54:01 +1100
From: Balbir Singh <bsingharora@gmail.com>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Matthew Wilcox <willy@infradead.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Subject: Re: [LSF/MM TOPIC] Address space isolation inside the kernel
Message-ID: <20190217215401.GG31125@350D>
References: <20190207072421.GA9120@rapoport-lnx>
 <20190216121950.GB31125@350D>
 <1550334616.3131.10.camel@HansenPartnership.com>
 <20190217193434.GQ12668@bombadil.infradead.org>
 <1550434146.2809.28.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1550434146.2809.28.camel@HansenPartnership.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 17, 2019 at 12:09:06PM -0800, James Bottomley wrote:
> On Sun, 2019-02-17 at 11:34 -0800, Matthew Wilcox wrote:
> > On Sat, Feb 16, 2019 at 08:30:16AM -0800, James Bottomley wrote:
> > > On Sat, 2019-02-16 at 23:19 +1100, Balbir Singh wrote:
> > > > For namespaces, does allocating the right memory protection key
> > > > work? At some point we'll need to recycle the keys
> > > 
> > > I don't think anyone mentioned memory keys and namespaces ... I
> > > take it you're thinking of SEV/MKTME?
> > 
> > I thought he meant Protection Keys
> > https://en.wikipedia.org/wiki/Memory_protection#Protection_keys
> 
> Really?  I wasn't really considering that mainly because in parisc we
> use them to implement no execute, so they'd have to be repurposed.
>

Yes, but x86 and powerpc have the capability to use them for no-read,
no-write and no-execute (powerpc). I agree that this might not work
well across all architectures, but it might be an option for architectures
that support it.
 
> > > The idea being to shield one container's execution from another
> > > using memory encryption?  We've speculated it's possible but the
> > > actual mechanism we were looking at is tagging pages to namespaces
> > > (essentially using the mount namspace and tags on the
> > > page cache) so the kernel would refuse to map a page into the wrong
> > > namespace.  This approach doesn't seem to be as promising as the
> > > separated address space one because the security properties are
> > > harder
> > > to measure.
> > 
> > What do you mean by "tags on the pages cache"?  Is that different
> > from the radix tree tags (now renamed to XArray marks), which are
> > search keys.
> 
> Tagging the page cache to namespaces means having a set of mount
> namespaces per page in the page cache and not allowing placing the page
> into a VMA unless the owning task's nsproxy is one of the tagged mount
> namespaces.  The idea was to introduce kernel supported fencing between
> containers, particularly if they were handling sensitive data, so that
> if a container used an exploit to map another container's page, the
> mapping would fail.  However, since sensitive data should be on an
> encrypted filesystem, it looks like SEV/MKTME coupled with file based
> encryption might provide a better mechanism.
> 
> James

Balbir Singh

