Return-Path: <SRS0=1HZa=QY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0AFA7C43381
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 20:09:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B58D82184A
	for <linux-mm@archiver.kernel.org>; Sun, 17 Feb 2019 20:09:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=hansenpartnership.com header.i=@hansenpartnership.com header.b="AU36qeZj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B58D82184A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=HansenPartnership.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4EB608E0002; Sun, 17 Feb 2019 15:09:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4730A8E0001; Sun, 17 Feb 2019 15:09:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 33A028E0002; Sun, 17 Feb 2019 15:09:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0A7E18E0001
	for <linux-mm@kvack.org>; Sun, 17 Feb 2019 15:09:12 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id 4so10103258ybx.9
        for <linux-mm@kvack.org>; Sun, 17 Feb 2019 12:09:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=V/MJi+PoKTGZJ1hLUTvRHctGqUBxfMUMTc0GPRvrp6c=;
        b=QQezWthMPA1fho+P7MSPDpvKT4QMxrDSLWk3n7uqI9tje1W3COxcaFgcXiafDSsw6y
         AVPxH8qyUPsx6KlDTZgfVdU232vzzloEYR1nqp+NdFFYhdkHxarbSz3z9R0aquhDUymJ
         8JaDXhAWArbHqDbKiIn9muYMU2rSyrmCdubce+VbiiADVlmGDVH03iQ9vfv7Tg4vS2S8
         8E+fmfXPoP9hr0lim/MYU2VowCrZfExqE/fpx6wRRjM1SkTlX31OzRAaHORSZ+3BKIZR
         Yo8EvomgVlRN8RHGk9DhhxRennnkqO0CECQcFmGhI5RhAs5jn7NOlK/oVLwonq9uV128
         7G6w==
X-Gm-Message-State: AHQUAuY+tqoSBVdzCrA6HCKXZjnOCNiZtkGFjF5D01ALhLEacUGklKYx
	u3Ad+XMR9ud6EcDZYSxxCRvcykfPKfcJhhZeTb0Sl4SbsIWjust2n46BXnhVVABGHR2E3W7nfxl
	WI2ih8ITJ7fCx9yh2z5q4Cn/QKAldujSuIhf7egXkBdqvX+J8EYIlCEi8WGpo/F3Dcw==
X-Received: by 2002:a81:5489:: with SMTP id i131mr16301738ywb.459.1550434151705;
        Sun, 17 Feb 2019 12:09:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IatZog2Lr6KlNRCbDD752HM7iRZM0/TvQilfFSdwu+tTFkmHl05mSOCILxmUrDr+9JOEhQu
X-Received: by 2002:a81:5489:: with SMTP id i131mr16301707ywb.459.1550434150988;
        Sun, 17 Feb 2019 12:09:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550434150; cv=none;
        d=google.com; s=arc-20160816;
        b=b8ghGe6Iv0Cu+BclxThu3NtMKy+AlU4QJSG/B/da5j0vdIl1bmvyt+2dYf5k7wVeqD
         nisSqI6ZOWdLmNVjmfLwDQpIN7TnesVzOgZhlPtIjpbHmlmJBTGME807F2KgY8GGFpUm
         t4m/D3ayBH2oInjvcHlV1F5UQ/tR1jaByeOHpqaGWFwpyjm7Uo8uBc1N+/7KK/+8Ecsv
         piqL7oWMasHLc68kdGLZO6CGqZMNHwkoYdShx361K0nkKwTISEgoQZ2TvVylCAseTco1
         4kPU3yBIaLtSdi7+Lo7p2EYgXpiEtbeah8kVxJW6TFdTgkBskJlUK2eTo1nj32gJ984C
         jkRw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=V/MJi+PoKTGZJ1hLUTvRHctGqUBxfMUMTc0GPRvrp6c=;
        b=alHcVOXlb8HgO6md6r+l29Q7iVGztcv1aH/DWDVmH030peoyDTO/K9jO82uwk2juXQ
         Z4N4mU0eohl9IP/G46jaGeX6/tnfOHg4/GPLZwdy2xpuR6OMJYXUt+I/FYIYejM/+V87
         Ldlohaq3+EQeBq/9bFprSkapLjT5DZ7Jus623dX0QoCpQSfEHY3WGfmCraY65n8qu/Jv
         QjAgx8TOsugDYDvaB6wE9c0VRO6fEBUHMHefhFxwC/NquJksG/rDlnoS9cX2bj/E2lvC
         dNXOzmP9/vWOB0UZh5O2WWncJ7ONxrZMYKBMwBsnOFhUshJuH7b97BVesmNtWbdgB6QZ
         Oobg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=AU36qeZj;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id r1si5981566ybb.431.2019.02.17.12.09.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 17 Feb 2019 12:09:10 -0800 (PST)
Received-SPF: pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) client-ip=66.63.167.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@hansenpartnership.com header.s=20151216 header.b=AU36qeZj;
       spf=pass (google.com: domain of james.bottomley@hansenpartnership.com designates 66.63.167.143 as permitted sender) smtp.mailfrom=James.Bottomley@hansenpartnership.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=hansenpartnership.com
Received: from localhost (localhost [127.0.0.1])
	by bedivere.hansenpartnership.com (Postfix) with ESMTP id 71FD88EE229;
	Sun, 17 Feb 2019 12:09:09 -0800 (PST)
Received: from bedivere.hansenpartnership.com ([127.0.0.1])
	by localhost (bedivere.hansenpartnership.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id KpySKP74NbDF; Sun, 17 Feb 2019 12:09:08 -0800 (PST)
Received: from [153.66.254.194] (unknown [50.35.68.20])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by bedivere.hansenpartnership.com (Postfix) with ESMTPSA id D102B8EE03B;
	Sun, 17 Feb 2019 12:09:07 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=hansenpartnership.com;
	s=20151216; t=1550434148;
	bh=O2uIap3QolEypaKj4a5iRFWycD3UxTmQg8u1D9csLis=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=AU36qeZjhi91pL7gNFxBgKTAUUc3GcPr7MsZy94NG6HXZd+XJfFOLi7eoQVAoS4dF
	 eSM26s+16vxkp/vq1EzkxQMvxVhDdFyovDRgRv+xQafCcypBf20HsrpzSOvxpE7i/m
	 xdosOReOE+hbeVxwCTRVeZh/mYmfRZBwAIyj7i1c=
Message-ID: <1550434146.2809.28.camel@HansenPartnership.com>
Subject: Re: [LSF/MM TOPIC] Address space isolation inside the kernel
From: James Bottomley <James.Bottomley@HansenPartnership.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Balbir Singh <bsingharora@gmail.com>, Mike Rapoport
 <rppt@linux.ibm.com>,  lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org
Date: Sun, 17 Feb 2019 12:09:06 -0800
In-Reply-To: <20190217193434.GQ12668@bombadil.infradead.org>
References: <20190207072421.GA9120@rapoport-lnx>
	 <20190216121950.GB31125@350D>
	 <1550334616.3131.10.camel@HansenPartnership.com>
	 <20190217193434.GQ12668@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.6 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 2019-02-17 at 11:34 -0800, Matthew Wilcox wrote:
> On Sat, Feb 16, 2019 at 08:30:16AM -0800, James Bottomley wrote:
> > On Sat, 2019-02-16 at 23:19 +1100, Balbir Singh wrote:
> > > For namespaces, does allocating the right memory protection key
> > > work? At some point we'll need to recycle the keys
> > 
> > I don't think anyone mentioned memory keys and namespaces ... I
> > take it you're thinking of SEV/MKTME?
> 
> I thought he meant Protection Keys
> https://en.wikipedia.org/wiki/Memory_protection#Protection_keys

Really?  I wasn't really considering that mainly because in parisc we
use them to implement no execute, so they'd have to be repurposed.

> > The idea being to shield one container's execution from another
> > using memory encryption?  We've speculated it's possible but the
> > actual mechanism we were looking at is tagging pages to namespaces
> > (essentially using the mount namspace and tags on the
> > page cache) so the kernel would refuse to map a page into the wrong
> > namespace.  This approach doesn't seem to be as promising as the
> > separated address space one because the security properties are
> > harder
> > to measure.
> 
> What do you mean by "tags on the pages cache"?  Is that different
> from the radix tree tags (now renamed to XArray marks), which are
> search keys.

Tagging the page cache to namespaces means having a set of mount
namespaces per page in the page cache and not allowing placing the page
into a VMA unless the owning task's nsproxy is one of the tagged mount
namespaces.  The idea was to introduce kernel supported fencing between
containers, particularly if they were handling sensitive data, so that
if a container used an exploit to map another container's page, the
mapping would fail.  However, since sensitive data should be on an
encrypted filesystem, it looks like SEV/MKTME coupled with file based
encryption might provide a better mechanism.

James

