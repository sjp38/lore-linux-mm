Return-Path: <SRS0=AIe5=P2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99608C43387
	for <linux-mm@archiver.kernel.org>; Fri, 18 Jan 2019 16:36:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 595842087E
	for <linux-mm@archiver.kernel.org>; Fri, 18 Jan 2019 16:36:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="FkyDdINE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 595842087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC4D68E000C; Fri, 18 Jan 2019 11:36:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E4A908E0002; Fri, 18 Jan 2019 11:36:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CED168E000C; Fri, 18 Jan 2019 11:36:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9F5128E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 11:36:04 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id o8so6480900otp.16
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 08:36:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=lw/evbXQOPWl45yh4xmiSoRgJO3UEKa0j1zf5GEngpE=;
        b=BxryWBZ6bPD6tZYN6XlpdnYX6JBTxDLIMORcVfTtfBxsJdtYV7MkmAL+HmRVPeP12t
         YAdHTSLi04xoUOZRVhjdtgEiquAxBEc/YB7joYIXhesqevp+udid9i2+bqeUTR3bRfr1
         aThhE09SV1/V+JL3g0/6/0sw5Dhoj1yYHWECU6dHHI3bl8drmLwcc/Dxfbx/yrDTwQVu
         LnKXIq3qx5VRF28Vo+Jlwf+LZNxXYPDJOcR8Yxxb1d0i/DqpdwUOUGQoAUIj6bbY8Y1T
         5n2zJw9Vg4ciVNNcl9sZiB4a6hvwe0Q73jXRRqYXntfTA9D/pfJ2t4NZAe71lSq8lSqF
         MyJQ==
X-Gm-Message-State: AJcUukd4lmxs7//nQ5fPuMQ9smk2Z898rXKFngkcU/bALxc3Inld3a/E
	hllHlNIYCTtWlbv1CKX7v8midupPSDR8w0bsQNOrHONx7fbwNIRViEky5XzWj0d9G58HkYQ079u
	DdJfu1BHMIz4PxpqA5ONj736M+FFQdOOtRkMkvADbr09i3eBfl0X/EP8T8CALPGJvkD+nRgQ+KN
	G0/fxGLht3RuE0kPJI0C7npJRBaMyA97CNTak5WM2cujR9Qf0vX1bfpFzVH3YInRBX8BFMmdxPV
	fTyihMMpSVs+W0wSokvCaKgFIWpKJG8cRmu0KNYaX38ovtMGWVdVEOPPEFk36JfLKvDH+GP/SGT
	798DWINbpk/W6rq0MOGq6azuWBda7+gZPAUDzw4WmHKswBgQ1SXHHN/afgK3UMri0K0ZTaWZjC+
	7
X-Received: by 2002:a05:6830:1310:: with SMTP id p16mr7775097otq.309.1547829364242;
        Fri, 18 Jan 2019 08:36:04 -0800 (PST)
X-Received: by 2002:a05:6830:1310:: with SMTP id p16mr7775079otq.309.1547829363574;
        Fri, 18 Jan 2019 08:36:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547829363; cv=none;
        d=google.com; s=arc-20160816;
        b=RRJuQanPb83Weib0gb4I30/DhmThRl3MwD127fX7l+0jSUSBlp8T+upXCKvr+0fh9H
         vRukDECKTFRBTM8wnqAcNswPgofls5PnVFUw/Lrmf6Cqodn3Jv+ll+jKyR1HsAUiQ9Ev
         BaM4GhclvyaBtwGKzAxxDBZLGuYfxvsZ2F7bwq9r/aqjdtgaW6ndqOOZy5YXCa/HO9Pg
         0OeGjq6VmvDhPbXiH+v0uSdvU6vRx16Ku1b3yjkWsUIVusZXrlZkkYlU12808FzC1Fch
         C6Di7aO6ezxiUIYdGQCcgrNCJDK9S6y4oGNPs7e6L24NGZOOdTBfR+/QynGiEzmCdUX0
         aVng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=lw/evbXQOPWl45yh4xmiSoRgJO3UEKa0j1zf5GEngpE=;
        b=y+yrxfRZFMwHefNjopNKdf8HUhq4ZxrVQFw6JdOuzeSNl+1eJT0WhCPgOi0VMykw69
         GTlahEGBPDpcWKvg9dywJhgsukmTbYK4x7jrmOKyiXO3wB0D8KZwfM/LPEcoUhLNK4U3
         /bB0eeYv0Rqvgg04OBlUfwuI3B83B4MYj8VFCOJbljyWGUZU/gutJ6RemQhbJNDoGMFs
         8KAtuapuSWpESHmMeUs/pLYyXGlQQZa7f+z4klJGx+SGIBKi586Y4gCrklsuufTIowwc
         w3zqsCvCtA0S0tEPGVCjaHd470k2hwSQB7sRpz7S8c5kVdfiPPrL9y8Jdk9E6kdeJMvF
         3ITQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=FkyDdINE;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t22sor3011665oie.57.2019.01.18.08.36.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 Jan 2019 08:36:03 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=FkyDdINE;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=lw/evbXQOPWl45yh4xmiSoRgJO3UEKa0j1zf5GEngpE=;
        b=FkyDdINE7f0BKmDJo6ikxgnXGoIaF5K38PG+i+7xq6DmDquvdWOBQ2bbhUR1jl5EWv
         bxHWPbdJBJxEQhaBYcV9rTl9ywrNqm/5N3TE/pGpTeSb+QSpGui0VlIlYien91SCNjNJ
         1JnfZuUQ7k/Ix3/0ZsyQmDE28VNdPJVxpqA7iROn5fxzfx5l+Y8D7O4OepVQ10J89+DD
         aXnJTkmcn5UGb5iz+ZiZHs6JsJ3ewxugNSjLQo9WJjbK+kBGZgMEuB6xjIrw4puTyQ9/
         wjWQgQVLo0l2wYO2DO9RmxUS2+StTPgCQIFRJySc9Bkx4Houx41p1gZN8mrx3OoMgNao
         foJw==
X-Google-Smtp-Source: ALg8bN7dlQwuuKqJEM5wiSPeX3yUCYfDc6SJidEHI/YbGPyjaU7mSqy4lEZ/5GiWydE/OcfOq4RyZfeGFt0ugk3Zxm0=
X-Received: by 2002:aca:2dc8:: with SMTP id t191mr472109oit.235.1547829362554;
 Fri, 18 Jan 2019 08:36:02 -0800 (PST)
MIME-Version: 1.0
References: <20190116175804.30196-1-keith.busch@intel.com> <20190116175804.30196-6-keith.busch@intel.com>
 <20190118112134.00003b65@huawei.com>
In-Reply-To: <20190118112134.00003b65@huawei.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 18 Jan 2019 08:35:50 -0800
Message-ID:
 <CAPcyv4jo20LkXnVuLcvxFOOSGhx7yGN1vy4jv3N33ubk0q0nOg@mail.gmail.com>
Subject: Re: [PATCHv4 05/13] Documentation/ABI: Add new node sysfs attributes
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: Keith Busch <keith.busch@intel.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux ACPI <linux-acpi@vger.kernel.org>, 
	Linux MM <linux-mm@kvack.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190118163550.SkkVtByVhL8XzsOuLkzTyTRofL-N0TCsgl7acG9-XoQ@z>

On Fri, Jan 18, 2019 at 3:22 AM Jonathan Cameron
<jonathan.cameron@huawei.com> wrote:
>
> On Wed, 16 Jan 2019 10:57:56 -0700
> Keith Busch <keith.busch@intel.com> wrote:
>
> > Add entries for memory initiator and target node class attributes.
> >
> > Signed-off-by: Keith Busch <keith.busch@intel.com>
> > ---
> >  Documentation/ABI/stable/sysfs-devices-node | 25 ++++++++++++++++++++++++-
> >  1 file changed, 24 insertions(+), 1 deletion(-)
> >
> > diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
> > index 3e90e1f3bf0a..a9c47b4b0eee 100644
> > --- a/Documentation/ABI/stable/sysfs-devices-node
> > +++ b/Documentation/ABI/stable/sysfs-devices-node
> > @@ -90,4 +90,27 @@ Date:              December 2009
> >  Contact:     Lee Schermerhorn <lee.schermerhorn@hp.com>
> >  Description:
> >               The node's huge page size control/query attributes.
> > -             See Documentation/admin-guide/mm/hugetlbpage.rst
> > \ No newline at end of file
> > +             See Documentation/admin-guide/mm/hugetlbpage.rst
> > +
> > +What:                /sys/devices/system/node/nodeX/classY/
> > +Date:                December 2018
> > +Contact:     Keith Busch <keith.busch@intel.com>
> > +Description:
> > +             The node's relationship to other nodes for access class "Y".
> > +
> > +What:                /sys/devices/system/node/nodeX/classY/initiator_nodelist
> > +Date:                December 2018
> > +Contact:     Keith Busch <keith.busch@intel.com>
> > +Description:
> > +             The node list of memory initiators that have class "Y" access
> > +             to this node's memory. CPUs and other memory initiators in
> > +             nodes not in the list accessing this node's memory may have
> > +             different performance.
> > +
> > +What:                /sys/devices/system/node/nodeX/classY/target_nodelist
> > +Date:                December 2018
> > +Contact:     Keith Busch <keith.busch@intel.com>
> > +Description:
> > +             The node list of memory targets that this initiator node has
> > +             class "Y" access. Memory accesses from this node to nodes not
> > +             in this list may have differet performance.
>
> Different performance from what?  In the other thread we established that
> these target_nodelists are kind of a backwards reference, they all have
> their characteristics anyway.  Perhaps this just needs to say:
> "Memory access from this node to these targets may have different performance"?
>
> i.e. Don't make the assumption I did that they should all be the same!

I think a clarification of "class" is needed in this context. A
"class" is the the set of initiators that have the same rated
performance to a given target set. In other words "class" is a tuple
of (performance profile, initiator set, target set). Different
performance creates a different tuple / class.

