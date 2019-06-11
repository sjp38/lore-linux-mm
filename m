Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECA54C4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 09:31:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B46B1208E3
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 09:31:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B46B1208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=units.it
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5429E6B0008; Tue, 11 Jun 2019 05:31:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F2BB6B000A; Tue, 11 Jun 2019 05:31:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E2646B000C; Tue, 11 Jun 2019 05:31:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1777E6B0008
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 05:31:04 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id k36so4288953pgl.7
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 02:31:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:from:cc
         :subject:in-reply-to:mime-version:content-id:date:message-id;
        bh=rCgtkbIEeIY97pXZSUXY8tWDaxOP5st28FJb1bNw/YY=;
        b=GmgnmV6H8TeZkfyf6Psq96afp3jijidOlLyo7Q+arS7R72lJVKSzW3pjxfRQTxdNYi
         sMdlufJKykUMLfkQ3CeaBxFyJtzjXILp9yPbf1Xx2bQoKN82YEEKRRqu8nnioDpZn4NT
         2PRx/wtKRybBeYj7+mf2Z+if3UD5xlZDfzdrBpTlYlEdgjj4TQ6nFlJ3dIvQ0V0bR8To
         XQpHh0cPxTNblHyN8Erhk/ZhG+ZD8vDwVuw+9nwgmF29IneW3/spd76z7cSlHW7L/1CL
         j9rp/BktSLaPeqLO+Ip1X5blcIcrLpp2LkZsxhiAlH/HQ/qXHIWXJYUGu2alls962B+k
         jpOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) smtp.mailfrom=balducci@units.it
X-Gm-Message-State: APjAAAVUBEgtqwrj5f4d8OGmewHxvZjW9XPUykABVgHKH/D9I0vNGF1Y
	3GA32tWsgsXkyEmrJFNaxMDLk9z5egguYkWorVkVIuXJe0iW7qPsyZRe02TfBGdLjUPz++VmA9W
	ZVZt6RkiQinOElTfoBKi+DIlrcsecHlsJn+qZdQ8o6tZO+W87yOsYO6pK1iQT39nuUQ==
X-Received: by 2002:a17:902:112c:: with SMTP id d41mr73386924pla.33.1560245463647;
        Tue, 11 Jun 2019 02:31:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyhNIbqIQ391e+MTpST7lKTk5lYpnt+N8b6EKDIwRwd4WnHhZvv6PjMQmAi69bD/XBia961
X-Received: by 2002:a17:902:112c:: with SMTP id d41mr73386867pla.33.1560245462837;
        Tue, 11 Jun 2019 02:31:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560245462; cv=none;
        d=google.com; s=arc-20160816;
        b=qPSJYyRx8qmpQaRE0S2ItsKQh7ya2lXGA/9OcZAXPeO07GdS9GiwFdo5diF6t0JpER
         kv4krBQYfa093KWrFFZvIvW6zgbsnZgbXYOLGO/OwIAoZuv2VKyzLGK2Ynku9MpY0RGB
         w4kbSiniHwV603eP+7YsiNJiva9viObzcPvM5lW1dMlV+aVnC7fwHtd+01eKftt35ZUf
         2roSSIQGtWlP/KTHX/y7NsuVPBN3OfMSuKt55aulDSOPtrDUb1bbcGoJmdlvy2JAaGA9
         OoQgW2pyztaCfkEmy/iC9pj/bFkPbzNbHW+iV/9EpX2UHXSavQphMd6zxPm4cv7dUX/C
         HpvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:content-id:mime-version:in-reply-to:subject:cc:from
         :to;
        bh=rCgtkbIEeIY97pXZSUXY8tWDaxOP5st28FJb1bNw/YY=;
        b=cpcQ5/uWQSjvs9O6ap1v88RfMF5u4QKc5uPycgKnLHm8RfJxd1A8Mx7VfywSKD2YXx
         B701forUAhDzyByjDdEA6ezGT3zLpRxvQXXOuPCUA8piifH86DYhIPEnNeB7TlENK/3S
         rHVgFAIpiO+OyXZCNRh6kvhJd/3PZIcejcjBJu4G9d/tt8Fmybo/yRzob0iFOIrtfl6b
         3ikDo6hv2rhbP2wUtRZwKM9DqHlk+3lT0aj+IydMBO3ZccWVsJBrRp3Lmt+MprXQGhGW
         JG3YblhPFichJvHXpxNCBLOItKVxZH+HHpoGRQbp4BJIgRaOKh5yiNtqMo+azzj7aWX1
         j/DA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) smtp.mailfrom=balducci@units.it
Received: from dschgrazlin2.units.it (dschgrazlin2.univ.trieste.it. [140.105.55.81])
        by mx.google.com with ESMTP id a18si7896010plm.171.2019.06.11.02.31.01
        for <linux-mm@kvack.org>;
        Tue, 11 Jun 2019 02:31:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) client-ip=140.105.55.81;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of balducci@units.it designates 140.105.55.81 as permitted sender) smtp.mailfrom=balducci@units.it
Received: from dschgrazlin2.units.it (loopback [127.0.0.1])
	by dschgrazlin2.units.it (8.15.2/8.15.2) with ESMTP id x5B9UW4r003046;
	Tue, 11 Jun 2019 11:30:32 +0200
To: Mel Gorman <mgorman@techsingularity.net>
From: balducci@units.it
CC: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org,
        akpm@linux-foundation.org
Subject: Re: [Bug 203715] New: BUG: unable to handle kernel NULL pointer dereference under stress (possibly related to https://lkml.org/lkml/2019/5/24/292 ?)
In-reply-to: Your message of "Tue, 11 Jun 2019 10:03:45 +0100."
             <20190611090345.GC28744@techsingularity.net>
X-Mailer: MH-E 8.6+git; nmh 1.7.1; GNU Emacs 26.2
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <3044.1560245456.1@dschgrazlin2.units.it>
Date: Tue, 11 Jun 2019 11:30:32 +0200
Message-ID: <3045.1560245456@dschgrazlin2.units.it>
X-Greylist: inspected by milter-greylist-4.6.2 (dschgrazlin2.units.it [0.0.0.0]); Tue, 11 Jun 2019 11:30:33 +0200 (CEST) for IP:'127.0.0.1' DOMAIN:'loopback' HELO:'dschgrazlin2.units.it' FROM:'balducci@units.it' RCPT:''
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.6.2 (dschgrazlin2.units.it [0.0.0.0]); Tue, 11 Jun 2019 11:30:33 +0200 (CEST)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000007, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mel Gorman writes:
>
> Any news with this patch?
>

oops: I run the patch and reported by email (CC'ing to bugzilla): either
I botched something with the reporting mail or you missed the email...
(my report is on bugzilla, though, comment 20)

I reproduce the report here:

> no joy; I left the FF build running and found the machine frozen this
> morning; however, firefox build could apparently complete successfully;
> I can't say when exactly the problem happened, as I haven't found any
> message in the logs

I can add that since the last attempt, after rebooting into 5.0.15, I
have built a lot of software (including FF) without any problem; this
enforces me in the conviction that there must be some problem for
kernels >=5.1

Does anybody else reproduce this?

thanks a lot
ciao
-g

