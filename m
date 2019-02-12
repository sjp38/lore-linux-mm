Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 361E3C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 23:51:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EEE5D20869
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 23:51:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EEE5D20869
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 64B5D8E0002; Tue, 12 Feb 2019 18:51:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5F9C28E0001; Tue, 12 Feb 2019 18:51:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50F3D8E0002; Tue, 12 Feb 2019 18:51:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1118B8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 18:51:19 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id q21so394841pfi.17
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 15:51:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=QC+C0WBYYC4ZbmCxW12ZtFAete4SFboPdMyrEyYhC0c=;
        b=gsa3pKS4mc7wt8sjVTyIVVKM7ZF3NSISr0A8jMFHwkSF72U242pd2Jvo8Vsq6TZf/s
         4YDDEUURjiGD13x/3BpR0bSHH/2idg37VmniwdX6MEP/zIO88aFqRlDFTccFoXZEaB12
         e3hkapJpp2RGRrP/zb/VjqnzeyGT2mrO9oLgnbLtcD0zLBl3khakn0QMtbwC86tlBwIK
         BTYC7TcklXVvl4SnUvAAtuU7s2x7qhzAukAwTCjlboTKTBjLXreHL9EF+wBaKwzdRpT3
         sTon2f6DrtSYPgAXfrKwzFPEKpLOnhjTaYPSoAv9uZC6kfBWJ5Ebz9ZU2+8164BFUqtU
         ZGbw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAuZjB96UmNIfrsxW5dtAVbZ64XlQe7Ka8r6vpqKO5QvDfX8JYHMX
	27JN08CmvjCapegjplL059XVs5hz+gFNvJ1FJFp9Qm14VUwc8rJdV1zv+kIZAiXn1bl+K+wc8zr
	0kHk90k4/6BbjC7qTVelEXVS5OXJuH7aB2TcV4j/M/BB/VWWASB1xsOOtJqVPnTI=
X-Received: by 2002:a65:4383:: with SMTP id m3mr5734960pgp.96.1550015478708;
        Tue, 12 Feb 2019 15:51:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaPM+VJXE7pMWMj0LvT5zC0u0Ha757uqhPXvH1C6DH0bqHv0xMNlGYqQeX9VNl5ZEigkq/S
X-Received: by 2002:a65:4383:: with SMTP id m3mr5734920pgp.96.1550015477916;
        Tue, 12 Feb 2019 15:51:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550015477; cv=none;
        d=google.com; s=arc-20160816;
        b=rf53Tg4jbl8+/NUNucoWse6Im4v80XeH2qMr4kQP3sbBpE9W0pgRbXkxw7iEGJ9+v3
         4uIXCIAoQOzFTrcdzxMD39QU1iJIqgOCj6NvcnKkdP7MB0CEbNuZ2V9+MW0DxO/uNxEf
         ZpOK/2K9uL2ewSbi/Zeoct1ojHrD27atwqbROfen38VqunTaOVHh3bQK4Irg9gpU2cNE
         cz9ngoKMNs4Rw9I8dfQ2vQ3kSs3B5R+NHbL7em08LNhfRKr7yAH59CtpCzn7blYZ3QOZ
         uCvycmiqH5JzTp5ODx31S0Pmh+iOxp3VHVg0t1AAfDXoU4ZcIcHl/TTxRqV1l2N/xYye
         PSow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=QC+C0WBYYC4ZbmCxW12ZtFAete4SFboPdMyrEyYhC0c=;
        b=WznxSaSuPkVBHLFrLKZnUZIw1ZKu3b5JT4fmFX7/ktnF4kUJImY1oTaJwujEgiy5lG
         ZbyZK8w68Pv/S26xdqK2Epnxdj4PhaefzSP/Wd0Ugxve2rESFlbyuz8MkObH27KjwF7f
         IBzzbppPKBAqaP0p1Ifmb4NFxGsTg++K3BKthTovdfHooRl59/YmUtODMtuqEzCfofr7
         OIFVEBFzYYCUbCaxZdTST10BKFXy7zp9xQM5fAvOSN1Ly4c+hOxBSo8px5+82+tN9V2K
         AnX5R6TbCnsYUTk2vhdm9M+v7BDA500IpvczR4RGdfjDgOuZCtx+Hc0FFQ0HbLqQfSmG
         HAEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id l67si14530912pfc.147.2019.02.12.15.51.16
        for <linux-mm@kvack.org>;
        Tue, 12 Feb 2019 15:51:17 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.131;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail07.adl2.internode.on.net with ESMTP; 13 Feb 2019 10:21:16 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gthpa-0003sF-Pw; Wed, 13 Feb 2019 10:51:14 +1100
Date: Wed, 13 Feb 2019 10:51:14 +1100
From: Dave Chinner <david@fromorbit.com>
To: Dave Hansen <dave.hansen@intel.com>
Cc: lsf-pc@lists.linux-foundation.org,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>,
	"Williams, Dan J" <dan.j.williams@intel.com>,
	"Shutemov, Kirill" <kirill.shutemov@intel.com>,
	"Schofield, Alison" <alison.schofield@intel.com>,
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>
Subject: Re: [LSF/MM TOPIC] Memory Encryption on top of filesystems
Message-ID: <20190212235114.GM20493@dastard>
References: <788d7050-f6bb-b984-69d9-504056e6c5a6@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <788d7050-f6bb-b984-69d9-504056e6c5a6@intel.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 08:55:57AM -0800, Dave Hansen wrote:
> Multi-Key Total Memory Encryption (MKTME) [1] is feature of a memory
> controller that allows memory to be selectively encrypted with
> user-controlled key, in hardware, at a very low runtime cost.  However,
> it is implemented using AES-XTS which encrypts each block with a key
> that is generated based on the physical address of the data being
> encrypted.  This has nice security properties, making some replay and
> substitution attacks harder, but it means that encrypted data can not be
> naively relocated.

The subject is "Memory Encryption on top of filesystems", but really
what you are talking about is "physical memory encryption /below/
filesystems".

i.e. it's encryption of the physical storage the filesystem manages,
not encryption within the fileystem (like fscrypt) or or user data
on top of the filesystem (ecryptfs or userspace).

> Combined with persistent memory, MKTME allows data to be unlocked at the
> device (DIMM or namespace) level, but left encrypted until it actually
> needs to be used.

This sounds more like full disk encryption (either in the IO
path software by dm-crypt or in hardware itself), where the contents
are decrypted/encrypted in the IO path as the data is moved between
physical storage and the filesystem's memory (page/buffer caches).

Is there any finer granularity than a DIMM or pmem namespace for
specifying encrypted regions? Note that filesystems are not aware of
the physical layout of the memory address space (i.e. what DIMM
corresponds to which sector in the block device), so DIMM-level
granularity doesn't seem particularly useful right now....

Also, how many different hardware encryption keys are available for
use, and how many separate memory regions can a single key have
associated with it?

> However, if encrypted data were placed on a
> filesystem, it might be in its encrypted state for long periods of time
> and could not be moved by the filesystem during that time.

I'm not sure what you mean by "if encrypted data were placed on a
filesystem", given that the memory encryption is transparent to the
filesystem (i.e. happens in the memory controller on it's way
to/from the physical storage).

> The “easy” solution to this is to just require that the encryption key
> be present and programmed into the memory controller before data is
> moved.  However, this means that filesystems would need to know when a
> given block has been encrypted and can not be moved.

I'm missing something here - how does the filesystem even get
mounted if we haven't unlocked the device the filesystem is stored
on? i.e. we need to unlock the entire memory region containing the
filesystem so it can read and write it's metadata (which can be
randomly spread all over the block device).

And if we have to do that to mount the filesystem, then aren't we
also unlocking all the same memory regions that contain user data
and hence they can be moved?

At what point do we end up with a filesystem mounted and trying to
access a locked memory region?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

