Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 18D2BC43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 22:01:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2C41217F9
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 22:01:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dnz4qIz/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2C41217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61EFB8E0003; Sun, 17 Feb 2019 17:01:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A5018E0001; Sun, 17 Feb 2019 17:01:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4478D8E0003; Sun, 17 Feb 2019 17:01:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id EF9A88E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 17:01:54 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 11so7260222pgd.19
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 14:01:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=0V94wftf7qYYjGwslfQBCAle9jbzinWXN8ZI6JiDtmQ=;
        b=CpsB4iCnrfe5wdnTiCuQ85wT+IXWGqYk3ikt40HjN4DjuHUtjDqLQSOxcKVNCyQlzM
         LFvo/9mUZjFOr8JMP2pSeULVFlu6Ag+FnC+dIoZqb3yBAmM39rJ2faBWE6ev/RA8q137
         wZfnhEnjnXsi/+6KUUUziz8lZRYF9wR8R9JCDD0S2lheRk0g44O95Cd64B4mFZXlBCJZ
         Fw4jRSF8Wov+zK6fP8CzilptanmN33WnvnhvSDWVV/Dy/C+JPUY1A34ATOIhgH9h6p1j
         AAshw9mq/8a9RjtmvEOK9keaZVF24bO5lIMVvSJwMor1yw/cSziO15Kkp60QAHzXevgt
         2jSQ==
X-Gm-Message-State: AHQUAuZpU7RzynTWKBg6XWD3T5mkIr8/sBYDEDq7wIhjm9L1y5OWPaCR
	b+rcyNC7XHpRiidxLsGfVsINza8zyVNezcd3leK1z+Rk0kr50nv6uL3jf+wGiOBIRVGEVrqpggu
	JiH2j45HaHF0nS9ZBM7Dz24lhEB5e9CEQi3UKrqukP2HX8h57VkHbVRnVyjSxo/Jrnl9FbwZj4O
	yh+PwrsGML7VYm7nLfSMugHgTnGS8rThy9q2shlmgsAvipqmQFgJiaTrpbD/no5ZhlbezWn3ANM
	uEz7J0NISwbkOJeMJ+fJMZcbW2fZVLsIleUateYJQ3TWwy6h/5mfHOJ6stubc2zmRT5sE7uaRlo
	wIrdqmrknSxeCifsmXUujEQqUebSQfeLcyiNSc2TR+FeR4dzvuLpYMOlxryoU947qKQMxGmAtKQ
	k
X-Received: by 2002:a17:902:a40d:: with SMTP id p13mr12173314plq.144.1550440914583;
        Sun, 17 Feb 2019 14:01:54 -0800 (PST)
X-Received: by 2002:a17:902:a40d:: with SMTP id p13mr12173268plq.144.1550440913983;
        Sun, 17 Feb 2019 14:01:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550440913; cv=none;
        d=google.com; s=arc-20160816;
        b=sSX9AlkEbiyQUYlEnMrcIGpydtxvRVF4n3cqi4uM/5O8J35IM4QcdjW9bIuKufUjaL
         7meerf0Dk1IrqyK9OYT14L4PMwbSoYkjVg5Dju5WOltkYpHj2USyaScU1cDBjnwyWzC8
         B3GJxlFiyib25UkY8jS4oBQapInnTNJVlCBMDb7/LlgFOzXn9FfRY131BDXNtIj7TJWH
         wT/jH22MvlaUFmuo7O5Xtgg87n6tAmS0DYQ/wUhyREyCzrjSudN2jHGAP42jJ8ChnC91
         tEoMOcYPOVob4t+slti9z/dQ0Z3jiaE0rM0p2Deah0pTaUWxS6IGwzZA8LyFSVidUaPW
         rd+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=0V94wftf7qYYjGwslfQBCAle9jbzinWXN8ZI6JiDtmQ=;
        b=0lAHs/rMOliRpR8aaFUXoiVcFa3/OxuR3YqzxAUcL9LEdXjAW9Y9dvt15rYt71YliJ
         S4vBVu/apLud0xbzNuc/DLRiI7E1IQFXY0lY6kuo7kV7Vr5TYgU/5RMCLRqnp+UwaDir
         kZF0/scYYeT7OTY2uTmUOXuomWfgmR3p8KcgKl5BhW8h2+a4zoCHIR0OiS9bHT+M3S1/
         BxCT5eV/VYOurVzSa0E9AAYzDMN/BzgJ7lVYxo/0HHmw5iVUsiTY68z1DDxLeTwo9mLj
         UlHlzYRQXIR/6uqKq0QyVvn6c/rQwVTToe55yL6QY1n/MrVAhrFoYcFBZm+/stRQLg1B
         wfCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="dnz4qIz/";
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y66sor17213215pgy.45.2019.02.17.14.01.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 17 Feb 2019 14:01:53 -0800 (PST)
Received-SPF: pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="dnz4qIz/";
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=0V94wftf7qYYjGwslfQBCAle9jbzinWXN8ZI6JiDtmQ=;
        b=dnz4qIz//oYMT6PFsYAwVosPJQ8DBUZFNQ1O4wlSvrqUYu/kcZ5x43fvV4SZW8SjPn
         CGNnYiHeuLppQFSWt7RI94eZSzNkwLzS7mCUYZT/cQrT7NmezOxMY+sYQRVAQLsKD9gq
         mA8vXMVB7s1Y8/XGcubDTtuWFXkbDTmo91idcKZlBjT4zJJIi4yyq4DNORRUu5VxVm3P
         9j+g6rwK+1yNIHU7rf2hZGyTnPO46oZhRTgPasyKryzBl4rDg2CVodF9rWJ7hUMGS3NI
         waxqenzqm5QcEDdXlywph4H9ZLUd9pT//6jkomO0X/PjbD+KGzhkwVK/TJqGAYxVmtnP
         uHHg==
X-Google-Smtp-Source: AHgI3IZAFCHDIOZDN/BDA+fT7xYi65ieDd1MnUSrNh5wv7caN69V6wAtINFqNxNuu0y0owl9ryoMzQ==
X-Received: by 2002:a65:6654:: with SMTP id z20mr7264026pgv.390.1550440913450;
        Sun, 17 Feb 2019 14:01:53 -0800 (PST)
Received: from localhost ([203.219.252.113])
        by smtp.gmail.com with ESMTPSA id y9sm16911390pfi.74.2019.02.17.14.01.52
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Feb 2019 14:01:52 -0800 (PST)
Date: Mon, 18 Feb 2019 09:01:50 +1100
From: Balbir Singh <bsingharora@gmail.com>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Matthew Wilcox <willy@infradead.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Subject: Re: [LSF/MM TOPIC] Address space isolation inside the kernel
Message-ID: <20190217220150.GI31125@350D>
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

Splitting out this point to a different email, I think being able to
tag page cache is quite interesting and in the long run might help
us to get things like mincore() right across shared boundaries.

But any fencing will come in the way of sharing and density of containers.
I still don't see how a container can map page cache it does not have
right permissions to/for? In an ideal world any writable pages (sensitive)
should ideally go to the writable bits of the union mount filesystem which is
private to the container (but I could be making up things without
trying them out)

Balbir Singh.

