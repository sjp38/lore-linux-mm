Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C22C9C31E44
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 07:05:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78A1C218DA
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 07:05:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (4096-bit key) header.d=d-silva.org header.i=@d-silva.org header.b="NGiJvBHc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78A1C218DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=d-silva.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 209E48E0003; Mon, 17 Jun 2019 03:05:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B9FE8E0001; Mon, 17 Jun 2019 03:05:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 082278E0003; Mon, 17 Jun 2019 03:05:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id E0F458E0001
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 03:05:51 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id b188so11321339ywb.10
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 00:05:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=tjfoX775x3v0r8mbMtOrq7sChSIbnGuw8O+jlpf/kdg=;
        b=Wdo7fH7glGGsKP2Rt4NWO68S6HtDrPSwEFZvvnlDI0aAbn7dbwu9i8I3mmQRCnWtbB
         8202gu/So0bGPMryJls0AamGYFiWOr/0IvZiJm0ZO4FlwI3BtXetiBfKmQur9EhjtDtZ
         OgbSdc7X818YtOQYKEKc5aU8GtMBoh5IspgnNgxwq0wxMTbTCVzfF/XnpynZ6aKrF2Cd
         PbImaQXPn0lksYnJ+i9IEJ8gZhuJr/L7VE1WC5tL5zYefiscYTsGY9RAkHO+TboordoF
         z4hlvojxNF47NUcPv770VVMCZB+3tFn/zlVoDKbKW63hf6qK4EGjTosyJggx5J6yLhpq
         lzNQ==
X-Gm-Message-State: APjAAAVsmNehBFmT9PAgNL6tZkwSO0HREbbiTimTteoXYp1u0EsvNRK+
	zr4KK1+mLqTkZn8ZKYGHP7Um7RHl/CP3Wuy/zThNJkzjYEmmMC/QJQi//h8L2MkK/1/LxxsFA+T
	eqWc4uXrU1FL5K9AgAfkapL4rqFkn+ZTEO/zY+ayuRoacJgmYEiQ1aNaq1lLC2rTspQ==
X-Received: by 2002:a0d:e84b:: with SMTP id r72mr18347157ywe.22.1560755151618;
        Mon, 17 Jun 2019 00:05:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxshSWlXdcO+cJ23sfXAKbKTt92uVWIag6Ar+8cUEe61fDFHJndxogM2qBcn/tFkpX0RBk/
X-Received: by 2002:a0d:e84b:: with SMTP id r72mr18347141ywe.22.1560755151123;
        Mon, 17 Jun 2019 00:05:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560755151; cv=none;
        d=google.com; s=arc-20160816;
        b=xzUpzQmwZxqmfVw3o5hPB+bewaIUxNRqopjyspVDK27KFUF1UPjdMD0mKI129euiXy
         iuViGAcC6RAnaHZuBE5nx63cr4VI3XQP/FSLDY4ZYH4Iorg08GuJu7aXEksMpdGen+MR
         AvOSfvcCIKRFonHLyvyHuH32Nrg8MCpN1AuUcvSCZofaOfj7ezZiBZ23pQf8INgLQxNC
         zQECGHFb4RNzf5BDTiZa7uJ1j+rw+ozZZYOoEyw34RKRXGNfut6ZnA1FyF8WMtkyZzxr
         MlCGpDv1rrHUa3KivYgZpdXUEeT4cmjMDdwwBmvm1Qc7lCkYlRf14PirrK8l53IeMHKK
         48TQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id:dkim-signature;
        bh=tjfoX775x3v0r8mbMtOrq7sChSIbnGuw8O+jlpf/kdg=;
        b=gppgLvAm0+f7GDh9YbOH8NR++HUe3c1v87WB4o+A2ZoDK70w0J0tWpSrzdIAovv+kJ
         G7JpDpPH1crogzZ71GhBhqY0QCJggxZM9cCut2/k+z+/v4ljssobcuojZJT7fjez0+jZ
         TuxS/gd472So16qFdDNz2LRLzuH+yGkddia+nF6qcsfzIZ+juS+NBfN1rvVHLEcaXFSl
         uatO9LRLEgsngFZdxpzpVP0pz5DUHy5cQlrT+SkpyZhfP3PtiYiJhKCe6VQvOCQ3KWr4
         d1lqCHLv5J6HDiE3eB5GjLJD45AXKPwSvhbQycB07Vt99t6PVZzbvOvt0vZsg2dj1eJp
         ABKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@d-silva.org header.s=201810a header.b=NGiJvBHc;
       spf=pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) smtp.mailfrom=alastair@d-silva.org
Received: from ushosting.nmnhosting.com (ushosting.nmnhosting.com. [66.55.73.32])
        by mx.google.com with ESMTP id f3si1731004ybh.294.2019.06.17.00.05.50
        for <linux-mm@kvack.org>;
        Mon, 17 Jun 2019 00:05:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) client-ip=66.55.73.32;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@d-silva.org header.s=201810a header.b=NGiJvBHc;
       spf=pass (google.com: domain of alastair@d-silva.org designates 66.55.73.32 as permitted sender) smtp.mailfrom=alastair@d-silva.org
Received: from mail2.nmnhosting.com (unknown [202.169.106.97])
	by ushosting.nmnhosting.com (Postfix) with ESMTPS id 31E9E2DC00DD;
	Mon, 17 Jun 2019 03:05:50 -0400 (EDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=d-silva.org;
	s=201810a; t=1560755150;
	bh=TotXHfC7mkapkJQ2eQkYpljIPSR0AGxVy5++z04zxGQ=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=NGiJvBHcjG+CIJgh2IA052h5ANspPN8jd6fbOzhRCeYoBkvDtYW+xqsOtyM2owh+k
	 4I9pLIhjyYJt5cgWRd28JYXp0bTSacf9BS/6eJz79G4zkKDIgkw9/n0k8lHtFL3LYp
	 v6tzGJy8rz0AsiUeHmLRARxW04mbdQIaGytijoRJI+CsPgvLrNSlEWtF8+pQvi/FLC
	 q0pXW1PJbIhDE4w+Es0IRXymmb6XQY8I2CCHKSA0okkQJOroNpGsWvNPvzkkluzmSe
	 nI7bFZ3e2yV6m+5WsqT9A3jJepIOzW9z8JppoC0qktOWqNlBfmgSlBIWhb/PoN81MJ
	 JKgebF9nGgSxXHZsWCTsEeDnYxPk/FCZlReafmBAy4zMLzfAKV/09mSMxtjxVl3hbi
	 Iv4+6f6qw0YG+ODfXXtHDaPBQyac3wi6mHDBVabHjDUGlUpxQ/9oBxTIGVnSXjkcOr
	 TMZ2EN5AYJY6QToHs1sZLafhiOVj3hh66/5+qwuTIpzwKMGQgiJ5lWeiZBLgrWz4P5
	 EKcMctBcYaUoVyx6Fo4znLsXbgY2xD8wLUao2qjobGSSPvVBSrmKc0p6YuWv5cNS9X
	 JmmB1UF1DlY3K1Sj4QirQKVF2VopERlT4pcRhBeBhtPSbH2KloRI6VOS0aoo0bLBWT
	 qX8Q1bXR5rLneh8uTOVhd0rI=
Received: from adsilva.ozlabs.ibm.com (static-82-10.transact.net.au [122.99.82.10] (may be forged))
	(authenticated bits=0)
	by mail2.nmnhosting.com (8.15.2/8.15.2) with ESMTPSA id x5H75Utj056973
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NO);
	Mon, 17 Jun 2019 17:05:46 +1000 (AEST)
	(envelope-from alastair@d-silva.org)
Message-ID: <f1bad6f784efdd26508b858db46f0192a349c7a1.camel@d-silva.org>
Subject: Re: [PATCH 5/5] mm/hotplug: export try_online_node
From: "Alastair D'Silva" <alastair@d-silva.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        David Hildenbrand
 <david@redhat.com>,
        Oscar Salvador <osalvador@suse.com>, Michal Hocko
 <mhocko@suse.com>,
        Pavel Tatashin <pasha.tatashin@soleen.com>,
        Wei Yang
 <richard.weiyang@gmail.com>, Arun KS <arunks@codeaurora.org>,
        Qian Cai
 <cai@lca.pw>, Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar
 <mingo@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>,
        Jiri Kosina
 <jkosina@suse.cz>, Mukesh Ojha <mojha@codeaurora.org>,
        Mike Rapoport
 <rppt@linux.vnet.ibm.com>, Baoquan He <bhe@redhat.com>,
        Logan Gunthorpe
 <logang@deltatee.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Date: Mon, 17 Jun 2019 17:05:30 +1000
In-Reply-To: <20190617065921.GV3436@hirez.programming.kicks-ass.net>
References: <20190617043635.13201-1-alastair@au1.ibm.com>
	 <20190617043635.13201-6-alastair@au1.ibm.com>
	 <20190617065921.GV3436@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.2 (3.32.2-1.fc30) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (mail2.nmnhosting.com [10.0.1.20]); Mon, 17 Jun 2019 17:05:46 +1000 (AEST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2019-06-17 at 08:59 +0200, Peter Zijlstra wrote:
> On Mon, Jun 17, 2019 at 02:36:31PM +1000, Alastair D'Silva wrote:
> > From: Alastair D'Silva <alastair@d-silva.org>
> > 
> > If an external driver module supplies physical memory and needs to
> > expose
> 
> Why would you ever want to allow a module to do such a thing?
> 

I'm working on a driver for Storage Class Memory, connected via an
OpenCAPI link.

The memory is only usable once the card says it's OK to access it.

-- 
Alastair D'Silva           mob: 0423 762 819
skype: alastair_dsilva    
Twitter: @EvilDeece
blog: http://alastair.d-silva.org


