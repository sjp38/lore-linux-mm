Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44D35C43218
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:19:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B509216C4
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:19:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B509216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mit.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E7D76B0003; Thu, 25 Apr 2019 17:19:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8971C6B0005; Thu, 25 Apr 2019 17:19:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7ADC76B0006; Thu, 25 Apr 2019 17:19:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5A8316B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:19:09 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id k68so1058516qkd.21
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 14:19:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mail-followup-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=gSOmHk+U2B3PSxyZO0MOHoW4FxKQXl6sFg88f2pStmg=;
        b=lUAqjY7KT2xfMBUFMbFSw9hCrWmK2gyBejg418uslTCm18CM7gxFitQDIurAUWK37A
         LuHqeVCoDITUfLKa5Y12jn/uFowrYKxzosUM5S2r6sHH1UdPoQ2fkKoOpwrxRUM2wuqA
         BWIDtmw1DwuoU/btRxsII38nzKhjp0M50iIf72hBbsqrYHtVdVofNLQFm1AVVvzIEZrS
         d8lfi3ONFVlqqWj0l8y6R05o1Mz1U2v1B+BU5zQzvgpNXYfTjOk3MVvnVCclX7EvjzRG
         348gQx/tRKTvNIeiryIu9OHsulYyAXMRGSiatWZoxjiX9P9Gkvv4csD1hcTxc0Zy5/09
         w8XQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
X-Gm-Message-State: APjAAAX49rVm1G4eMEnfcwDWLk5LLDg/g5SUtoku4f6tlc+3mpnEEQjz
	ylearonLJadWqAQbKW9Dvv9ZyT21TgWjZYJ68dbUaNRLJ9xLT5t2L8sVHof4k/X/PEw2BH4GkMj
	0OY6ZpeGSMBkW+MEMTRt2yIX+pCOdQgxnzsBDnBoq3SuhG2vzYIQJskVW/+E60GUTzw==
X-Received: by 2002:ac8:3567:: with SMTP id z36mr13869065qtb.59.1556227149156;
        Thu, 25 Apr 2019 14:19:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZ1PT52VKYLRaxwdFNuqyD4lvdqQL0O79IVT5ZMV+ieOnSkJtDXg/Sm0DXKN/RYGCL9Lzu
X-Received: by 2002:ac8:3567:: with SMTP id z36mr13869024qtb.59.1556227148509;
        Thu, 25 Apr 2019 14:19:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556227148; cv=none;
        d=google.com; s=arc-20160816;
        b=f41OZncWx/BAP9RrptTvcWjNdtlzRxYv6b+8caPtqp4hoFqtEv1biSFoLMFj3Iy7Ka
         DKnDohfQ3g8w5HRP25q+xAcJwST0t8OrkQN4bikFzjDhTgL9ZtgchNJmSc6GUH4c5RFd
         4N7bLkGgj0UOBVUWxRW/KemGGKg6HqSAnNY1cDO8IBjiAhTTwJlHbH0xJozIZxdyPFI8
         uVKSQPHWunbkLZXlX01gbxt4XxmCqt7rr9pMXpduDCjJGjQ+TFIf5C5Fv5mxlcMB3CsG
         oxHeEIJ/VRtGvJJJJdSpfulBQ5SVRWFfH1vzVxzK28Gjwk7pVJ1xWYgWsp078RH/GcxU
         zXVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :mail-followup-to:message-id:subject:cc:to:from:date;
        bh=gSOmHk+U2B3PSxyZO0MOHoW4FxKQXl6sFg88f2pStmg=;
        b=EnkzeIaK1xfd+gOkLkVtdHHRomYWTCjoeByUoPSs/4H2MsujcdfvAM4AUgVPT+hNji
         YNdHBaeiRHzvCiafYqyxoc8dwUGII9Iva1w5PBqUcrEFnjyZxCMZV8WiUTJd61S5CDow
         YPp5pngdEHf+5CYBYFjLgMt78ncYkEiJ/4yAaSc5YJukRMt88P7AAlhpwwieeMy5DAJI
         f81cO+tjTS5Lbbry0/3NW92RCorD1pOo2Uts/aaxOTnsY9WTOigkXmTVqF//jEB08251
         oLeDWgV5gOXCS/90AVToyF/EwaZVX3hzORObgkER+3nekLpNb7LInJ3qFY+cXhjDGK1g
         vBPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from outgoing.mit.edu (outgoing-auth-1.mit.edu. [18.9.28.11])
        by mx.google.com with ESMTPS id p5si96786qti.168.2019.04.25.14.19.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 14:19:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) client-ip=18.9.28.11;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from callcc.thunk.org (guestnat-104-133-0-109.corp.google.com [104.133.0.109] (may be forged))
	(authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id x3PLJ6g3014498
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Thu, 25 Apr 2019 17:19:07 -0400
Received: by callcc.thunk.org (Postfix, from userid 15806)
	id 442D7420EEC; Thu, 25 Apr 2019 17:19:06 -0400 (EDT)
Date: Thu, 25 Apr 2019 17:19:06 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
To: Jens Axboe <axboe@kernel.dk>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [LSF/MM TOPIC] Lightning round?
Message-ID: <20190425211906.GH4739@mit.edu>
Mail-Followup-To: Theodore Ts'o <tytso@mit.edu>,
	Jens Axboe <axboe@kernel.dk>, lsf-pc@lists.linux-foundation.org,
	linux-mm@kvack.org, linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org
References: <20190425200012.GA6391@redhat.com>
 <83fda245-849a-70cc-dde0-5c451938ee97@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <83fda245-849a-70cc-dde0-5c451938ee97@kernel.dk>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 25, 2019 at 02:03:34PM -0600, Jens Axboe wrote:
> 
> which also includes a link to the schedule. Here it is:
> 
> https://docs.google.com/spreadsheets/d/1Z1pDL-XeUT1ZwMWrBL8T8q3vtSqZpLPgF3Bzu_jejfk

It looks like there are still quite a few open slots on Thursday?
Could we perhaps schedule a session for lightning talks?

I've got at least one thing that I'm hoping to be able to plug as a
lightning round topic.  Folks may remember that a year or two ago I
had given an LSF/MM talk about changes to the block layer to support
inline encryption engines[1] (where the data gets encrypted/decrypted
between the DMA engine and the storage device, typically EMCC/UFS
flash).

[1]  https://marc.info/?l=linux-fsdevel&m=148190956210784&w=2

Between the Android team really trying to get aligned with upstream,
and multiple SOC vendors interested in providing inline encryption
support in hardware, we (finally) have a few engineers who have been
on implementing this design for the past few months.  If all goes
well, hopefully RFC patches will be published on linux-block,
linux-fsdevel, and linux-fscrypto by early next week.  Assuming this
happens on schedule, it would be perfect for a lightning talk, with
the goal of commending this patch series for feedback.

						- Ted

