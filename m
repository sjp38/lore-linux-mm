Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AE3EC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:33:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C490218C3
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 08:33:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C490218C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7EDAF8E0002; Mon, 18 Feb 2019 03:33:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 79D398E0001; Mon, 18 Feb 2019 03:33:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 666588E0002; Mon, 18 Feb 2019 03:33:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 103718E0001
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 03:33:35 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d9so6843419edh.4
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 00:33:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:mime-version:content-disposition:user-agent;
        bh=2x2uVSKbs7bv8AzY1Zn0j2YCvSB0eTISBd5h4Iyqe2w=;
        b=StIRzJn5eJLa/f9I/HWyNEjppv3D+9z7bM5n6IUvSLV6fBMnn4mELW6B2d38H20pxZ
         EZkikTOnTOGbgPh5EPqVSx4b5LR7KiX/sYCuTIBk9lEWLwJBVfVQnnMoCGJ92L+0J+GO
         oZ/f+blbON0+mn3z+kShkXGOPDxXP4sf/hIOblonOcc1zrEhVYu216DfvRQzJSxFNo9o
         BaqIZcs0k0PXBU6e9RM8IhtXcCDuWYt31H0xvaoO1rXLNifs7I4YCuqBiCM28aIhaGU9
         RITqRA17PDECchNO5dEjH+4zcdrPZiQQ4HF6LjSHPisH+SKd9QVJzM4yYktJHJXoAJR/
         XcbA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: AHQUAubtGiZYIkdh9yaGLwWEhgioRRUmlexB6IKtltoSGiVPtJfXvPyN
	qBMsFU83pmYHacPKS2iG4kY27t3Q0Z1GCj37ld7SLf0oLVjyUJMvaMtzGie2GENfEZvwUlw3zA+
	feDDKghfRQmmZytKR+iQX27m2RmS7YQjxZYTZOyVsCA0gVQB5di4GC5h/EaymiNHvlw==
X-Received: by 2002:a17:906:64d9:: with SMTP id p25mr15739598ejn.90.1550478814535;
        Mon, 18 Feb 2019 00:33:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3IakVVuPVk1GLnaYBpDUmeQmWU68/yQrgyIpoSp4UBi0vTKQ54x8ZhWZDzMiDjRFwpq5M7ts
X-Received: by 2002:a17:906:64d9:: with SMTP id p25mr15739555ejn.90.1550478813411;
        Mon, 18 Feb 2019 00:33:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550478813; cv=none;
        d=google.com; s=arc-20160816;
        b=fetGLdGssD7o4v24Glpjh06FzHeJ7lhAdkgjf6pr+Um3RREYEzURZqwy5sd6+OJmwn
         jdxf1H1qBku3WBK5gODQcZewI6q0exY2twh0uJ0NgPJx6ehbWQq0cNRptVgGg7fzq5xk
         tlRUM6Zeqxf3pRFZX7z9uqjp3XuV2/Yi9UR9n9ZFzZS/kKGGjjWAnbZRTZoivw8uSEUE
         aZhiuQRiQk+8pNjlLjxvFyFuOjzaVDndDRT13hhcQh5ZM1SW8EzbeSSL//NmgvEYNj+k
         Um0B98of8tIzRqGVwgpgkNmbRJrG6mfCTE1W/nHUW4OXQjZfkTs0brG8bmUs/vCiMKwL
         rJNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date;
        bh=2x2uVSKbs7bv8AzY1Zn0j2YCvSB0eTISBd5h4Iyqe2w=;
        b=O5+noD3FtmASGSU+R4PiDYgeacRg5qdL/KTp8K3ZNljOkxD6t0Vk6w4mHjJpZ9p74m
         pLFbhlCfTjoV9N/J4XEAUn8A1NB7IAcX1JGqsjma7FPtuYyP2RQ7BTEF9vIIVkbdRaKQ
         1MlQ9iUNxjg+MRJBzjbHLEbe1FFlkyST3+elJpbpx9CRbvKnNKBSZ0qns/ETJkt92Wo0
         6avDVL5Hxr9IoJLpH7MF8IBohBn1u4HJdpaqLGVy8O+dOOnFnmHFwuQ9eVDA8Nn291b6
         GWTHc0KwaR/+sC0ExEzLijAAc1csuotA0P6iNhURPb4vmHU5is0YSPxKywsY3Am5x/Ps
         b81w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (charybdis-ext.suse.de. [195.135.221.2])
        by mx.google.com with ESMTP id a13si1758397eds.214.2019.02.18.00.33.33
        for <linux-mm@kvack.org>;
        Mon, 18 Feb 2019 00:33:33 -0800 (PST)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 46E2C42F1; Mon, 18 Feb 2019 09:33:32 +0100 (CET)
Date: Mon, 18 Feb 2019 09:33:31 +0100
From: Oscar Salvador <osalvador@suse.de>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org
Cc: hughd@google.com, viro@zeniv.linux.org.uk,
	torvalds@linux-foundation.org
Subject: mremap vs sysctl_max_map_count
Message-ID: <20190218083326.xsnx7cx2lxurbmux@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Hi all,

I would like to bring up a topic that comes from an issue a customer of ours
is facing with the mremap syscall + hitting the max_map_count threshold:

When passing the MREMAP_FIXED flag, mremap() calls mremap_to() which does the
following:

1) it unmaps the region where we want to put the new map:
   (new_addr, new_addr + new_len] [1]
2) IFF old_len > new_len, it unmaps the region:
   (old_addr + new_len, (old_addr + new_len) + (old_len - new_len)] [2]

Now, having gone through steps 1) and 2), we eventually call move_vma() to do
the actual move.

move_vma() checks if we are at least 4 maps below max_map_count, otherwise
it bails out with -ENOMEM [3].
The problem is that we might have already unmapped the vma's in steps 1) and 2),
so it is not possible for userspace to figure out the state of the vma's after
it gets -ENOMEM.

- Did new_addr got unmaped?
- Did part of the old_addr got unmaped?

Because of that, it gets tricky for userspace to clean up properly on error
path.

While it is true that we can return -ENOMEM for more reasons
(e.g: see vma_to_resize()->may_expand_vm()), I think that we might be able to
pre-compute the number of maps that we are going add/release during the first
two do_munmaps(), and check whether we are 4 maps below the threshold
(as move_vma() does).
Should not be the case, we can bail out early before we unmap anything, so we
make sure the vma's are left untouched in case we are going to be short of maps.

I am not sure if that is realistically doable, or there are limitations
I overlooked, or we simply do not want to do that.

Before investing more time and giving it a shoot, I just wanted to bring
this upstream to get feedback on this matter.

Thanks

[1] https://github.com/torvalds/linux/blob/master/mm/mremap.c#L519
[2] https://github.com/torvalds/linux/blob/master/mm/mremap.c#L523
[3] https://github.com/torvalds/linux/blob/master/mm/mremap.c#L338

-- 
Oscar Salvador
SUSE L3

