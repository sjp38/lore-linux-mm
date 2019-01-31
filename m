Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E448C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 09:51:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D00A4218AC
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 09:51:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D00A4218AC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codewreck.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 669588E0002; Thu, 31 Jan 2019 04:51:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 618BF8E0001; Thu, 31 Jan 2019 04:51:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 556FF8E0002; Thu, 31 Jan 2019 04:51:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE1468E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 04:51:39 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id z10so523841lfe.21
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 01:51:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=nfV7OIObBXz32fdW+x2GE9V6v0HxaBHPSEgwCSNk0WM=;
        b=t+XVEiyqy9y1HmBRSqDy4QrytPHnccHBrgFGtVnuZ9hQ3jXfR8NLi3MIcXxsDPiZ9Y
         RZxuZzTHzwXNOOwM317dYcNn0BUtLXB8dmYSfU1WpQW+PBU+7Kr0JXksWIYNQMM2s71I
         Y+7a8UsEpuJLzLdZCrC2Z5oFsvylCQwyZY0AA/pfR0TXB68gor106+0JPb7VL3KLflye
         2mrp0/6o477HleRY7lMWUPQONRbrl4rIjn4i7pHbctTU/fdeAjkhTUcRPz5TAfNWkWhG
         WIYWs0XNEpiQC2/lFd8ZHGW8FzGo+HYfjPdtAOZkUTFkvgThVzRf3lFAdmxbtmGAq8CT
         jfYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of asmadeus@notk.org designates 2001:41d0:1:7a93::1 as permitted sender) smtp.mailfrom=asmadeus@notk.org
X-Gm-Message-State: AJcUukczNtCSypeK65VBlrjOjcXHccZBNNuKVFXJQxgh+hsuhnYGs7Uj
	2Mn2UP8ul+vpoO4s+SiUC3yZ/raJcja9NfL8qg9eiyJWVdt0QlRJ3nNAtzf5ar4pq0wVXQtmRR8
	qD1KnxMv271wxkzh6CJqqvG7ej2BUHA300gx4pB7urxOWIbM1k7CSjzZvoNlsGHM=
X-Received: by 2002:a2e:9944:: with SMTP id r4-v6mr27441945ljj.185.1548928299099;
        Thu, 31 Jan 2019 01:51:39 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5LMWQ7F0bSFm4E9eMj8QKfQaohbB+M4fR4ZoMLiPBG5cjnyhB45+zaCI2z/6RVixy5IRpj
X-Received: by 2002:a2e:9944:: with SMTP id r4-v6mr27441898ljj.185.1548928297937;
        Thu, 31 Jan 2019 01:51:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548928297; cv=none;
        d=google.com; s=arc-20160816;
        b=RGqlVFqFX55psziGNn93T/IPU0oWlBuwuu9D+Nk6EJbUb8PU3uG/5et3GHUwAV9W2/
         P/SddSak9C8k+FAqSmbWEvgRlc40lFI/76oKr51IbhGXV11L61I6bePKhYmajM1tGoi3
         hCroJPdJV6fYB3619hopgWc0Jjw+jQFww4vzxq/LiLFT8xNNoaDwoGafh1gNU83U/ceE
         DLLtHr6iAXYPWzbuijgcuQumzMBE7kDwf14og5Y3ZXkSaIVT6CxwwO4S7AUNlUNZ454V
         yXK3ELSNrN0MQ8QsIsf0wTaxvc8l0+ahO4KyDuNf5RZHQJ7pjfGWRH2As7lrHWY0mo6U
         mciA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=nfV7OIObBXz32fdW+x2GE9V6v0HxaBHPSEgwCSNk0WM=;
        b=BVtKduwbiJFozhVIywC+c7LnoV5eND0rIgOFYDOF9HHDtLDxkrx4UYgtgsd1f38MVt
         7XCUHAvGqfiPpBWkvLbFAQIEZsUFC78/RrBvQAqX9AN/j6i4bUNX/jy8ZbXGvsujgaU6
         iumd4WsNBcXx0aVpbynXbEI/7Dm3nXvy8WBYQ/jH1pdyPVbVPwWH2voC4WlDqfmLTpvR
         RQ+oK/vB6DIDBSXlW7VYIc2U3Nv27GJH8GDV2T0S9Bv+EaT5lmLlm3pBR3IjEOviLEmA
         9DTrVkd/ayUUscao2AN3INmcZ+B1gi9Rn6ZTOyaV2wjFeyDfxRXKSVIvzPLWNLgagL6i
         r5YQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of asmadeus@notk.org designates 2001:41d0:1:7a93::1 as permitted sender) smtp.mailfrom=asmadeus@notk.org
Received: from nautica.notk.org (ipv6.notk.org. [2001:41d0:1:7a93::1])
        by mx.google.com with ESMTPS id q27-v6si3449015ljc.196.2019.01.31.01.51.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 01:51:37 -0800 (PST)
Received-SPF: pass (google.com: domain of asmadeus@notk.org designates 2001:41d0:1:7a93::1 as permitted sender) client-ip=2001:41d0:1:7a93::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of asmadeus@notk.org designates 2001:41d0:1:7a93::1 as permitted sender) smtp.mailfrom=asmadeus@notk.org
Received: by nautica.notk.org (Postfix, from userid 1001)
	id DAA5DC009; Thu, 31 Jan 2019 10:51:36 +0100 (CET)
Date: Thu, 31 Jan 2019 10:51:21 +0100
From: Dominique Martinet <asmadeus@codewreck.org>
To: Michal Hocko <mhocko@kernel.org>, Josh Snyder <joshs@netflix.com>
Cc: Vlastimil Babka <vbabka@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
	Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Andy Lutomirski <luto@amacapital.net>,
	Dave Chinner <david@fromorbit.com>,
	Kevin Easton <kevin@guarana.org>,
	Matthew Wilcox <willy@infradead.org>,
	Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Daniel Gruss <daniel@gruss.cc>, Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH 1/3] mm/mincore: make mincore() more conservative
Message-ID: <20190131095121.GA26131@nautica>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
 <20190130124420.1834-1-vbabka@suse.cz>
 <20190130124420.1834-2-vbabka@suse.cz>
 <20190131094357.GQ18811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190131094357.GQ18811@dhcp22.suse.cz>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Michal Hocko wrote on Thu, Jan 31, 2019:
> > Change the semantics of mincore() so that it only reveals pagecache information
> > for non-anonymous mappings that belog to files that the calling process could
> > (if it tried to) successfully open for writing.
> 
> I agree that this is a better way than the original 574823bfab82
> ("Change mincore() to count "mapped" pages rather than "cached" pages").
> One thing is still not clear to me though. Is the new owner/writeable
> check OK for the Netflix-like usecases? I mean does happycache have
> appropriate access to the cache data? I have tried to re-read the
> original thread but couldn't find any confirmation.

It's enough for my use cases and Josh didn't seem to oppose, but since
he's not in Cc I don't think he would answer -- added him now :)

FWIW happycache writes in the current directory by default so I assume
in the way they use it it would usually have access one way or another.

> If this still doesn't help happycache kind of workloads then we should
> add a capability check IMO but this looks like a decent foundation to
> me.

the inode_owner_or_capable/inode_permission helpers already do allow
quite a few capabilities there


-- 
Dominique

