Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1CD7C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 18:48:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B76012070B
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 18:48:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B76012070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5456D8E012C; Fri, 22 Feb 2019 13:48:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F5228E0123; Fri, 22 Feb 2019 13:48:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 396A38E012C; Fri, 22 Feb 2019 13:48:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E767D8E0123
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 13:48:30 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id j13so2163338pll.15
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 10:48:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=/eSseL3F9ekfkN4+acQPnKUV3WUrZ1thPceUqMBGnQE=;
        b=XKbZXxceA37fb1s7HR9sIqxKn4JXAHsp7SfhWrMMlId6mOFZjY6BjQbP2iQJM7G+IN
         YcAx7SeJbKNQWN/RO2gG21JC/3h/j2l3EioON6622MiHQK59WJmf6+yT85rtS43L2o2U
         QwcF4Pg6YxMQAW7Qv+i+8qiXXNAUHNzqK9km7/+DHz4k1c1YjdpJ36EIXsY1M3U+EM7J
         ZA960m5KEwN0ObYL24b/N/JrjhggwBq0SjuJAH7VjG/pUsaxlTfeTa6vZzMFWVKbspz1
         HpaVGxdWSgrC087RNGFq6ajQ2LzsaTg2wvfxRIr/sLwVY/hOZW8rWI8JJKRKRr2r+VON
         DasQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaVUsVsIDCuJXUmL8m8HlHktREhRJhPSGpFOCt2pBfvasp1S97Q
	xy55J8DT5K2AhgLxtnxTZfLnUf3BFgGM3xlo2/nTNN8ma7veu6hq3yrtQhIG3MOSactOxHXBVwU
	V54paGJo2H+4o1I5rVuiPYz35+rBL88SjeYbYheu7iGcJrYTSeEsyW39V9lBSaUW8vQ==
X-Received: by 2002:a63:c40a:: with SMTP id h10mr5374821pgd.131.1550861310472;
        Fri, 22 Feb 2019 10:48:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaxSKzPj3u2WtV1oKEzNQm0PnXPbxKEAAmtBRSONJ4LCyyb6EkB+k7EhGg72NvPP9oLF7Ka
X-Received: by 2002:a63:c40a:: with SMTP id h10mr5374775pgd.131.1550861309476;
        Fri, 22 Feb 2019 10:48:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550861309; cv=none;
        d=google.com; s=arc-20160816;
        b=UwBwto5/VwUU2CJocX6o5s9WdJEpl/Dq0V6JweZBFtxbnXzA/qo1c0DH8V6IoQR+pW
         h5INfHxjBrpsuUofz5MCl4z0JlPJnSBvYwoq6sjVnAtaY8g61tzio1cXcFRFs59bTtkX
         aGV6tJlJG6qKYiW2mE95tnQkW+lVT8+0vY7mAchpLD4RruaDczoXVHUhWns9gli/wCD5
         Ll00bmbejgB0miv/Eq3+D8WPnw9B1jL3l9whhOIZ/dxaPnngrIa3UtaU0ILOn7NIc0Le
         EGn3bMVke7vz2Sp3YUl92F7RQwjuYzIp6SCW0MRFx7C+RerHs1M7+vs1TYvAYxAazEFo
         cEmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=/eSseL3F9ekfkN4+acQPnKUV3WUrZ1thPceUqMBGnQE=;
        b=fkvuyB/XBZg2HZD9s8B3x1ifES4dXa3leqnoLY8TJnHtr9Q1JnTwlwL0DG6orSH1hy
         rEY+WO0FZwWx0ecUuevGrry5lX56CdfkDhr1hl7LscWYYf5gNK1WMXMmJXgv87ed+aqG
         agAmOt6xO4VgK/O0fY3BE+jW20IAdl1qhRrNu692r68hdRLQo6seH3J/FDyp4YuDTyQd
         Z6TcT2mI2Hw7jVNRgCePpl7iGoQJMaW/eBF2kPU0cPBX+6RP1s4fPfsxUD3hmDMZTN3j
         sJ2qrwauWyxsIHe+DTSe1jVeSaLICuCQuIVY620CCjdgImYutpLeXR/m2Cnzi/s8frHJ
         2CqA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id i12si1850677pgq.466.2019.02.22.10.48.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 10:48:29 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Feb 2019 10:48:28 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,400,1544515200"; 
   d="scan'208";a="124469968"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by fmsmga007.fm.intel.com with ESMTP; 22 Feb 2019 10:48:28 -0800
Date: Fri, 22 Feb 2019 11:48:31 -0700
From: Keith Busch <keith.busch@intel.com>
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
	Linux Memory Management List <linux-mm@kvack.org>,
	Linux API <linux-api@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCHv6 07/10] acpi/hmat: Register processor domain to its
 memory
Message-ID: <20190222184831.GF10237@localhost.localdomain>
References: <20190214171017.9362-1-keith.busch@intel.com>
 <20190214171017.9362-8-keith.busch@intel.com>
 <CAJZ5v0gjv0DZvYMTPBLnUmMtu8=g0zFd4x-cpP11Kzv+6XCwUw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJZ5v0gjv0DZvYMTPBLnUmMtu8=g0zFd4x-cpP11Kzv+6XCwUw@mail.gmail.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 11:02:01PM +0100, Rafael J. Wysocki wrote:
> On Thu, Feb 14, 2019 at 6:10 PM Keith Busch <keith.busch@intel.com> wrote:
> >  config ACPI_HMAT
> >         bool "ACPI Heterogeneous Memory Attribute Table Support"
> >         depends on ACPI_NUMA
> > +       select HMEM_REPORTING
> 
> If you want to do this here, I'm not sure that defining HMEM_REPORTING
> as a user-selectable option is a good idea.  In particular, I don't
> really think that setting ACPI_HMAT without it makes a lot of sense.
> Apart from this, the patch looks reasonable to me.

I'm trying to implement based on the feedback, but I'm a little confused.

As I have it at the moment, HMEM_REPORTING is not user-prompted, so
another option needs to turn it on. I have ACPI_HMAT do that here.

So when you say it's a bad idea to make HMEM_REPORTING user selectable,
isn't it already not user selectable?

If I do it the other way around, that's going to make HMEM_REPORTING
complicated if a non-ACPI implementation wants to report HMEM
properties.

