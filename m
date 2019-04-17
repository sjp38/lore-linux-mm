Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4DB7C10F12
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 03:52:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DF0020835
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 03:52:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DF0020835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C7CA6B027F; Tue, 16 Apr 2019 23:52:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1767F6B0280; Tue, 16 Apr 2019 23:52:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 065EC6B0281; Tue, 16 Apr 2019 23:52:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C2BAB6B027F
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 23:52:15 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id j184so13862812pgd.7
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 20:52:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=S+t9eOXeFbqGYs+RIQWWpMVXSDHY79M24t6nvEH5ceI=;
        b=TWm7SiHRXF1mEFRCcgMqVIrEezjUn7tkVmj05+Jc2ZQ0fq+1+0mMG4+tBLfMGkIOdO
         HtsmGVIKeie3DM7JW2JkR/xc3X3C4bJgPs1eb/dh8iyev2UkfNjdhcVKsIGvuG9j6m8J
         uCZxNS/pTKzfKP3Z2ZIUrtP2qfV0lcVa2BncIeUQmJg/3rK5eApJsZzwvl0tKbSGQZzM
         92im8RtahPV6u6c7CYLnJ5UHtROp/bynx2tMRj/kYQ/lkaJBIrtxCJwr/92BQy6a3NCj
         JplDo08gEJ5xRH/nypThETsAEmItrQ1XeGEacCM3v48bmmtA6SstcMeOWrGtdBTbsP4a
         qWvg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAXqfnw+nRLg2RgYtVBYBIHv6cQ1/9teiGRj8QHWjOnou7vB2arP
	32oU7Tz9dLZSo4m5zRbzGpOs7NoUezn8YLmJAnv0urgAHsdpF5hLg0TgGOpfFKIu8fj+mg/MnZv
	KbV9I1EJp8PM3XgXV21AADDyeUnqD9FGkjc4s/XCCAj4dbl9vHlE8zmjCFdUTE3IrqQ==
X-Received: by 2002:a17:902:141:: with SMTP id 59mr50478522plb.132.1555473135469;
        Tue, 16 Apr 2019 20:52:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWAjxODGdDn5ceYj3kMBbSJ9koJtazcWtafnMk1FO8KqUlirP2j2ZHdt4N81whyldJ5nod
X-Received: by 2002:a17:902:141:: with SMTP id 59mr50478469plb.132.1555473134727;
        Tue, 16 Apr 2019 20:52:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555473134; cv=none;
        d=google.com; s=arc-20160816;
        b=PIfeSPwChwcwocqKSwIKg6GKaA0H+EkIJToBEOH4BuqxkfBWX+pT1blrKLPDGpNbPl
         tebeYxpoEuTj3kht4baO++nJ+Cy51FN6+CfigZQ/Q2RF+xl+B5yuJaZKnCEl5WTBf33a
         U3F//4Ru/Qoahlh06SG/JSDS2m7KcSjX71paOGTZrkT4JN/aC/PiX50gXZIwT6De/zCK
         iMXXQ409wler3AjsibG3Oy/wFt9TqHP6sPwGjlF8VpPIzxGAU0HGNb6GvptBmk4ka+pu
         kKiDQhig0eC+yaq1UwFHWNTkd79/eaFd56Fz7MqvDOWJSC5qsOjQj7hvCnGpIgJIxWdc
         Tgwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=S+t9eOXeFbqGYs+RIQWWpMVXSDHY79M24t6nvEH5ceI=;
        b=v/mbxuqxm0+aH72PmHyZulSgckTHTLg1pTBaxoVl3fzNfEks3oEIF00M6RcmL0DnGC
         IJSAbQelIRSLmFw8j64jxgprdHSHgxp9VkBj3QvWsaH5hOo/k49nzB5rEoOi3OTa22ud
         kU4CyRyHrTh4XE5TG0x570x5eYJR67E4S7dR87uuXsIAoIw6x7gxbn8l4yJ+89ysIjyI
         cS5iBEHdF/PxzNClYk5GkpOlohgSpPfu6HUtR3PLQgitwC+bMwNUbsgBb3k4gYSXgbZI
         fZriuWZHfKdrhLHWGmK71mFlh97hTiC9wsuM7mSBYoYhwTuSl9WEa3Pj38WFXlBYAR3d
         vYbw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g11si45730890pgo.563.2019.04.16.20.52.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 20:52:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 93DCADA6;
	Wed, 17 Apr 2019 03:52:13 +0000 (UTC)
Date: Tue, 16 Apr 2019 20:52:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>,
 "Tobin C. Harding" <tobin@kernel.org>, Christoph Lameter <cl@linux.com>,
 Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Tejun Heo <tj@kernel.org>, Qian Cai <cai@lca.pw>, Linus Torvalds
 <torvalds@linux-foundation.org>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org, Jesper Dangaard
 Brouer <brouer@redhat.com>, David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/1] mm: Remove the SLAB allocator
Message-Id: <20190416205212.5cb286fbeec801f50269b2b5@linux-foundation.org>
In-Reply-To: <20190412112816.GD18914@techsingularity.net>
References: <20190410024714.26607-1-tobin@kernel.org>
	<f06aaeae-28c0-9ea4-d795-418ec3362d17@suse.cz>
	<alpine.DEB.2.21.1904101452340.100430@chino.kir.corp.google.com>
	<20190412112816.GD18914@techsingularity.net>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Apr 2019 12:28:16 +0100 Mel Gorman <mgorman@techsingularity.net> wrote:

> On Wed, Apr 10, 2019 at 02:53:34PM -0700, David Rientjes wrote:
> > > FWIW, our enterprise kernel use it (latest is 4.12 based), and openSUSE
> > > kernels as well (with openSUSE Tumbleweed that includes latest
> > > kernel.org stables). AFAIK we don't enable SLAB_DEBUG even in general
> > > debug kernel flavours as it's just too slow.
> > > 
> > > IIRC last time Mel evaluated switching to SLUB, it wasn't a clear
> > > winner, but I'll just CC him for details :)
> > > 
> > 
> > We also use CONFIG_SLAB and disable CONFIG_SLAB_DEBUG for the same reason.
> 
> Would it be possible to re-evaluate using mainline kernel 5.0?

I have vague memories that slab outperforms slub for some networking
loads.  Could the net folks please comment?

