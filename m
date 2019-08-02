Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98974C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 14:54:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D85421726
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 14:54:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="GkFK9XVP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D85421726
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 015BF6B0006; Fri,  2 Aug 2019 10:54:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F09CB6B0008; Fri,  2 Aug 2019 10:54:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E27D76B000A; Fri,  2 Aug 2019 10:54:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id C052B6B0006
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 10:54:27 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id p34so68197234qtp.1
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 07:54:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=vk3Gb7aOedlU4VZXPFZa0tWgmZW/7NAn18jQbzKBa/E=;
        b=Xb/Nsf/uy0FQayZJqMBvttahVAYhSzsdYj7JDwNv4pcPuRgtKoRg1AAX+kKYO3Miva
         QgjHKV+wmjJvTMdfIT/iD668EQvNuS5iPzY8C/J0tA0wd6ogs42Mnw6M2lwbEB1kIfRR
         CyCxL2w8/WKRFwf4XR2C/jfVpo4I0dmLVmP35Lom55zWQaJL8WDAefc4XZi5KJ9HNWNx
         z87AK9220Wht9MgMdMKfJ3EEHXNFMfo4iWp9l2FZvJ2BnNwdVQJJe8il+fugDbMHzp74
         EUHpKvkSWOyzjpvDoUevr4EdScyKgoV7bg0i1qGLC7SdTzu1i1EwB0bojcGINFjsfvOU
         urDg==
X-Gm-Message-State: APjAAAWyr264YyBrm83pYgn1qZBnGJzexHdEExy+kRNv9zfi0ykLvBSR
	KdwBbHs1IptUxXnYcDFeNDIVliM3ZObzwg6f2HGNNAHWuiVLnowVgUDuh4DBnh/9OYil7yuSQfh
	VTh9ypPHnQuiHxOkni1OVLmIO8X65vfoNog8fYbEm4HYms0Uhmdag5fW9b2BHMMI=
X-Received: by 2002:a37:b741:: with SMTP id h62mr91810862qkf.490.1564757667542;
        Fri, 02 Aug 2019 07:54:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpIe4VBCwXAN/LAYvOeOXfIRdxRjq1Fsw+Khy2RfQUQWSdYa0ZT8QlxXC3rPxVmyEtpiaX
X-Received: by 2002:a37:b741:: with SMTP id h62mr91810819qkf.490.1564757667072;
        Fri, 02 Aug 2019 07:54:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564757667; cv=none;
        d=google.com; s=arc-20160816;
        b=JMiI3M7Ddq7gYeLPwsLCnYFsdSzeVPEnDLnHVrYEb1bcltEL/8Ol2oheAQy9jmWXlj
         yJ1wtzUFubQgwLlDqiNDy55oUS89CE22EHplKFDD3XfbSDSRQZYLK2H2Ukoew4M0qBka
         aR1ppyzDiQ22MoW0HsbXuBqg4ivuBgs3RvbgSNeqKBdJsbYKn/wPn6Lf5dr7Kuri3n/f
         L2PEjjPJvrHacm/I8HpRks1qgoJsiaUOQJI3mRFCqZoT9s+USO61rjdIsUmCrCIxBZpM
         M8VVb0lVUAsPTSsvaVImu/zzaczbR4sII2zsmTy3ik5YHBtBBSZ5YibJgnwlNNKdfcpZ
         ZIBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=vk3Gb7aOedlU4VZXPFZa0tWgmZW/7NAn18jQbzKBa/E=;
        b=e1O+4mn0VQeed2I6rWWFLs4da18p+zNskOv49ojLDrNlt+DSDDnFyyR/3FQnqvIdRk
         Z/QVLUsiz0rIsvq1Mk6tKQLtmlvU0INBPRZZVGjpq2g/HR2/BCqyMoeqXa4yvgl6Ezn2
         Pu5Y5+leL+Y+wN/Iqe6fuKDC0aJ9vI3hqvVp0bvn4GR0CwoMxp6G+JKOxKu9ax+37Jz2
         NULXGO604GAOo1Iyg4ioZ/FYMu7zS3cHJzCIFYP2nPguQf0BZ2WMoUuckXfw/8b3Zpr0
         l0+DGGHztIC2sG3FYmpdEyCmWQl2fmQHF6UEdr7wnpPjOAh/ULB8LxrnHLvCyZhIENGB
         yPow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=GkFK9XVP;
       spf=pass (google.com: domain of 0100016c52d32b18-8593625f-bf32-4005-be04-79af900ac112-000000@amazonses.com designates 54.240.9.54 as permitted sender) smtp.mailfrom=0100016c52d32b18-8593625f-bf32-4005-be04-79af900ac112-000000@amazonses.com
Received: from a9-54.smtp-out.amazonses.com (a9-54.smtp-out.amazonses.com. [54.240.9.54])
        by mx.google.com with ESMTPS id p57si44520607qtc.217.2019.08.02.07.54.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 02 Aug 2019 07:54:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of 0100016c52d32b18-8593625f-bf32-4005-be04-79af900ac112-000000@amazonses.com designates 54.240.9.54 as permitted sender) client-ip=54.240.9.54;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw header.b=GkFK9XVP;
       spf=pass (google.com: domain of 0100016c52d32b18-8593625f-bf32-4005-be04-79af900ac112-000000@amazonses.com designates 54.240.9.54 as permitted sender) smtp.mailfrom=0100016c52d32b18-8593625f-bf32-4005-be04-79af900ac112-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=6gbrjpgwjskckoa6a5zn6fwqkn67xbtw; d=amazonses.com; t=1564757666;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=z+KAYvssR654xT1PJmIJ3CS5+fx3UQzQRMe7cbSlSqs=;
	b=GkFK9XVPajmUrXiNorqYyeXjnb5kxq4Cb7xBG5EVT9qDBnmqPCxH/Q4RMGLw6oDT
	woH5I+acrCTkrFsP9K97B+S3gYciANlTIcTOKxu6QVxVDhvsvig0tH2wb9qGN7pVOWQ
	v11bHmqsvgx+cmakvLlTN7O9cMKuaG6z3jCKUZYw=
Date: Fri, 2 Aug 2019 14:54:26 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Matthew Wilcox <willy@infradead.org>
cc: linux-fsdevel@vger.kernel.org, hch@lst.de, linux-xfs@vger.kernel.org, 
    linux-mm@kvack.org
Subject: Re: [RFC 0/2] iomap & xfs support for large pages
In-Reply-To: <20190731171734.21601-1-willy@infradead.org>
Message-ID: <0100016c52d32b18-8593625f-bf32-4005-be04-79af900ac112-000000@email.amazonses.com>
References: <20190731171734.21601-1-willy@infradead.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-SES-Outgoing: 2019.08.02-54.240.9.54
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 Jul 2019, Matthew Wilcox wrote:

> Christoph sent me a patch a few months ago called "XFS THP wip".
> I've redone it based on current linus tree, plus the page_size() /
> compound_nr() / page_shift() patches currently found in -mm.  I fixed
> the logic bugs that I noticed in his patch and may have introduced some
> of my own.  I have only compile tested this code.

Some references here to patches from a long time ago. Maybe there are
useful tidbits here ...

Variable page cache just for ramfs:
https://lkml.org/lkml/2007/4/19/261

Large blocksize support for XFS, ReiserFS and ext2
https://www.mail-archive.com/linux-fsdevel@vger.kernel.org/msg08730.html

