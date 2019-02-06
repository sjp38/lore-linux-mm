Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EDF4C169C4
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 23:48:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21533218AF
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 23:48:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21533218AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B05078E0005; Wed,  6 Feb 2019 18:48:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8C518E0002; Wed,  6 Feb 2019 18:48:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 979938E0005; Wed,  6 Feb 2019 18:48:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 629738E0002
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 18:48:25 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id n22so7622225otq.8
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 15:48:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=2km3dMyZpRUU5hnOZjk3ra+UsEl0QjP4uRCEE8dLVpA=;
        b=Q728MAMtzobNRbyLxgWmJZpIjaPUjZZscOW/1ZcXoQUSlHA4eqpp0x5HzqEtyAhFsU
         DgmD7NXZ8eW2/TOUkn38Whr1Gz0nHK1kERpoMY7kFdlCPHviKo7b5ADwMKNN3u0OvZsT
         6yv3e3ReetQN5SeMxPhlCe0jicZ/E3uzv8Rd7wldLMK8v/9wYR1xBbgsY7po8fq1xd2m
         BAAiTgxKNOs4PjIiJJZLknH+qWZPkERIjvzV/GbL/r+pAjLtikU30u+c4BGft7MJ4UGQ
         /twGIFtDUNHv81Ax5bcRJWO8zDCLWEj7Bp7uORbChQ/V5FW93UdyQ5M566JHu2R2lef1
         NhDQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuay3k0WzN4GFs9PuEM/kTORp4j5TSdobIGi6HgQZxWCausHw+aA
	E8ociMcI0JUZITLDRX+rSqoKEfcguj3DvMdfoOBVSFh6dBfmGmQYh7EX72lWeLMlq7i2R78UyOp
	ShsIu/yuVOOum6da3BlxgG91T3Xzf6FPoy8gzwiZcKvkJ67rcCSTmGTnHJikwPR7xmbWrGtrO0c
	gPRWSNbvNZhMnjYG6kEQnQjsGAtKfmPi0dtYCVKvNxihyeFib24s3Njq/wo0E24J0dUNyhgzNTZ
	CoIZFMEJurUaRboQ/O7J5HjnCNkBHkwOIUZlPHwKw/4nm4gUCI1TWw2mzJ2tHuJRklhcUQypwRg
	FzXy8RHPPi4c62xt1eqf4MEMGz2oM7G714kVbyMb9l+a/ckFd5dS3O4KNSraY/EOuOfHkjVa5Q=
	=
X-Received: by 2002:a9d:2aa5:: with SMTP id e34mr6687877otb.67.1549496905128;
        Wed, 06 Feb 2019 15:48:25 -0800 (PST)
X-Received: by 2002:a9d:2aa5:: with SMTP id e34mr6687847otb.67.1549496904405;
        Wed, 06 Feb 2019 15:48:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549496904; cv=none;
        d=google.com; s=arc-20160816;
        b=tSO4Vi9yZezKJ3Hn0ejIpCpoT2ypUS6G03BnQNr5KVxMSqfJbqzbzs+XrvnGdiwf5U
         coHYZO0v04muLm0sIAScgPPVCVgpno2KS0GgS8A4eGeormgl3auQhcFCv+cXnDv/Cr5V
         GeaEvF9tH+SEuCHBvbWF1UCi4Dq2cNzXlqeHMZmtttrb8Gefodbe6sZ1EbUnRCtDib4s
         3J/1ovm4w9htvH0Xc+bfQuJfbEVuZI6IMmKHlniyG9++o6UpwFhbExp47J5NPKxUicXL
         FuOYxJufrJlg26NQCC31ZC2UhBFI5jZ3J0B1cFXsNbOHcCKYKk6tu5wYe4kqC29QZHPL
         uljA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=2km3dMyZpRUU5hnOZjk3ra+UsEl0QjP4uRCEE8dLVpA=;
        b=HQQL48t113u3baJHhlEBNlfkZhJkkawHy+1JoMFW6nSWNRk8SRZr/i0zhSI4FTKr6Q
         OnI0wjCNiCyExsqdEdqrzeZG12lhBP3yoXjaIc/w0rzJiW39EkzgY+lao2bGDFJ1cglY
         YiIXqf3v5ncNyWfmynX4/XzFupjZq03meDevshC56C3rCz8f2pCRoPHZqjIeyykTpIZ1
         YMEggDyI5Ym1ugXYrcoh1aW1N2aCYeL6XCMqEmBra3xeQIaDWf3S+3klV/JMci78ueMz
         D9YfCx4mut9ohVlRitH6WG03iIuoF61BQuYwM9hmRlr7WAyEZv7tvBjAflbwcZwe933J
         pqew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 78sor12271211oii.101.2019.02.06.15.48.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 15:48:24 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IZpEk2CWNtYPQQ7KqZEikUauiX+EFdFnS71/6BMSENFy4IR4l4ddI99XqMvH80bYuTgwAvnu48+7Fk1yZ21Y3Q=
X-Received: by 2002:aca:f08b:: with SMTP id o133mr988016oih.32.1549496904026;
 Wed, 06 Feb 2019 15:48:24 -0800 (PST)
MIME-Version: 1.0
References: <20190124230724.10022-1-keith.busch@intel.com> <20190124230724.10022-5-keith.busch@intel.com>
 <CAJZ5v0jE_gRT5WgpQYwZQmx6N5G+axymbSySb2Nk8Q0OGeNt9A@mail.gmail.com>
 <20190205145227.GG17950@kroah.com> <CAJZ5v0g4ouD+9YYPSkoN7CRLTXYymeCaVkYNzm6Q6gGdNgJbuQ@mail.gmail.com>
 <20190206230953.GB30221@localhost.localdomain>
In-Reply-To: <20190206230953.GB30221@localhost.localdomain>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Thu, 7 Feb 2019 00:48:12 +0100
Message-ID: <CAJZ5v0hHCVTui70g0Dcn8GEWOBTW1HCTi=3RXLPRHL_p2U62Dg@mail.gmail.com>
Subject: Re: [PATCHv5 04/10] node: Link memory nodes to their compute nodes
To: Keith Busch <keith.busch@intel.com>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>, 
	Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 7, 2019 at 12:10 AM Keith Busch <keith.busch@intel.com> wrote:
>
> On Tue, Feb 05, 2019 at 04:17:09PM +0100, Rafael J. Wysocki wrote:
> > <gregkh@linuxfoundation.org> wrote:
> > >
> > > When you use a "raw" kobject then userspace tools do not see the devices
> > > and attributes in libraries like udev.
> >
> > And why would they need it in this particular case?
> >
> > > So unless userspace does not care about this at all,
> >
> > Which I think is the case here, isn't it?
> >
> > > you should use a 'struct device' where ever
> > > possible.  The memory "savings" usually just isn't worth it unless you
> > > have a _lot_ of objects being created here.
> > >
> > > Who is going to use all of this new information?
> >
> > Somebody who wants to know how the memory in the system is laid out AFAICS.
>
> Yes, this is for user space to make informed decisions about where it
> wants to allocate/relocate hot and cold data with respect to particular
> compute domains. So user space should care about these attributes,
> and they won't always be static when memory hotplug support for these
> attributes is added.
>
> Does that change anything, or still recommending kobject? I don't have a
> strong opinion either way and have both options coded and ready to
> submit new version once I know which direction is most acceptable.

If you want to make dynamic changes to the sysfs directories under
this object, uevents generated by device registration and
unregstration may be useful.  However, they only trigger automatically
when you register and unregister, so presumably you'd need to do that
every time for the changes to trigger an update in user space.  Also,
whoever is interested in this data would need to listen to the uevents
to get notified.

OTOH, you can call kobject_uevent() for the "raw" kobjects too.

Anyway, if Greg really prefers struct device to be used here, that's
fine by me, but since the uevents in question are going to be part of
your user space I/F then, it may be good to take that into
consideration. :-)

After all, you need to know how you want the I/F to work.

