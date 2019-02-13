Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03194C0044B
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 20:21:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1FB021872
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 20:21:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1FB021872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 483B28E0002; Wed, 13 Feb 2019 15:21:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 432CD8E0001; Wed, 13 Feb 2019 15:21:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 323E18E0002; Wed, 13 Feb 2019 15:21:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E490C8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 15:21:51 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id b15so2779257pfi.6
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 12:21:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=cWG2KB/3pqybigvDBq/fYl752/5qEiuxKu8Qj0Lhryk=;
        b=RXBCxgJEwlHBxFU5bloUMHhe76hovPi3SnakxKcDdOyiR00YxPfbz0eUDmeFpqoBS7
         7G6PukprGM5wIM1WNS4R+IfFms9LneM6QekwOjh19A2vE/jpUJovQJqQzvHqKzo9F6MW
         nwUnM8K+JbzMeb1JKZOXZJ9DvN73hZUBZZPZvHXdYmA2uHcGItTXru1xnYmpV7Tmx1F2
         O8GLfVgVYNRgd1BSinF82pieFxvuzxDqlojFDMJPeq+zW3W08EptSzXsasmemHTeXfkG
         nRa6HDdN096V8u+NRN9Jo9nue48JboITVJVJ0S660e4A4zpEBXK/GgkaJ8jinGgYjj5w
         ajWA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
X-Gm-Message-State: AHQUAuY4mZQULlFt9Eby+rpNw2vmVnpZfwrN8rA/ub6Ji66eoGdCsmwF
	FaU6bwd7G1t7177odvojb2uj3Mm4uPG62Ee8FlRB4XuWHtZkaEYxCUqc0ayqN0uuTrjOnj2rFI2
	IBh9QlxLxB8nFwq9yGz4AKuKKiS6QTpg2p4KF8TU0ynkH5yYTxuuHUB/PEtTYgPE=
X-Received: by 2002:aa7:8497:: with SMTP id u23mr2230145pfn.253.1550089311592;
        Wed, 13 Feb 2019 12:21:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY2/yvMgLELBcpL+HZvvGeUJS5Rg/MHrmseFOk1I1Pm4sGm8w1Wt5m654nq3lbdHykNlCLF
X-Received: by 2002:aa7:8497:: with SMTP id u23mr2230096pfn.253.1550089310921;
        Wed, 13 Feb 2019 12:21:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550089310; cv=none;
        d=google.com; s=arc-20160816;
        b=tzD3rXkqvhtAlKiv+hXRFWt2W0M0BzVfFvVA8LL9ct6dtmgqsTMPFErGM2HZ+SyN2a
         NrZ8BLtJP7nLUT1nE87yGlR38EHCjKaauaDLdoW7+Do6RCXLvkLk1F+QFlp9IFRrhsPk
         pZMynXZSZ9uXm97U8ZVCpQ03yKWDY/CdTKAcCIocG3OveXw5LUKYgjf7SbC4CcH42Y98
         CVlzREg7llDoPaabeeBvSb/uUZ0fyiJhvyPAUb8LEKZAXlvoS74LTwYr98xLQKBGdaBx
         /MocgyGTneVgPrhknh1D1pOVBj5+c+xapvM+0u0B7vK/+56Wn61p0oGQWbcW4b4+G7jU
         yrVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=cWG2KB/3pqybigvDBq/fYl752/5qEiuxKu8Qj0Lhryk=;
        b=yCryoCTUxtNg+ck2OVc6Sm/6WWYgcRYdivAM2WUydsMWwr72ADQjM88Hw5FcOTq6JJ
         tYWl577sHzmNWinUNJZ1OeIcL9xZbvqPo1fbSBH05wuMAdS9gKUYyyUUAikqINvv0q2M
         1F4QdtuqweBbJ4UhbLqtFHvbsdOSoSWikPhvMy0SmpjAIANKjoKVEOmiVrHSimRTF5ze
         81MWkJWC3XmSWrDGth3VP6fW0hu/9xIM2Ak+pOlviz+REyvMDIHDVWWnrN6WrE//DAMv
         /nk0hvn0fmqoGQOcNf0ONeMxYJMfImBDMJcm9fqlB3DZNrcdElpprrFaNqMr4W34WlrV
         GDgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id w2si192001pgp.546.2019.02.13.12.21.49
        for <linux-mm@kvack.org>;
        Wed, 13 Feb 2019 12:21:50 -0800 (PST)
Received-SPF: neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) client-ip=150.101.137.131;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 150.101.137.131 is neither permitted nor denied by best guess record for domain of david@fromorbit.com) smtp.mailfrom=david@fromorbit.com
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail07.adl2.internode.on.net with ESMTP; 14 Feb 2019 06:51:49 +1030
Received: from dave by dastard with local (Exim 4.80)
	(envelope-from <david@fromorbit.com>)
	id 1gu12R-00055k-Cg; Thu, 14 Feb 2019 07:21:47 +1100
Date: Thu, 14 Feb 2019 07:21:47 +1100
From: Dave Chinner <david@fromorbit.com>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>,
	lsf-pc@lists.linux-foundation.org,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Linux-MM <linux-mm@kvack.org>,
	"Shutemov, Kirill" <kirill.shutemov@intel.com>,
	"Schofield, Alison" <alison.schofield@intel.com>,
	"Darrick J. Wong" <darrick.wong@oracle.com>,
	Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>,
	Theodore Ts'o <tytso@mit.edu>, Jaegeuk Kim <jaegeuk@kernel.org>
Subject: Re: [LSF/MM TOPIC] Memory Encryption on top of filesystems
Message-ID: <20190213202147.GP20493@dastard>
References: <788d7050-f6bb-b984-69d9-504056e6c5a6@intel.com>
 <20190212235114.GM20493@dastard>
 <CAPcyv4jhbYfrdTOyh90-u-gEUV7QEgF_HrNid5w5WbPPGr=axw@mail.gmail.com>
 <20190213021318.GN20493@dastard>
 <CAPcyv4g4vF84Ufrdv8ocwfW3hrvUJ_GaF65AbZyXzaZJQVMjEw@mail.gmail.com>
 <a9b9af61-d4cb-46c2-8e98-256565dcf389@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a9b9af61-d4cb-46c2-8e98-256565dcf389@intel.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 07:51:12AM -0800, Dave Hansen wrote:
> On 2/12/19 7:31 PM, Dan Williams wrote:
> > Thanks, yes, fscrypt needs a closer look. As far I can see at a quick
> > glance fscrypt has the same physical block inputs for the encryption
> > algorithm as MKTME so it seems it could be crafted as a drop in
> > accelerator for fscrypt for pmem block devices.
> 
> One bummer is that we have the platform tweak offsets to worry about.

What's a "platform tweak offset"?

> As far as I know, those are opaque to software and practically prevent
> us from replicating the MKTME hardware's encryption/decryption in software.

We're not trying to replicate the encryption in software, just use
the existing software to manage the keys that get fed to the
hardware so it can do the encrypt/decrypt operations as the data
passes through it.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

