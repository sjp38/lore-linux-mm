Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78475C04AA9
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 17:34:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2246520651
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 17:34:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="hp6CAJKt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2246520651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9EF4B6B0003; Thu,  2 May 2019 13:34:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 979396B0006; Thu,  2 May 2019 13:34:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 818E36B0007; Thu,  2 May 2019 13:34:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 464C16B0003
	for <linux-mm@kvack.org>; Thu,  2 May 2019 13:34:28 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c12so1606375pfb.2
        for <linux-mm@kvack.org>; Thu, 02 May 2019 10:34:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=k1Mng5fkxG2kqXsRSaQDBN/3qrjtIBnMdTR42nRFITQ=;
        b=tJNL4OXKJSIW4z1mtv4TkwTA9MPSGZBFkNN/ZnJYB811dEPAfuMsyEIZZ33crm7/8H
         YOu6kxpZc0VoAUEWigBVOtbAm9MU9Yj9yNuTGkIEt8D14AvVX3TWyHGyuagy0qGeW3P0
         OPxx3s/xRiuHgjTWFh40wKlYSDIAktzN86PJwmXrWyQttMBEFWOurB5fWFYkuhAuCbbI
         cVupOpzmTo0lNEv+gAUDe4O6A/TAVC0hm1c7I0/Yxh8vH/Zlq7ufi/pyilG3tBKH2GQk
         RXCE1CJ5vM4ewS350d2EEmd6f0e41RA+JHi7LizOnr0xz4qZw1F8ZaI8smAyjMZkocfC
         Vjkg==
X-Gm-Message-State: APjAAAWxx8e/4doTMP/T+HYuEOhfcFgTuTtyUuFleR7W7tdTcKBlAGeT
	nnNHflMPnbi9pG2u8tVIr2C9bsTfd15usK6H4U/X72eOHM4CKomNeuvEKQo1gR6pr78xBK5e3rn
	OHxfbrMme2kKIxlZZCPXQTnPrTSbQ3NbI6wPxGdoD5JqdltsE85BfwVSLmGoQyUqjPA==
X-Received: by 2002:a65:644e:: with SMTP id s14mr5376111pgv.290.1556818467801;
        Thu, 02 May 2019 10:34:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyO7vV4sSR4Fg8aLOuBITNP9J9cVxuRbSGW2LaHXIFIcJTYnkqd8xVZAdq9hWJSVCjseJH3
X-Received: by 2002:a65:644e:: with SMTP id s14mr5376013pgv.290.1556818466635;
        Thu, 02 May 2019 10:34:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556818466; cv=none;
        d=google.com; s=arc-20160816;
        b=rO54FMNC+tkDB28BYURJvrHR8KzDS1tF+PYmpKkzE9W2dKULxryWZ/vpKsXnCJSgB6
         RY0mwYDpJVn7ki6uSqPC86CC7ymvcCjokmWvYEVywhHte5cQTaJYIqNJ5EzTY8RsVqcj
         /FtSrXRDBXJbWVZz3M/mjbxOYAQayfN1OggleH9kce7E9uDLIQc9P/+fbv61f3Bpw88u
         iiU4Bk063YAIM8TtQMhn3nzni3GbcNW/3f/wRysfA01Z+AB5YaUQZ/HvvS9RSZmigyBo
         spNOYC4CAjdjMi7xl9cT/nD4Kj2t0czeK7gCMGdEch6gRvzOQjpZqzMv/dYVGqRJv94g
         FN8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=k1Mng5fkxG2kqXsRSaQDBN/3qrjtIBnMdTR42nRFITQ=;
        b=jqO1hjs6aiN92WNUad30GWfIAYuMc7LOk7m7nQI9CmDcL7qLknJ8XknWd9zIhoWh4m
         /N1ztXmHwN+wHXhNuq+3xuDZZwg4Z91wtG/sUQU8/KUKYFAtw3CVYztQM2HJAxMbWMf8
         k7xUHQ4umNsp7cG9XA2KwuJdu+/pCYexXU3aTPZB3g14l/gpEkpHRgbGr1mzf0Im1dru
         6kN+P159Zeh4cTUjZf6Avp/dhyMYshlh2BSBwY60c+veEquieqPDtYV+7JszAkKHik5A
         kBDpHSmp1kMnlFZa1xPGrs2K+yW6fwRonvYdqHqsfvIlNPeDkDltgmG3lj7tgwgZ8QkH
         G30A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=hp6CAJKt;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p2si28021813pls.31.2019.05.02.10.34.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 10:34:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=hp6CAJKt;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (adsl-173-228-226-134.prtc.net [173.228.226.134])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C09C5205F4;
	Thu,  2 May 2019 17:34:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556818466;
	bh=k1Mng5fkxG2kqXsRSaQDBN/3qrjtIBnMdTR42nRFITQ=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=hp6CAJKtym6IoN734hnJoB9bKolzpSd0R7qRYpUjsgNKYsINuqSetNrT1/y1xcNaN
	 6xMHqCPis63NBoZhcvCRXmKfvQQYWd1l/DP9A5DA3xV1FqO6dXcr1bM8eS8DJT8DaH
	 JFX5NmJuqQJsTHn1vYCIS0QS8K+KpZZYBJoG9Pjs=
Date: Thu, 2 May 2019 13:34:19 -0400
From: Sasha Levin <sashal@kernel.org>
To: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: jmorris@namei.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-nvdimm@lists.01.org, akpm@linux-foundation.org,
	mhocko@suse.com, dave.hansen@linux.intel.com,
	dan.j.williams@intel.com, keith.busch@intel.com,
	vishal.l.verma@intel.com, dave.jiang@intel.com, zwisler@kernel.org,
	thomas.lendacky@amd.com, ying.huang@intel.com,
	fengguang.wu@intel.com, bp@suse.de, bhelgaas@google.com,
	baiyaowei@cmss.chinamobile.com, tiwai@suse.de, jglisse@redhat.com,
	david@redhat.com
Subject: Re: [v4 2/2] device-dax: "Hotremove" persistent memory that is used
 like normal RAM
Message-ID: <20190502173419.GA3048@sasha-vm>
References: <20190501191846.12634-1-pasha.tatashin@soleen.com>
 <20190501191846.12634-3-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190501191846.12634-3-pasha.tatashin@soleen.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 01, 2019 at 03:18:46PM -0400, Pavel Tatashin wrote:
>It is now allowed to use persistent memory like a regular RAM, but
>currently there is no way to remove this memory until machine is
>rebooted.
>
>This work expands the functionality to also allows hotremoving
>previously hotplugged persistent memory, and recover the device for use
>for other purposes.
>
>To hotremove persistent memory, the management software must first
>offline all memory blocks of dax region, and than unbind it from
>device-dax/kmem driver. So, operations should look like this:
>
>echo offline > echo offline > /sys/devices/system/memory/memoryN/state

This looks wrong :)

--
Thanks,
Sasha

