Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C983FC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 17:21:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 94020206B6
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 17:21:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 94020206B6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D040C8E011C; Fri, 22 Feb 2019 12:21:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAFF18E0108; Fri, 22 Feb 2019 12:21:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B79BF8E011C; Fri, 22 Feb 2019 12:21:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 89A938E0108
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 12:21:45 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id 43so2632555qtz.8
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 09:21:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=dknhRUOWvWuzFmvUh455sOK4Id5MTsNcbc5OzMX0gF8=;
        b=uVSCIS6pjSOUddt/qpCuzaBYslAFXQQ46ejaouWS4glg4OrHoOdHsgDGXyooha+Lwz
         rzr4qFrbtGdBmu40nKeX6JqkTYOCmqy1VtCGfdMkvFwN1ZjaCPg5CyyuFbHcqE1w/NjO
         Guyiz2VPxoCP/92BiRodeq8JSIQSc7TFtef5Ss2ezXfk0kbNMvM0mMm4N6dkHwqSJOeG
         hufjfJVu6LivhkkXNfH9lWgaQZGcwCzI8syugpkTKx6b7ekmzxiNYVA0/QY1wPV7e46F
         1/zBZhQNzv4hKgmEdJF7UBDjmfixcWv78Jzr+COlXWUubW535AFupgbPsXnk9doQ0f+b
         eT+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuY/HcOv1vXJRKJGPDg9OWbrDkYTzsYcRobUdsznEyoVqUn7E0an
	ckwA4qUbSPVCI9OrwgQBttxJGqYwgnV7iEcdAqlXJeIAXH+2pbRTKxODmFLbZtE5dpn6oBBAaBe
	IU6Jd6aj0kHqukNsaE+BesT77Gzaow64wJRmqjDDMOZCxQb9T8yWKQWeo7jIcveTejw==
X-Received: by 2002:a0c:d237:: with SMTP id m52mr3913832qvh.219.1550856105307;
        Fri, 22 Feb 2019 09:21:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYwSlBTCRPu/r0KraDRJ5s2P7s2F4vqWk84/gbyDxCE54baNXlZH/Vdh4odMH9qizRQW4Op
X-Received: by 2002:a0c:d237:: with SMTP id m52mr3913778qvh.219.1550856104645;
        Fri, 22 Feb 2019 09:21:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550856104; cv=none;
        d=google.com; s=arc-20160816;
        b=GMhVy29iRmbI8To+2wZ/4K85VkvailIBwmHQ3cjd4PXWecStfqvQHNO8MU6LdNEdQ2
         bSTvYgexzBMb7oMadCot6twz2POTqrt3C8bFvNUkipByGiZVnw6qae4cVflk4Wm8r9ik
         jdn9OQPJigrfTcPOUfTOZA2EMK5/xFGghzUA0CAkAv06OQ9uvyaDw5JY5boFt38Qpghm
         mQmOrSxDAWXi2WBQ4dBr89aA7GekYB4n4dZuphxntmAXCzIEqp674WnLw77EXLZoUQVs
         JpzitQD7FTeqsFEQ7kvlUQ8EIHH0IFB0zOOoeivgobhiYD6BkYNt0qThuCapkdNW+nFw
         gjNw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=dknhRUOWvWuzFmvUh455sOK4Id5MTsNcbc5OzMX0gF8=;
        b=H2P8FyW4W6lSbTpE/BP4tzg4AzAtLR5srKdvkRk9gSVqCQxfz2Vgb6TYuRgJKYM8ec
         lWqixRjS8ltwmnt6r57O6ap8e4dByIev5Z5tlWdgU81HL32t2fDS5+I2CE9xLo6I72eL
         zmpACgPoxIvasRjX/PoiTeAI1Q9dBsPv4nABX9zG5NTZ8wxGfVf3L63zu4eXx5qg5zWJ
         MOrc0YFejPFAYdLa7D8WntwAAkTm4iYjIExCwwOhjU4HAAj3ijECLhaSWi5f5aXhhBG/
         GrAt+1a74OEmHxrNBjgUZAtKL7ik3+TaSududw3dOWC7q+Vsmq2d7fco7h9RME5xBmUI
         JqYg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a49si1269289qva.62.2019.02.22.09.21.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 09:21:44 -0800 (PST)
Received-SPF: pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jmoyer@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jmoyer@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AFAE3C057F4F;
	Fri, 22 Feb 2019 17:21:43 +0000 (UTC)
Received: from segfault.boston.devel.redhat.com (segfault.boston.devel.redhat.com [10.19.60.26])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id E97F85C647;
	Fri, 22 Feb 2019 17:21:42 +0000 (UTC)
From: Jeff Moyer <jmoyer@redhat.com>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm <linux-nvdimm@lists.01.org>,  stable <stable@vger.kernel.org>,  Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,  Vishal L Verma <vishal.l.verma@intel.com>,  linux-fsdevel <linux-fsdevel@vger.kernel.org>,  Linux MM <linux-mm@kvack.org>
Subject: Re: [PATCH 7/7] libnvdimm/pfn: Fix 'start_pad' implementation
References: <155000668075.348031.9371497273408112600.stgit@dwillia2-desk3.amr.corp.intel.com>
	<155000671719.348031.2347363160141119237.stgit@dwillia2-desk3.amr.corp.intel.com>
	<x49ftsgsnzp.fsf@segfault.boston.devel.redhat.com>
	<CAPcyv4h9s1jYROGqkMfKk0MNBUedP=vQ1nJObLRwFiTB405nOg@mail.gmail.com>
	<x49imxbx22d.fsf@segfault.boston.devel.redhat.com>
	<CAPcyv4jweuVTm6D2OTaAMGvUXfxqZMDPfaASJ=QL9=8SdGUZqg@mail.gmail.com>
X-PGP-KeyID: 1F78E1B4
X-PGP-CertKey: F6FE 280D 8293 F72C 65FD  5A58 1FF8 A7CA 1F78 E1B4
Date: Fri, 22 Feb 2019 12:21:41 -0500
In-Reply-To: <CAPcyv4jweuVTm6D2OTaAMGvUXfxqZMDPfaASJ=QL9=8SdGUZqg@mail.gmail.com>
	(Dan Williams's message of "Fri, 22 Feb 2019 09:12:37 -0800")
Message-ID: <x49a7inwxga.fsf@segfault.boston.devel.redhat.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Fri, 22 Feb 2019 17:21:43 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Dan Williams <dan.j.williams@intel.com> writes:

>> Great!  Now let's create another one.
>>
>> # ndctl create-namespace -m fsdax -s 132m
>> libndctl: ndctl_pfn_enable: pfn1.1: failed to enable
>>   Error: namespace1.2: failed to enable
>>
>> failed to create namespace: No such device or address
>>
>> (along with a kernel warning spew)
>
> I assume you're seeing this on the libnvdimm-pending branch?

Yes, but also on linus' master branch.  Things have been operating in
this manner for some time.

>> I understand the desire for expediency.  At some point, though, we have
>> to address the root of the problem.
>
> Well, you've defibrillated me back to reality. We've suffered the
> incomplete broken hacks for 2 years, what's another 10 weeks? I'll
> dust off the sub-section patches and take another run at it.

OK, thanks.  Let me know if I can help at all.

Cheers,
Jeff

