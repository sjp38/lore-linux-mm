Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 529DCC282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 21:10:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EDF820882
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 21:10:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="ATAhGi2s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EDF820882
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 934C78E0002; Tue, 29 Jan 2019 16:10:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E54E8E0001; Tue, 29 Jan 2019 16:10:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7FC738E0002; Tue, 29 Jan 2019 16:10:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E1698E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 16:10:20 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id o23so15187116pll.0
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:10:20 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Wxh59vCeZzc/niritQQciNFuN8LGjFJi0zZVJrNwVb4=;
        b=PQ8gzLUPTZ8jIIiEHERGiO29gzD5JHPsDd+Z65iUHyrOSec9Af8UD4ytDdNUvjq2To
         S3duORK1KjLGRDb5ViOFAT9E3Peixqu6EQdrGedhwCUpKEQWcXImpXZNUHeWCd+jiIrG
         Jwq2Wax6W7tpj8KOoFPICT74Setf0zYFTqzsqZ/mq8AJMk4AuxxY3YQaQQ8D/nKZIcPG
         udHctUwlJL9pQ7y3O23HMyqy9IkXArvuWVafsLy1bYtMMN3XPLgQQPM/CDOqZ/ls/BCK
         6bmNwN/mRlOoKxdewtDoqNq7aKVIQuWo+fILF07X3QFQTmWJMEdRkdGMxxWA+3PgHbZ8
         5aAA==
X-Gm-Message-State: AJcUukcp1TImGTxgTbSf83lhBOqjKzDa0/mhUvQKPpncd15YU3V3NhhQ
	lDl7UynBJVItsH7ZiWCVtfC6mQv39ZTa4rx5lg5vl9QHTD/VkWa8L/gakFtkCx+occ3XKvXXtXB
	uwRuL3SMAE5yNa8qXR4tayknrc/Kw6d9rDCjNYMgFK7RDB13CUfVQpg6KQC6puSBbjw==
X-Received: by 2002:a63:fb15:: with SMTP id o21mr25115748pgh.211.1548796219837;
        Tue, 29 Jan 2019 13:10:19 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7/SvlgPU8xURNE2N941KqWAgrr9cDnJ7KiA8edeyF06A+V6ZF+sVM4Xl5CLRPM27vPKrkN
X-Received: by 2002:a63:fb15:: with SMTP id o21mr25115713pgh.211.1548796219066;
        Tue, 29 Jan 2019 13:10:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548796219; cv=none;
        d=google.com; s=arc-20160816;
        b=Pyu+eEiXOfJku1YnM+SfcHV3+/VuSdpOMrA430Uut432fsPbI7RZC1gvvN9vrHgtom
         bwlvZxna0p9KxpTWfdvnr31/p5iD7XuhmZYc3eUwaKR3BUDfQNarHQGutHAzv4uWeAvj
         8PUytEUpQVdrVIwCTw00AKi4OgHcx7LW58fO3NRl1Ft/vqTQ5CGtALzFlF3nhq1VdfYV
         dQFmcAgIaIJHH6e0G1uSPFPrOEyNHzfRdmh3IyOAD8nzNtsoW5KKfxTPIv2uHqMot6MM
         s5BmZ1+vCmUXeKCZ8LLx11BzeuCaZpHxTOOdwMjc8rQnyfK3dBlwXgmK9kb4HMCVdOnp
         6MRQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Wxh59vCeZzc/niritQQciNFuN8LGjFJi0zZVJrNwVb4=;
        b=MLPwcVnrcHIw/v6u+RTeA1zXdbtLicSOEjgc12FYbNc6YGbxeUduUlOMwS6pWV9deA
         F1UNFXoy7zX3n/d2xgo6Kh0yw8pRinaadrvuRcGydJgQOurx83EISP4Yy9rV4Pg6Bu4m
         QqItimaXXZQsdbBVQUDidkSuUOrT2m1ALttwBbeIkIhwjKwCREe2XqvhZeonbrIsz8zn
         6jyzIyXoZ/zUGzSjH8r/NVNSw/QWt8+HimlCLeIL1+d/s2+MR6tB3GXJWtG/ZTA3qIu+
         uKKWFaWUCtR1Dm1/y3d4RS2XiePRnPd4NJhT9hkjNsngT4+MXyA0ezWMU9VUbtXGMpaM
         oSuw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ATAhGi2s;
       spf=pass (google.com: domain of helgaas@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=helgaas@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id ce11si28442115plb.420.2019.01.29.13.10.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 13:10:19 -0800 (PST)
Received-SPF: pass (google.com: domain of helgaas@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=ATAhGi2s;
       spf=pass (google.com: domain of helgaas@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=helgaas@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [69.71.4.100])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6727820881;
	Tue, 29 Jan 2019 21:10:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548796218;
	bh=qWO9bM+DuNPqJmOmyb7lU7cbI5oNTcA6OD6LaHnrAgA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=ATAhGi2sNENIXqgsDaKRJ1CTeMrwZzJTV+WAOSQpInXRnOebj1m4LyjbTUAGkXpd/
	 gUOn0R3XIuTDEAu1cZXROOF89hGa3Y5tMaPapjP7CMZoQPVWR4r8BYtY4mGsqAaBC8
	 fHoNhv6oaaQt0knPY9UOcbzx1gj1+F33Myrqqetk=
Date: Tue, 29 Jan 2019 15:10:15 -0600
From: Bjorn Helgaas <helgaas@kernel.org>
To: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-pci@vger.kernel.org,
	x86@kernel.org, linuxarm@huawei.com, Ingo Molnar <mingo@kernel.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Martin =?iso-8859-1?Q?Hundeb=F8ll?= <martin@geanix.com>,
	Linux Memory Management List <linux-mm@kvack.org>,
	ACPI Devel Mailing List <linux-acpi@vger.kernel.org>
Subject: Re: [PATCH V2] x86: Fix an issue with invalid ACPI NUMA config
Message-ID: <20190129211015.GC91506@google.com>
References: <a5a938d3-ecc9-028a-3b28-610feda8f3f8@intel.com>
 <20181212093914.00002aed@huawei.com>
 <20181220151225.GB183878@google.com>
 <65f5bb93-b6be-d6dd-6976-e2761f6f2a7b@intel.com>
 <20181220195714.GE183878@google.com>
 <20190128112904.0000461a@huawei.com>
 <20190128231322.GA91506@google.com>
 <20190129095105.00000374@huawei.com>
 <20190129190556.GB91506@google.com>
 <20190129194534.00004087@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190129194534.00004087@huawei.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 07:45:34PM +0000, Jonathan Cameron wrote:
> On Tue, 29 Jan 2019 13:05:56 -0600
> Bjorn Helgaas <helgaas@kernel.org> wrote:
> > On Tue, Jan 29, 2019 at 09:51:05AM +0000, Jonathan Cameron wrote:

> > > However, if there is NUMA description, but with bugs then we should
> > > protect in depth.  A simple example being that we declare 2 nodes, but
> > > then use _PXM for a third. I've done that by accident and blows up
> > > in a nasty fashion (not done it for a while, but probably still true).
> > > 
> > > Given DSDT is only parsed long after SRAT we can just check on _PXM
> > > queries.  Or I suppose we could do a verification parse for all _PXM
> > > entries and put out some warnings if they don't match SRAT entries?  
> > 
> > I'm assuming the crash happens when we call kmalloc_node() with a node
> > not mentioned in SRAT.  I think that's just sub-optimal implementation
> > in kmalloc_node().
> > 
> > We *could* fail the allocation and return a NULL pointer, but I think
> > even that is excessive.  I think we should simply fall back to
> > kmalloc().  We could print a one-time warning if that's useful.
> > 
> > If kmalloc_node() for an unknown node fell back to kmalloc(), would
> > anything else be required?
> 
> It will deal with that case, but it may not be the only one.  I
> think there are interrupt related issues as well, but will have to
> check.

Sounds like a valid concern.  Also, kmalloc() in general looks like a
performance path, so maybe it would be better to address this on the
other end, i.e., by ensuring that dev->numa_node always contains
something valid for kmalloc(), interrupts, etc.

Maybe set_dev_node() could be made smarter along that line?

Bjorn

