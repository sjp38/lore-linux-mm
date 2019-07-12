Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14552C742A1
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 01:04:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3E962084B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 01:04:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="eIqKhpRe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3E962084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61DBF8E010A; Thu, 11 Jul 2019 21:04:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A6F38E00DB; Thu, 11 Jul 2019 21:04:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46E918E010A; Thu, 11 Jul 2019 21:04:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0926E8E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 21:04:20 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id t19so4665251pgh.6
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 18:04:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=riDzNQoeHsr/F1rbB9LpQ2Ps7FxNjb3tAQENVw8Ghy8=;
        b=KBnmxP/nmm3CCTyFX3kWQ1T6iXrXEnOB50aUALn8d2ecwMz8a/gBe69ObPgJjWYpJ/
         XQgxkix4e9KeEf5gnACV56F88UWexL32d7mflshkCc94QSxBHlD5KfgYclkquN7OP5/o
         4hIGzkaG2xX8E0ONd0J/lrWcpkXCu4zKEoeMBAHbVCjBFU7Ph+eyWalXxZQ2XxMD4wmT
         mkfWQ1GusR4T+cI2heNbV7W0NmqIhq1qobq3DNU3WilmdbbX/bKyoXR0ahEuHxyzzyEb
         viukbzGQbv5bFA1ax0PaQz+b1cmbQU+DeBSGkWzB5tHh2JI+sq6Lo97q8ZxRIg43WmNc
         DnMw==
X-Gm-Message-State: APjAAAXj4Vdulo7e1W/mrANmwtMc6sdQyL3UCZhNxJMz4euG9NEQi385
	OBHEZZrBWQ8ilJA8VA9jPaLp9WOG1o1GyOfEH5FJoXNZz4kG9nE3KtvMdxve933E/UuYiUnyd+4
	lgyOE4z7OPxICjImOEWiQ6Xu0k4qSpB5AV46sXOMclykT9fwCpqVaLrK22VEvrFpmaw==
X-Received: by 2002:a17:90a:9bc5:: with SMTP id b5mr8218474pjw.109.1562893459490;
        Thu, 11 Jul 2019 18:04:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwHGvZ9+0Hlq+1en3/MzHnz2OnmTa//30GUxA9VUwBkTn8K4S55wX86KnZb5f1yylgkQUkn
X-Received: by 2002:a17:90a:9bc5:: with SMTP id b5mr8218400pjw.109.1562893458593;
        Thu, 11 Jul 2019 18:04:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562893458; cv=none;
        d=google.com; s=arc-20160816;
        b=ahPVmm9Z2GXGjFz8YqlYAAmKBbjaxTtBoXLsbexfsuZJ8VTMsBuzp7pncG+0ZThWuA
         ceIk1TfTbT7XtsNPzRDjlWPjf9GoFiHLyvkjzkkSmqn1nWrLM65qryye4Uq9urtYbn81
         eJyMWQeACIx/sAjdD5eVLbM9NRuFmJVOwvfWN1EUfmh05WIPcfXg4bz6q6LFpx4yIQK8
         x8py3Ulp40GD3G3wqUiKOA5WkJt8utNxKuVtGcx+yjh30NeSNvgn6MxUNGle3a4RNmKb
         Ysu53+Y03zwmfB+EGRpYNetAUQLk/rVbXVZKmbAzb8KSDDhKjppbC8/Ivr6h8Xj3WVd0
         En+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=riDzNQoeHsr/F1rbB9LpQ2Ps7FxNjb3tAQENVw8Ghy8=;
        b=zsYQ3Hg0GQqms8BfcTLtk2F6yvyFMSBz+HG/uKYIl2/kOna/x4Eg9EQnsNHQdYBklN
         yqUZPpJVBxkwFh65hOOB1z0AF8ME00PDvpPCVTkUAPf9afWHGf5G78EeLYHD41vBQpk2
         Y+Q6SMgUf8aAe8+GvGYvvEStMH7nYFaRg52Bwhpwl/SOpQJfMIir2WkwFzB8jgFySeOE
         7ic3KDjUZ7tOTI2yyAnib0BKJ4yWYGeuciStm0hzv63sQHUZ+R2AC/J5/V3Gud6kEQ9Y
         F49cyC34VGFS1fex7N8obyhqn3yxoHju8Xu3FdN89GyLkEe9ZjKdeIuamtyQaN+e8BKD
         Z4yQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=eIqKhpRe;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p1si7186870pff.250.2019.07.11.18.04.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 18:04:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=eIqKhpRe;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9C31E214AF;
	Fri, 12 Jul 2019 01:04:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562893458;
	bh=Bo+q0hKf5LxeaSDApUoWhLNtI3MOCrePufeOx5LfW4Y=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=eIqKhpReC6BpOSmlhSKbSmEX+UF6UZwoQMoeeqZrA9bz5kt6Fa1wU4ocnSjH69X1g
	 +yGG+J0opFVEOtIjbLclYHqZvjMxeT4i+rTawAiYusSoyp3wM8lN4VSx+dRY7HjOjp
	 tvdun+s0YcfiReWs+eyaOs5n7rfM1HXSSVq6olg0=
Date: Thu, 11 Jul 2019 18:04:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Sai Charan Sane <s.charan@samsung.com>, mhocko@suse.com,
 tglx@linutronix.de, rppt@linux.vnet.ibm.com, gregkh@linuxfoundation.org,
 joe@perches.com, miles.chen@mediatek.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, a.sahrawat@samsung.com, pankaj.m@samsung.com,
 v.narang@samsung.com
Subject: Re: [PATCH 1/1] mm/page_owner: store page_owner's gfp_mask in
 stackdepot itself
Message-Id: <20190711180417.1358ba8b359f68bbf92cf3c2@linux-foundation.org>
In-Reply-To: <24037235-2174-423f-9055-c6a49aa659e2@suse.cz>
References: <CGME20190607055426epcas5p24d6507b84fab957b8e0881d2ff727192@epcas5p2.samsung.com>
	<1559886798-29585-1-git-send-email-s.charan@samsung.com>
	<24037235-2174-423f-9055-c6a49aa659e2@suse.cz>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 17 Jun 2019 15:51:32 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> On 6/7/19 7:53 AM, Sai Charan Sane wrote:
> > Memory overhead of 4MB is reduced by storing gfp_mask in stackdepot along
> > with stacktrace. Stackdepot memory usage increased by ~100kb for 4GB of RAM.
> > 
> > Page owner logs from dmesg:
> > 	Before patch:
> > 		allocated 20971520 bytes of page_ext
> > 	After patch:
> > 		allocated 16777216 bytes of page_ext
> > 
> > Signed-off-by: Sai Charan Sane <s.charan@samsung.com>
> 
> I don't know, this looks like unneeded abuse to me. In the debug
> scenario when someone boots a kernel with page_owner enabled, does 4MB
> out of 4GB RAM really make a difference?

Thanks.  I'll drop this patch.

