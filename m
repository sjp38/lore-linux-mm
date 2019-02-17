Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1CB8C43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 22:20:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AA1C72146E
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 22:20:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="OnB+lfyt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AA1C72146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 489098E0003; Sun, 17 Feb 2019 17:20:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4380D8E0001; Sun, 17 Feb 2019 17:20:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 300DF8E0003; Sun, 17 Feb 2019 17:20:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 043768E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 17:20:55 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id p198so5528398yba.6
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 14:20:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=3ykwAIpgUTAfEmrlfVQyUdAqMjNuaotPHS1Kcda2iQQ=;
        b=HOyPUAttV/YAbhbyvmSyKc8feFU0XiSOZZ3/LbYGjjJt7lLhhL1g8op1uuU/YX6E7S
         Edp18I/hTfyqMASXR2XjxUMajnI7Sq3l02bXPC6lMrRmjGjL0hpeWgUKhqVuNPGlPq1m
         EbRu4/xo5DbtgTwzHZr29GHtps8CU+igGntopvfSi9dzBXtgsQyMCYIVbECAZnJbw7j8
         Ne5DbIQwlcbyZGG4fP+za55UWD+7gPTr9UX0VyNizEGUR8ye673X9r6ijav+aaLW6667
         TKrKG7uxJt4pXaos5Z8mzGM4dbm5TpMwFiB3aPmQQa9FlSurXOSmpLMC5wKmt2WrC18m
         lODw==
X-Gm-Message-State: AHQUAuYcwfb+LlOhchSOLtORMiY5BojeN27gVvK3XnIJxmUAOqMSyRFZ
	rZq6+uqH2IT3XLz/IrscXgCyhS+1fYAYnOdUrk3nYMRM8sbd3dfPiOpTmjshjFrTqYV9lDOXpjC
	riKB5i9nD9CAfPqRiV+5J62etCkcHR77p0cNkOAJlUsyzetd+gp8pe9fCfXROuTl23w==
X-Received: by 2002:a25:ed06:: with SMTP id k6mr16936076ybh.43.1550442054532;
        Sun, 17 Feb 2019 14:20:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZvKd+8lSzPVzN2LrZjf3Q8SShZdW1BoUjtJM/8akHkIHDinqRCnRNNxmYOMLBXy80dZ2RE
X-Received: by 2002:a25:ed06:: with SMTP id k6mr16936049ybh.43.1550442053850;
        Sun, 17 Feb 2019 14:20:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550442053; cv=none;
        d=google.com; s=arc-20160816;
        b=yR2YBpHXXthjAheDm+McPBODlTT8uSdymADdJ6Z0/ZsqHo7PtNjcunHuldwi0b2/yu
         YgBTGTQx4HQ1gRelKBcEiutT4FcQBSPbh6W+PqgUeRSd3OU0jDJhThs2JoVd8PFttBZY
         +SGJR/UsOj+pIOHFNFVV4sd6McPc578M2RAyWkk3n1BUI7VbyqIYeC1mlX9jRaHZLWH4
         e1yhPrZLcXlwYUGIlM+757pNXaJrtvbEiq63tRAS+mPRGe9mbHBM41uANxO+I/YoTSW7
         M+wp0hrEMQQ/p8TERqplqa3dLO2ecGgPGnGRf3+Ix6SfpXEn//8QtpLP9x+DEpwF4Px1
         59xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=3ykwAIpgUTAfEmrlfVQyUdAqMjNuaotPHS1Kcda2iQQ=;
        b=vO/gVMfXxjoffzjpWeaXjsLLtHAfEoscwk+sWeLYoWBSnrQY+bukftz+qV1pOuxV+B
         BksFyOQPJFSyb0zgvVRd9mwiDeAf4Xb/kQnvNaSaUsQBHRJlMnIK2FxhhIWM7Xb5DntF
         0uZo72ZzMjT3N44IPFjKVksUO8kin+PQvhXk/keHPFF5lc0GeVbciB06iGr3itsIRlXW
         K1/bIyzB/mo9uFTaGg3yEPd1lCQnWXEwcZhPuryXoAvkiEg6fGfz5ka6+ypTzfAvRkg4
         AHicYY2lUdmAWkbXGqd+Dte2aqnm7zpFGGQbu9NXNIamFi+hcZWozffT8a2FO8ch4t2z
         C0mg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=OnB+lfyt;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id a205si6800263ywa.155.2019.02.17.14.20.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Feb 2019 14:20:53 -0800 (PST)
Received-SPF: pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) client-ip=66.63.167.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=OnB+lfyt;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id 3DFF38EE229;
	Sun, 17 Feb 2019 14:20:52 -0800 (PST)
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id WqA7UXrtDXv9; Sun, 17 Feb 2019 14:20:52 -0800 (PST)
Received: from [153.66.254.194] (unknown [50.35.68.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id 8D9E08EE03B;
	Sun, 17 Feb 2019 14:20:51 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1550442051;
	bh=kE54KaubUyvpRwvJHTzMYv7IAx6POuhzbL13gFliihY=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=OnB+lfytBogStplvUxDYjP0ohQJn2mjUMPUr26iwhjqyCJtvK7VhchALBA3VK6xwo
	 Y/SYHfqCt2wmQv70MWt/BFqIctugzmdI8GTwLdFAZokD0izMfhTYXiwDIk7ValL2aE
	 6Kb1oBPJEME2ZwT/pB9FS7E2I7rRJKTmgeeiKvu0=
Message-ID: <1550442050.2809.36.camel@HansenPartnership.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Address space isolation inside the
 kernel
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, Matthew Wilcox
	 <willy@infradead.org>, Mike Rapoport <rppt@linux.ibm.com>
Date: Sun, 17 Feb 2019 14:20:50 -0800
In-Reply-To: <20190217220150.GI31125@350D>
References: <20190207072421.GA9120@rapoport-lnx>
	 <20190216121950.GB31125@350D>
	 <1550334616.3131.10.camel@HansenPartnership.com>
	 <20190217193434.GQ12668@bombadil.infradead.org>
	 <1550434146.2809.28.camel@HansenPartnership.com>
	 <20190217220150.GI31125@350D>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-02-18 at 09:01 +1100, Balbir Singh wrote:
> On Sun, Feb 17, 2019 at 12:09:06PM -0800, James Bottomley wrote:
> > On Sun, 2019-02-17 at 11:34 -0800, Matthew Wilcox wrote:
> > > On Sat, Feb 16, 2019 at 08:30:16AM -0800, James Bottomley wrote:
> > > > On Sat, 2019-02-16 at 23:19 +1100, Balbir Singh wrote:
> > > > > For namespaces, does allocating the right memory protection
> > > > > key work? At some point we'll need to recycle the keys
> > > > 
> > > > I don't think anyone mentioned memory keys and namespaces ... I
> > > > take it you're thinking of SEV/MKTME?
> > > 
> > > I thought he meant Protection Keys
> > > https://en.wikipedia.org/wiki/Memory_protection#Protection_keys
> > 
> > Really?  I wasn't really considering that mainly because in parisc
> > we use them to implement no execute, so they'd have to be
> > repurposed.
> > 
> > > > The idea being to shield one container's execution from another
> > > > using memory encryption?  We've speculated it's possible but
> > > > the actual mechanism we were looking at is tagging pages to
> > > > namespaces (essentially using the mount namspace and tags on
> > > > the page cache) so the kernel would refuse to map a page into
> > > > the wrong namespace.  This approach doesn't seem to be as
> > > > promising as the separated address space one because the
> > > > security properties are harder to measure.
> > > 
> > > What do you mean by "tags on the pages cache"?  Is that different
> > > from the radix tree tags (now renamed to XArray marks), which are
> > > search keys.
> > 
> > Tagging the page cache to namespaces means having a set of mount
> > namespaces per page in the page cache and not allowing placing the
> > page into a VMA unless the owning task's nsproxy is one of the
> > tagged mount namespaces.  The idea was to introduce kernel
> > supported fencing between containers, particularly if they were
> > handling sensitive data, so that if a container used an exploit to
> > map another container's page, the mapping would fail.  However,
> > since sensitive data should be on an encrypted filesystem, it looks
> > like SEV/MKTME coupled with file based encryption might provide a
> > better mechanism.
> > 
> 
> Splitting out this point to a different email, I think being able to
> tag page cache is quite interesting and in the long run might help
> us to get things like mincore() right across shared boundaries.
> 
> But any fencing will come in the way of sharing and density of
> containers. I still don't see how a container can map page cache it
> does not have right permissions to/for? In an ideal world any
> writable pages (sensitive) should ideally go to the writable bits of
> the union mount filesystem which is private to the container (but I
> could be making up things without trying them out)

As I said before, it's about reducing the horizontal attack profile
(HAP).  If the kernel were perfectly free from bugs and exploits,
containment would be perfect and the HAP would be zero.  In the real
world, where the kernel is trusted (it's your kernel) but potentially
vulnerable (it's not free from possibly exploitable defects), the HAP
is non-zero and the question becomes how do you prevent one tenant from
exploiting a defect to interfere with or exfiltrate data from another
tenant.

The idea behind page tagging is that modern techniqes (like ROP
attacks) use existing code sequences within the kernel to perform the
exploit so if all code sequences that map pages contain tag guards, the
defences against one container accessing another pages remain in place
even in the face of exploits.

James

