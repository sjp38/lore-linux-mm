Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4844DC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 11:16:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBA3E217F4
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 11:16:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="orhSARZb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBA3E217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8D53F8E0005; Mon, 18 Feb 2019 06:16:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85E018E0002; Mon, 18 Feb 2019 06:16:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FF5E8E0005; Mon, 18 Feb 2019 06:16:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2884F8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 06:16:01 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id y12so11350869pll.15
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 03:16:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=sQSYVZJHr+0svrMyD14QL42mvsWlI7jZbfgnjeBduY4=;
        b=SxRKC8MLqNTa42MP20YE5c61EtD91FMzYc+h5ckjQd/NpvTTXhiskWUzK7p4roSExc
         yFdTh07i+cIu6yqoRPsIP03mDHYc3mb4MMOLP87QjFqOC2pFV8+WJ5qa/5LOLZMSnfS9
         z25bVPhA/TJtLm8FNR9/A29nJTvpuIeYcDv3vo5t6MHqTvq+btMlwGmDm6b0/Mc7EJBp
         k5mYF5h6BeKzjUVAg4ZlYa+5LrgX0OaZbyQyXxq15PQ81zlcByQiH6q2u26ZULZvakM1
         KcZmUJ7w9Shka/esgNMMcxWpm1sDBVmtwcHASDlBhDUcc1VesBfILE07DmF2CujdP1LI
         PImg==
X-Gm-Message-State: AHQUAua3Oo/73LHR3AkKcQPunG/LDaic8dh+NOg1WAZqaCC6oN8lFVom
	M9zNiNLCL8nfzc+SEe3FuyhEX4br1arNsCY5e5WVguhsLOFDipDzLLbYPKoyn8f/2SRpUGPKWzd
	5ov/SpGPQAx4BAFRSK+HzFT0pzkmMeSS5o+mh8wrOi7Bo4p/r+KwbBrFkOvSA10n4bYTRkNubBH
	Kvh0nE3duiAth9MnBkSdGSFlkcFXYTSu0KbS0OmPPBDW60PQ1Q2ysE2MCaZfSx8iSpYl8s99JBp
	v5u3sEoAfrvou8wbNNds8np/n+Q2Q7pZicF5gujyKkZ6QwBPjJfvFqNLmlT/Q9Ah6hZPAuooHbb
	UEHhmEQBJo/Yjv+1lSqK1f3Zr5VIhpT6u9ImQTWXHD47P88ed0Ld05YwdrYZ3cWlnTlZtTTvDgG
	L
X-Received: by 2002:a62:ca48:: with SMTP id n69mr23616178pfg.162.1550488560811;
        Mon, 18 Feb 2019 03:16:00 -0800 (PST)
X-Received: by 2002:a62:ca48:: with SMTP id n69mr23616123pfg.162.1550488559957;
        Mon, 18 Feb 2019 03:15:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550488559; cv=none;
        d=google.com; s=arc-20160816;
        b=KmJOBcCpaQP+XXkLHky8l620a04YqwkAHWAy1yLoHsiK9TCFMGp7D7/M+8bU55k9sA
         5Y6vPkJg7lUGqjazlUbXumBrmCBBgPCM2GaY4SfZSRrQmDeB+u6sgpR7vvK75ppkD25M
         IB65nmULyLw1Kkv27pnRn3TzyvCrV6+2bQxnAZAQIwVGEBSrMIU545tw9KW3yuIXhAot
         5A1T12VmCdObZD0Td5bibtRocYLMIH300zqdnkSTMrBi50tmE2ZESnDAfLsXM0NgWLve
         ooZkF7ex4U1Iq0NQncxb2+oCWpTwSIbuDOTXT1JgMqw0x+OzRF/Vifz2CnwdnXVq48dN
         f5tA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=sQSYVZJHr+0svrMyD14QL42mvsWlI7jZbfgnjeBduY4=;
        b=IlmPggeHi8KPKFArjHI+KoGliDDP5VL6Xa0AS+tXf05Uem4M8b4kgP9eKGvYl+0TqO
         shhjR60XuCeAFeKXz0cZ2Dltx+ScEhYQ8+cvM2kGRAWqcProep59jbO1VS1Yd7hasDhw
         fvwDPA7zKqphvLbqCYkrXjIKmHPkxSkCHN1cr0snV8zdwfl/hAKjrSHJAcIGqYc2yDxK
         +FRDT5rU07+DahujyfzCX/QwGuN0bDoXjv1O+2hibjti27qfh0+vI3gABuSzXT1ymFNr
         JIr8OJA5JO4fr5NlAnsANe0m55ssizk3S8b+G3zGdKGZBF01ZxvdKAoNuVfme2VPmHYY
         HC/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=orhSARZb;
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n3sor17384253pgp.41.2019.02.18.03.15.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Feb 2019 03:15:59 -0800 (PST)
Received-SPF: pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=orhSARZb;
       spf=pass (google.com: domain of bsingharora@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=bsingharora@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=sQSYVZJHr+0svrMyD14QL42mvsWlI7jZbfgnjeBduY4=;
        b=orhSARZbKbZ8O3Ba6GKDUnmYL0riZt5lfmr7ByoWhyFfmAOHpouMNWLd/lTqOBz1u1
         QKpB4yXcSAUan6PTXaEnOPtqM08WifAkpqhNhvpwOgeSkRR33Yu16+Kq730S7vad5J0v
         4itfKYcnIdVoC7WmpJeT0iPVRsk4bTXIv9okqs9TMQcMlIVqxu/1nmlCSZxE02dkG+Kl
         MF1H7tmEgZq3PJIfRPmpZ2s6XfwpHM5CqPV6rlPuuBjMAw5wDbKnrjTp/fD0FaVsoBZk
         6li0TEQ+x/5ya20NEWE+pbEjDJe6m55nPBbz98W56KIgn8vvWpzdbY2SYUuuOaOS+8gK
         ss7A==
X-Google-Smtp-Source: AHgI3IbKxgJ5D9ysrFz53657L1pd0a1DZYmF70xjPd31Cx/JBS37VfdP6RP2V00D+U8RDxmNojuF0g==
X-Received: by 2002:a65:6553:: with SMTP id a19mr18547917pgw.267.1550488558872;
        Mon, 18 Feb 2019 03:15:58 -0800 (PST)
Received: from localhost ([203.219.252.113])
        by smtp.gmail.com with ESMTPSA id d129sm31019917pgc.59.2019.02.18.03.15.57
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 03:15:57 -0800 (PST)
Date: Mon, 18 Feb 2019 22:15:55 +1100
From: Balbir Singh <bsingharora@gmail.com>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org,
	Matthew Wilcox <willy@infradead.org>,
	Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Address space isolation inside the kernel
Message-ID: <20190218111555.GJ31125@350D>
References: <20190207072421.GA9120@rapoport-lnx>
 <20190216121950.GB31125@350D>
 <1550334616.3131.10.camel@HansenPartnership.com>
 <20190217193434.GQ12668@bombadil.infradead.org>
 <1550434146.2809.28.camel@HansenPartnership.com>
 <20190217220150.GI31125@350D>
 <1550442050.2809.36.camel@HansenPartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1550442050.2809.36.camel@HansenPartnership.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Feb 17, 2019 at 02:20:50PM -0800, James Bottomley wrote:
> On Mon, 2019-02-18 at 09:01 +1100, Balbir Singh wrote:
> > On Sun, Feb 17, 2019 at 12:09:06PM -0800, James Bottomley wrote:
> > > On Sun, 2019-02-17 at 11:34 -0800, Matthew Wilcox wrote:
> > > > On Sat, Feb 16, 2019 at 08:30:16AM -0800, James Bottomley wrote:
> > > > > On Sat, 2019-02-16 at 23:19 +1100, Balbir Singh wrote:
> > > > > > For namespaces, does allocating the right memory protection
> > > > > > key work? At some point we'll need to recycle the keys
> > > > > 
> > > > > I don't think anyone mentioned memory keys and namespaces ... I
> > > > > take it you're thinking of SEV/MKTME?
> > > > 
> > > > I thought he meant Protection Keys
> > > > https://en.wikipedia.org/wiki/Memory_protection#Protection_keys
> > > 
> > > Really?  I wasn't really considering that mainly because in parisc
> > > we use them to implement no execute, so they'd have to be
> > > repurposed.
> > > 
> > > > > The idea being to shield one container's execution from another
> > > > > using memory encryption?  We've speculated it's possible but
> > > > > the actual mechanism we were looking at is tagging pages to
> > > > > namespaces (essentially using the mount namspace and tags on
> > > > > the page cache) so the kernel would refuse to map a page into
> > > > > the wrong namespace.  This approach doesn't seem to be as
> > > > > promising as the separated address space one because the
> > > > > security properties are harder to measure.
> > > > 
> > > > What do you mean by "tags on the pages cache"?  Is that different
> > > > from the radix tree tags (now renamed to XArray marks), which are
> > > > search keys.
> > > 
> > > Tagging the page cache to namespaces means having a set of mount
> > > namespaces per page in the page cache and not allowing placing the
> > > page into a VMA unless the owning task's nsproxy is one of the
> > > tagged mount namespaces.  The idea was to introduce kernel
> > > supported fencing between containers, particularly if they were
> > > handling sensitive data, so that if a container used an exploit to
> > > map another container's page, the mapping would fail.  However,
> > > since sensitive data should be on an encrypted filesystem, it looks
> > > like SEV/MKTME coupled with file based encryption might provide a
> > > better mechanism.
> > > 
> > 
> > Splitting out this point to a different email, I think being able to
> > tag page cache is quite interesting and in the long run might help
> > us to get things like mincore() right across shared boundaries.
> > 
> > But any fencing will come in the way of sharing and density of
> > containers. I still don't see how a container can map page cache it
> > does not have right permissions to/for? In an ideal world any
> > writable pages (sensitive) should ideally go to the writable bits of
> > the union mount filesystem which is private to the container (but I
> > could be making up things without trying them out)
> 
> As I said before, it's about reducing the horizontal attack profile
> (HAP).  If the kernel were perfectly free from bugs and exploits,
> containment would be perfect and the HAP would be zero.  In the real
> world, where the kernel is trusted (it's your kernel) but potentially
> vulnerable (it's not free from possibly exploitable defects), the HAP
> is non-zero and the question becomes how do you prevent one tenant from
> exploiting a defect to interfere with or exfiltrate data from another
> tenant.
> 
> The idea behind page tagging is that modern techniqes (like ROP
> attacks) use existing code sequences within the kernel to perform the
> exploit so if all code sequences that map pages contain tag guards, the
> defences against one container accessing another pages remain in place
> even in the face of exploits.
>

Agreed, and I believe in defense in depth. I'd love to participate to
see what the final proposal looks like and what elements are used

Balbir Singh. 

