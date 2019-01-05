Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C4BCC43612
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 19:24:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3990221915
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 19:24:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3990221915
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF74D8E0125; Sat,  5 Jan 2019 14:24:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C7C938E00F9; Sat,  5 Jan 2019 14:24:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1C7B8E0125; Sat,  5 Jan 2019 14:24:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 510388E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 14:24:06 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id d41so35857005eda.12
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 11:24:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=jJ+jGacXZo4Ybr8s5P1KbEwvFpRSHBMbVRnJ1VTbiqQ=;
        b=WrQpDGPfRpa4O0Kvn4dFnvkOIU88H6oeIxb6JPOQeBdg2DojLyQjFn9lRfqIHMs2SD
         6eEbMSSK0eLTPlkkLbf05WAQaH1T/pwZfCK7Ssh8pbVwmqpZ+/bZIRp7rPU6cFDhLXy+
         XNnjjA7kmOmTe1uRuL7o3CuctQXZJ8zc2d9jdrBC56KgJJ/Uw8NfOy3hb8gyDXLUvQae
         6DswavJOxrarpkQNxUFonNYgQjTJEM7sf/SpQ4sUW5gUp74KtVIjrZQdb/7NulSe87Uq
         FudqjCw1wwGiutjH4NrCW99OpDbGr07U52oQPFxiiVt87ej7Nl5QS8epVAJ9GVmXbiVA
         TCPg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukel5q/CAOpEQrjGFFeNCC+ibnjcVUS7Pn1Hs0fP43pyk6o9Il6q
	orMAhpf8ArZ3LZ9gu1Km3cZDwDzy2euAMZLVMk3t4HgJHk9pIrfmzYPXyNwpGEXC9ei+qBZp4J7
	GcOhQMACcWyv5/Ci/PZ81dOEe87SGLKQ/F2VD3y2Zs9fb7ACJk3aS6I2MYb7dFGM=
X-Received: by 2002:a17:906:48c2:: with SMTP id d2-v6mr6301889ejt.244.1546716245841;
        Sat, 05 Jan 2019 11:24:05 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5GhGUVNGw/wEc3ZDFyFGiFHwYRBFEJBZ6etUlHx1hlis5QFgidyXn+FN+itHhIJDGGwmpL
X-Received: by 2002:a17:906:48c2:: with SMTP id d2-v6mr6301861ejt.244.1546716245043;
        Sat, 05 Jan 2019 11:24:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546716245; cv=none;
        d=google.com; s=arc-20160816;
        b=sez8E8SzhMX+lvtzzqpunFKFUIF87BeDS2bI3HdvOjpIj3WiGTHKru8IS5/TfqlJaI
         8Q1eW9AkzOSQbeZ05ewDUF4XvT/yurw2Lu+L9pXAVy3EGM21WdzKs0gn+qye38JtmVqi
         55VWdwqZeVJbQtIDXuHVnhAa2wQN6CVY6atbAZ/d6NZXg2MYUy51LkbhNuTrvVGo8DY1
         nbsr6w0BF++Yt42pg2emHefxux3BtTKrk0Y1z5MxAOMoev8+F1KPYjABt+uyNHeQJAg/
         mUz2z2su7HbgtiELQMdNWF8KKLHLM6G3dwRk6+RRYN6pNhfUERSN7+fBDTOftIKgL3YW
         ByHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=jJ+jGacXZo4Ybr8s5P1KbEwvFpRSHBMbVRnJ1VTbiqQ=;
        b=ZeTykzWp7boTMW3fC98CXxWvbnaIM0NyEnNNc359WoadVZr6V8RLS/3aPLkLGcUf5Q
         BUh4bqY6zIAVLjEL/BzOa/zbbnC120bjb1eYmYqv57Z0Ck9yyM7z7dyp9KyWGUM6tuTA
         kiRIqBEMijniknYkq7mn9wfpzs+VmNITyIB1C/Gy0B4IspLBICY6k7/ajhx4kwU7xWLw
         o4eJDumWLxgOhgLUoXMNDuoA7+RU7KfdxhK7/ftJkF/T99XATUT/JVAI26w1O1+wWv6j
         MN7+GtFbKG8vfq9mD284KgpsL//l5ZSbAM3pTeZLaYm7cedDfYmI6a2xZuAniFqqHM21
         DrRA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s17si408754edr.396.2019.01.05.11.24.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 11:24:04 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0A0CAACE8;
	Sat,  5 Jan 2019 19:24:04 +0000 (UTC)
Date: Sat, 5 Jan 2019 20:24:03 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Vlastimil Babka <vbabka@suse.cz>
cc: Linus Torvalds <torvalds@linux-foundation.org>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Greg KH <gregkh@linuxfoundation.org>, 
    Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org, 
    linux-api@vger.kernel.org
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <d4846cb2-2a4b-b8b3-daac-e5f51751bbf1@suse.cz>
Message-ID: <nycvar.YFH.7.76.1901052016250.16954@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <d4846cb2-2a4b-b8b3-daac-e5f51751bbf1@suse.cz>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190105192403.brE6ZWJBBySymIwzqj95ScKtXbcTPj7x1fLOIUP9Q_A@z>

On Sat, 5 Jan 2019, Vlastimil Babka wrote:

> > There are possibilities [1] how mincore() could be used as a converyor of 
> > a sidechannel information about pagecache metadata.
> > 
> > Provide vm.mincore_privileged sysctl, which makes it possible to mincore() 
> > start returning -EPERM in case it's invoked by a process lacking 
> > CAP_SYS_ADMIN.
> 
> Haven't checked the details yet, but wouldn't it be safe if anonymous private
> mincore() kept working, and restrictions were applied only to page cache?

I was considering that, but then I decided not to do so, as that'd make 
the interface even more confusing and semantics non-obvious in the 
'privileged' case.

> > The default behavior stays "mincore() can be used by anybody" in order to 
> > be conservative with respect to userspace behavior.
> 
> What if we lied instead of returned -EPERM, to not break userspace so 
> obviously? I guess false positive would be the safer lie?

So your proposal basically would be

if (privileged && !CAP_SYS_ADMIN)
	if (pagecache)
		return false;
	else
		return do_mincore()

right ?

I think userspace would hate us for that semantics, but on the other hand 
I can sort of understand the 'mincore() is racy anyway, so what' argument, 
if that's what you are suggesting.

But then, I have no idea what userspace is using mincore() for. 
https://codesearch.debian.net/search?q=mincore might provide some insight 
I guess (thanks Matthew).

-- 
Jiri Kosina
SUSE Labs

