Return-Path: <SRS0=7n0b=P6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28DEDC282C3
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 16:54:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2F6621726
	for <linux-mm@archiver.kernel.org>; Tue, 22 Jan 2019 16:54:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2F6621726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 836E38E0004; Tue, 22 Jan 2019 11:54:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E5168E0001; Tue, 22 Jan 2019 11:54:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 688E08E0004; Tue, 22 Jan 2019 11:54:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 386558E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 11:54:58 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id b27so9852342otk.6
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 08:54:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=10akT0bp1NHa/2U4y1Gem6h2yLdRu35gxbi/m3mvu2Q=;
        b=sVOJ8M0Kc8/0gSBn21WtXoQUUTDa22b+mR2NDAks+LZL9hAicKPfjF7AJwSgSlkLQz
         /FBl7fBk2r+NGKSY/sxIOmHMhEqbeU3NpXZ9CALlXQW27eYQ2A2/9bFtJVBS3ZVU9yy+
         38u232exeCgWKSWTxBhI/4vzdw3aryZGb05MRqwGgxRPpZzOr6248pdnT5ItqdDVPhS3
         PqZvaUtPy+ulV6YC8fIIq9DGxVj3+6BspXyDXDoaKh+fnzqDp2QpeqaC2psbzh4i3zh5
         VqvkuOiAzbv+xZDG9LVjh7zsDgHJV6vYNz+XH0uKvfqgwjWo5YTxxDL1ybuhHEYX/kXf
         dJzA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AJcUukf/rf1DeMD8D63oEvfQ1++vXpZOKY67XxUPySdvwBLogE+r0Abm
	vFVML7zhfrsqgOFbdKuGOJle7rnu/CuHeSHoCcGq653LnudCLTazmgsakcOMV3AjhV/n602741X
	sFi2j4vWBQ6YjnHmkpa1TM+6V6x37Bl8h9Jn5PUSqYXTtg3geXtylHfejKSWjZYvWZiqkoI5bgw
	u8DR2T/xVzJo/PpQzX9VD6lt4GOiu8qZqsXYLZtO2+1ulEMo4FkpPd600KX4gZ6PNiGWW3ScUnQ
	zFDeF01ARngLg+umRsAq8NlOn9pLdAvtn2EHiT77wwlogCwqrxUOwhvCxwlHV1CUDHi93kaIL1g
	BZt42+vfhGnNnqRVHoWzjjnicZrI4voaLJd4e+uKfGxbd7qQ9imjY5XzvM77gsUKznOvoK8uLA=
	=
X-Received: by 2002:aca:b102:: with SMTP id a2mr9052063oif.180.1548176097953;
        Tue, 22 Jan 2019 08:54:57 -0800 (PST)
X-Received: by 2002:aca:b102:: with SMTP id a2mr9052036oif.180.1548176097321;
        Tue, 22 Jan 2019 08:54:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548176097; cv=none;
        d=google.com; s=arc-20160816;
        b=MNIvoqdQTSjOJ/1R9seLL2egv+i1nAS743IRsRnyeFh61YNESOe2HpPghlt6bTVpXk
         3hTjI3ndYm/WaYwGKAqQ1ywMUmCPof9s8bh4ucY531Sh6NwMJNcrHbX5/QOBUIbSFrjp
         cjb+SRNDSQcy3hGZHl/Gah0J6Nvu6OtPWiqKN2Qm09a/o0f+OzQC+DlD7CnxYNjlgmpF
         DSozecdM/uyGFNgtitdc6XPv0aZ6a9XUNOHh8GNNM3k4wc0E6AkvYRv/6lZq7TL+E7vS
         zy2e8xgmuiaY0rqJOIVYxE6uwsJQVFWHJCv5eVMWauQq9lWi1MTvC+a/DSUCXOY3jHU9
         n8rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=10akT0bp1NHa/2U4y1Gem6h2yLdRu35gxbi/m3mvu2Q=;
        b=NFswOS0IqRTnk22lMTRZX+4iYlByX91+YszgShv5q2GcJRdrJGq3NhHkJx+w2VTW9j
         dl2Z8c8IhRMIVCogU0KK4edcWVLYFvlicOMOvG5upeM7P2UhDTeomwqreg/2cqwVLIA9
         QNLoGx9OBrijCKBLpIuedjn5iuE7/e2asyolL7U0qmUZtOVpfu2Pyj0PIA750oj26Rj5
         CmnuwyqjwtSNu9oPbxc6vWpIl08eO3DsaTtJmKHuUcGx+yIdbC2XRx/BxHDYRpL9voOb
         P8CdK8yHuh45UdY8AJZ/QIjuLW9wv0FA4RZ9BAtAtNsj11FpSRCCS4opedBPb2nmH0fj
         xbqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 90sor9667285oti.17.2019.01.22.08.54.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 22 Jan 2019 08:54:57 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: ALg8bN7/pj42bfI8MW2bGnxgQF7xVHkxCJOb9VEFnDvIEb8DKD9g0HZa8+FBZ9rVqFp0rnIb5zJLxmr2py7CtonYb70=
X-Received: by 2002:a9d:588c:: with SMTP id x12mr23381958otg.139.1548176096957;
 Tue, 22 Jan 2019 08:54:56 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-6-keith.busch@intel.com>
 <CAJZ5v0jmkyrNBHzqHsOuWjLXF34tq83VnEhdBWrdFqxyiXC=cw@mail.gmail.com>
 <CAPcyv4gH0_e_NFJNOFH4XXarSs7+TOj4nT0r-D33ZGNCfqBdxg@mail.gmail.com>
 <20190119090129.GC10836@kroah.com> <CAJZ5v0jxuLPUvwr-hYstgC-7BKDwqkJpep94rnnUFvFhKG4W3g@mail.gmail.com>
 <20190122163650.GD1477@localhost.localdomain> <CAJZ5v0ggO9DePeYJkEoZ-ymB5VQywBgTnsGBo4WPHD5_JrjKRA@mail.gmail.com>
In-Reply-To: <CAJZ5v0ggO9DePeYJkEoZ-ymB5VQywBgTnsGBo4WPHD5_JrjKRA@mail.gmail.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Tue, 22 Jan 2019 17:54:45 +0100
Message-ID:
 <CAJZ5v0h1Q_dtJu7eXvs-7-bFRBBhLC158H1FKv96nE87rHv40A@mail.gmail.com>
Subject: Re: [PATCHv4 05/13] Documentation/ABI: Add new node sysfs attributes
To: Keith Busch <keith.busch@intel.com>
Cc: "Rafael J. Wysocki" <rafael@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Dan Williams <dan.j.williams@intel.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Dave Hansen <dave.hansen@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190122165445.p7JhAtOSFWAsenP10-3Ls5c1zBgckSQ4Q3rObyarY8w@z>

On Tue, Jan 22, 2019 at 5:51 PM Rafael J. Wysocki <rafael@kernel.org> wrote:
>
> On Tue, Jan 22, 2019 at 5:37 PM Keith Busch <keith.busch@intel.com> wrote:
> >
> > On Sun, Jan 20, 2019 at 05:16:05PM +0100, Rafael J. Wysocki wrote:
> > > On Sat, Jan 19, 2019 at 10:01 AM Greg Kroah-Hartman
> > > <gregkh@linuxfoundation.org> wrote:
> > > >
> > > > If you do a subdirectory "correctly" (i.e. a name for an attribute
> > > > group), that's fine.
> > >
> > > Yes, that's what I was thinking about: along the lines of the "power"
> > > group under device kobjects.
> >
> > We can't append symlinks to an attribute group, though.
>
> That's right, unfortunately.

Scratch this.

You can add them using sysfs_add_link_to_group().  For example, see
what acpi_power_expose_list() does.

