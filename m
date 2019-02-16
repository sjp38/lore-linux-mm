Return-Path: <SRS0=AfK9=QX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 275BEC43381
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 16:30:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AEE87222E0
	for <linux-mm@archiver.kernel.org>; Sat, 16 Feb 2019 16:30:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="thzY8sio"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEE87222E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24DEE8E0002; Sat, 16 Feb 2019 11:30:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D5F78E0001; Sat, 16 Feb 2019 11:30:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 079678E0002; Sat, 16 Feb 2019 11:30:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id C47578E0001
	for <linux-mm@kvack.org>; Sat, 16 Feb 2019 11:30:21 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id y133so8079127ywa.21
        for <linux-mm@kvack.org>; Sat, 16 Feb 2019 08:30:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=qiu9UwarxhuqZeqbiWLLsyXAVGkcv98/iMm6DLxLbgw=;
        b=VqdVV76H6il54zGq/K+Wvml+i7N10kb5pwO2EWI0XIIuSWFli9O5NtTGGvZEdKO7sa
         VEcI+uxRSO8VAQF0xtD61OASoMyRadSVEvgL9cRPcj4nrjioWiqpJh0pDGOKNcB8VHGZ
         jagn/Ey9HqYv7/jVYnkEoq4ViqEXk5DgNsucl2yBlq04pe8TNzsAb3vkKnJZS3ZI2mZw
         On9iZJZeFyGvnSrIXBoENXx4mw7iuDUZt0dWPkxMXwoAvkmdzhTWOP+Wa5L+yhlcGPTh
         s+lNn1s7VfS27YlnwYQDxMoZkld0k33htuvJFTg+qQXvMXBq24alOEBWpxXSr5N44FB0
         gjeg==
X-Gm-Message-State: AHQUAua3hZsCUYFMK0jkM5c7Yn6pesbIvn7ICXE1rEPtpJBkssyw5mPL
	yES/ih8NF5feaDrh1u2H+kYoM2//0yJzx9DNY9Yby+0zDlt/r12iWaXxu3tLieRSKyRxE5biq7J
	sIZGQCSXK3aoyaXGs4P30ohU9wKxihzMKp9kZnZ5fcq4G1KweaAb0f141f9l+vepfKQ==
X-Received: by 2002:a81:4bc9:: with SMTP id y192mr12613618ywa.359.1550334621425;
        Sat, 16 Feb 2019 08:30:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbAgiQNuufwIX5nuPO+pASOJlDstcVK5eGHXVsBRQ6xhmTKw9k9ynPu0j15Wp0tdABTCock
X-Received: by 2002:a81:4bc9:: with SMTP id y192mr12613572ywa.359.1550334620646;
        Sat, 16 Feb 2019 08:30:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550334620; cv=none;
        d=google.com; s=arc-20160816;
        b=NLUAWo9w/IMxbPXpEK10K+Qau/pQGDrHScH8gCvCKtyBEmn665UqVTONoY0613yIL6
         8xmX50LXTEiDPo+JB4cxRGJspTXJKPwwZ0L/8mGC4NqC6iBhnBJFq0NICGeNhicjffzY
         EqjYpLrr2j6uq9OAAl7bK8/8T5WN5/EQGeDlnt6oiuJqVlfKmUGCIzyfgGxnOtzr1JBD
         MyehKTjsdHAUl9ATNiGHgncK3fnlpqqEZ59A9iZbgRyRB4KtVzmPIvgz4XVhs9/8bU25
         nP3OGAqhxR/nba74Pf0ug315pOGPiFbVZJjrlpgpSXuzTgdyy1ghGt8sK+MEVutYCX3/
         KDdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=qiu9UwarxhuqZeqbiWLLsyXAVGkcv98/iMm6DLxLbgw=;
        b=uF4jjLo4/R9291xFpnEOtz1dLvuQSFy99PhZVnqeHsgxh8feGhPrbHi/VgtgilgLGB
         AowrjaKoU9b/EMiCAH7jWi/c1GKJrKd4SHd36fqrfqjRkbcF2w49vY6UutMapaDV1bt3
         7vWhNrb/61Vhj34qunThfT2mDJxO7+vbc0EvHA9adsMfVlSa132L89bc7qLKk0rkc5uo
         PmIKS3mZRI7Z9s7j6nlkTj8eCXlVLUH32Im6hFbRGP8vOHyW95oQNdyEGv7QthIbF+J8
         OvUoSylXfQYkOSZb4eDyKIbEzv9cTZYWQEFlREbbfRRgtN+tvOa6dBzRBMiu/nf97h2w
         aMWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=thzY8sio;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id 129si4880387ybl.206.2019.02.16.08.30.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Feb 2019 08:30:20 -0800 (PST)
Received-SPF: pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) client-ip=66.63.167.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=thzY8sio;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id 0AF3D8EE2CD;
	Sat, 16 Feb 2019 08:30:19 -0800 (PST)
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id huS1SnUvTZ3V; Sat, 16 Feb 2019 08:30:17 -0800 (PST)
Received: from [153.66.254.194] (unknown [50.35.68.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id 770498EE101;
	Sat, 16 Feb 2019 08:30:17 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1550334617;
	bh=vAVNRCinn+mQ/3iICrX92xuD+yFA9cSJ1ODacin7UD0=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=thzY8sioRttNxhYpGtOavYqsKy9LrVJUId/7n/UXnzn3eQwPZoT64Amgl0ZYOCinD
	 ndwh9lCffxuKMoNahmVQcLyPVNG/K7Q8EBk6y6BavBSKS3K+6+4hbu8lpzEpNniwmb
	 Je51xqjI0lNp5om1taAE0b/5GsOhWM0GqhsN/GO4=
Message-ID: <1550334616.3131.10.camel@HansenPartnership.com>
Subject: Re: [LSF/MM TOPIC] Address space isolation inside the kernel
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Balbir Singh <bsingharora@gmail.com>, Mike Rapoport <rppt@linux.ibm.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Date: Sat, 16 Feb 2019 08:30:16 -0800
In-Reply-To: <20190216121950.GB31125@350D>
References: <20190207072421.GA9120@rapoport-lnx>
	 <20190216121950.GB31125@350D>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2019-02-16 at 23:19 +1100, Balbir Singh wrote:
> On Thu, Feb 07, 2019 at 09:24:22AM +0200, Mike Rapoport wrote:
> > (Joint proposal with James Bottomley)
> > 
> > Address space isolation has been used to protect the kernel from
> > the userspace and userspace programs from each other since the
> > invention of the virtual memory.
> > 
> > Assuming that kernel bugs and therefore vulnerabilities are
> > inevitable it might be worth isolating parts of the kernel to
> > minimize damage that these vulnerabilities can cause.
> > 
> 
> Is Address Space limited to user space and kernel space, where does
> the hypervisor fit into the picture?

It doesn't really.  The work is driven by the Nabla HAP measure

https://blog.hansenpartnership.com/measuring-the-horizontal-attack-profile-of-nabla-containers/

Although the results are spectacular (building a container that's
measurably more secure than a hypervisor based system), they come at
the price of emulating a lot of the kernel and thus damaging the
precise resource control advantage containers have.  The idea then is
to render parts of the kernel syscall interface safe enough that they
have a security profile equivalent to the emulated one and can thus be
called directly instead of being emulated, hoping to restore most of
the container resource management properties.

In theory, I suppose it would buy you protection from things like the
kata containers host breach:

https://nabla-containers.github.io/2018/11/28/fs/


> > There is already ongoing work in a similar direction, like XPFO [1]
> > and temporary mappings proposed for the kernel text poking [2].
> > 
> > We have several vague ideas how we can take this even further and
> > make different parts of kernel run in different address spaces:
> > * Remove most of the kernel mappings from the syscall entry and add
> > a
> >   trampoline when the syscall processing needs to call the "core
> >   kernel".
> > * Make the parts of the kernel that execute in a namespace use
> > their
> >   own mappings for the namespace private data
> 
> Is the key reason for removing mappings -- to remove the processor
> from speculating data/text from those mappings? SMAP/SMEP provides
> a level of isolation from access and execution

Not really, it's to reduce the exploitability of the code path and
limit the exposure of data which can be compromised when you're
exploited.

> For namespaces, does allocating the right memory protection key
> work? At some point we'll need to recycle the keys

I don't think anyone mentioned memory keys and namespaces ... I take it
you're thinking of SEV/MKTME?  The idea being to shield one container's
execution from another using memory encryption?  We've speculated it's
possible but the actual mechanism we were looking at is tagging pages
to namespaces (essentially using the mount namspace and tags on the
page cache) so the kernel would refuse to map a page into the wrong
namespace.  This approach doesn't seem to be as promising as the
separated address space one because the security properties are harder
to measure.

James


> It'll be an interesting discussion and I'd love to attend if invited
> 
> Balbir Singh.
> 

