Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30BE5C282D7
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:02:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC39020836
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:02:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC39020836
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0A2DE8E0150; Mon, 11 Feb 2019 15:02:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 02BB28E0125; Mon, 11 Feb 2019 15:02:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E37168E0150; Mon, 11 Feb 2019 15:02:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id B71B78E0125
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:02:09 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id h6so13160710qke.18
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:02:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=bJ92XFGdXoI66IabC1B27UhUDJuwdv8r8xTw01NIqEw=;
        b=Xm0NZi5oiIb2ewmMzCaTcc1T03UHpkCemi20DoHL7gqpoKi8LNgBdqPRKumG/b6a9l
         QuD0VU+xDAZ08M77bzYoDybftbTNlURlnR+LieXJmC5NisKp4If+BA1zfQ+f1/fa97PJ
         tui2xBvboyD40taDIasS7BZVUkeIBuBTwxlPmO6XF7Y3GEcotrzWf0Ohl6+DtMO4Wavi
         ykZ2PWe0rGzVzwquKn0dIFS/YOUri25bB0TYw+Pxeigi/E9pmutNisTGB7xqJwrBNQvb
         b/NEThoLmIT0JYVxv39foWKG3XWNFfteP8ICSfG7Y+qhuMOt2yJaZJlMz5/tTxwWybMJ
         PtAw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZOovjehUFIXHKGpyrMvmrNTIcQcPcFbaMy80ROSPb1JuxZmObK
	NjPYUxhj50Na5s869IVMJo1mHuluh80/veVMwFaMV2Lzih/iNwBwbiikFA8P5EBSgLPb2/Ddy9b
	+/9rQrcat+v9g1CPQxAlw+FrlWEzosZUrnl+EIg8qL0GFSluKTG40eCZ4hRd7m+w7KQ==
X-Received: by 2002:a0c:b068:: with SMTP id l37mr18638946qvc.21.1549915329515;
        Mon, 11 Feb 2019 12:02:09 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYlvdprs/+6BEOUO9K7Kk5hmJMIJzhAVCulfq292o5Y/71BXepB55NKeeiMa9DeITyVvzZA
X-Received: by 2002:a0c:b068:: with SMTP id l37mr18638909qvc.21.1549915328959;
        Mon, 11 Feb 2019 12:02:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549915328; cv=none;
        d=google.com; s=arc-20160816;
        b=QB1QPYPKcqp6PS66mUM1rcq5wUnOKg/RLwbbo5VMBJw/86Wd2uHgm3IoBTynKzOOjW
         o66UZMhCbW/jct9uEgfi7nP5LnBNznHHDizNeJAb17xjPHFzAduwviobj4DW3vN4bjvm
         tO6HdJ08B4Rvd6GIXvDNBtp7xp4l4J1Vo+aGJZ4ownT+j57PjbZyKnASonIR5CkaBrbs
         iufNzzgsE2LqLMi+cmIFTR+MDRVC3M9cpgZ5O8Y7dNuazA97SrH+aRYaps87s8000Ex2
         fgBxCB+xSZ2nRLAEjT9i3LOZhkV4qPBMh//ptqaEyQSUqOxGyi0JKJrji0kOX5ljeBZT
         jiiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=bJ92XFGdXoI66IabC1B27UhUDJuwdv8r8xTw01NIqEw=;
        b=W0PA9ItU+DmQZYP/aWGLH4tovtvii5Slwt2ZBtMxYYgRVh7auS8uqOYH5SXOpAvDb2
         YoFnxWh+3qcwK5UnMsi3fAtI/R7w11NO3kVn5kg/0q2cFni5KKgLbf0M92BOivTOqOCp
         2iAD70qIgROA7HrRDfmWD14aOAjXUfrAAFp6M1GW5V9xs/VNNF8nLW5CkJHXm7l10NXy
         eFQTh5L/GMoEAva72HxKm8AGST50rQ3xqrDgQMsUyO+pJE138n0MEMg3WCO9tYFzLUux
         PT1RzHmJs7CzTYjei7y0eHoGjb1eoU682cfFvh7fClHQdVhPGQv+N0iEH2ZuOXVSyNIw
         fpjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c18si6529444qvb.181.2019.02.11.12.02.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 12:02:08 -0800 (PST)
Received-SPF: pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of aarcange@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=aarcange@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AF3B358E22;
	Mon, 11 Feb 2019 20:02:07 +0000 (UTC)
Received: from sky.random (ovpn-120-178.rdu2.redhat.com [10.10.120.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 714BD5C21A;
	Mon, 11 Feb 2019 20:02:01 +0000 (UTC)
Date: Mon, 11 Feb 2019 15:02:00 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Peter Xu <peterx@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	Jiri Olsa <jolsa@redhat.com>, Namhyung Kim <namhyung@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Matthew Wilcox <mawilcox@microsoft.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>, kvm@vger.kernel.org
Subject: Re: [RFC PATCH 0/4] Restore change_pte optimization to its former
 glory
Message-ID: <20190211200200.GA30128@redhat.com>
References: <20190131183706.20980-1-jglisse@redhat.com>
 <20190201235738.GA12463@redhat.com>
 <20190211190931.GA3908@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211190931.GA3908@redhat.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Mon, 11 Feb 2019 20:02:08 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 02:09:31PM -0500, Jerome Glisse wrote:
> Yeah, between do you have any good workload for me to test this ? I
> was thinking of running few same VM and having KSM work on them. Is
> there some way to trigger KVM to fork ? As the other case is breaking
> COW after fork.

KVM can fork on guest pci-hotplug events or network init to run host
scripts and re-init the signals before doing the exec, but it won't
move the needle because all guest memory registered in the MMU
notifier is set as MADV_DONTFORK... so fork() is a noop unless qemu is
also modified not to call MADV_DONTFORK.

Calling if (!fork()) exit(0) from a timer at regular intervals during
qemu runtime after turning off MADV_DONTFORK in qemu would allow to
exercise fork against the KVM MMU Notifier methods.

The optimized change_pte code in copy-on-write code is the same
post-fork or post-KSM merge and fork() itself doesn't use change_pte
while KSM does, so with regard to change_pte it should already provide
a good test coverage to test with only KSM without fork(). It'll cover
the read-write -> readonly transition with same PFN
(write_protect_page), the read-only to read-only changing PFN
(replace_page) as well as the readonly -> read-write transition
changing PFN (wp_page_copy) all three optimized with change_pte. Fork
would not leverage change_pte for the first two cases.

