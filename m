Return-Path: <SRS0=02aR=PE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 208B0C43387
	for <linux-mm@archiver.kernel.org>; Thu, 27 Dec 2018 20:07:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78F39208E4
	for <linux-mm@archiver.kernel.org>; Thu, 27 Dec 2018 20:07:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazonses.com header.i=@amazonses.com header.b="TOF2ro9U"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78F39208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 131078E0021; Thu, 27 Dec 2018 15:07:28 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E1618E0001; Thu, 27 Dec 2018 15:07:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F38518E0021; Thu, 27 Dec 2018 15:07:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C65FA8E0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2018 15:07:27 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id 41so25242154qto.17
        for <linux-mm@kvack.org>; Thu, 27 Dec 2018 12:07:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version
         :feedback-id;
        bh=QTawriguloQdF7CFQCrxqBobe3Vbqu3Bc8KBa60ZtJY=;
        b=oJGJGERCkwtJ4wwxFEn9OZuV/nywORUoc07JbcrZjAqz/pxzh6/ps3UmIPwt1yaVbU
         qJL0RxHOX+d3j9fm5K/lQ1T2jXY3jY7rZPObQKFzzd0AUm6SEKtOjzJZh9odoDLDPds/
         Ukw5O/HK3iLDBVGGe+vjGmKu5uoOtvz5wB/Y61QYa0+4qvFjnLwktT5LNlm5FYFj85a4
         wNOcdcP+VDbjXnJUpn0yuvMK5vknHL/RBCsZubcJMgBOuZ07aKwvqkrgerUPPDIwjBCe
         1TTHeU4n+tBBGDFaS4ua4xfparXf6MyzUrg5Im8LQGZvjAdVwa3NPy8x9D0r0jFmtL+s
         WHFw==
X-Gm-Message-State: AA+aEWYC+dHpJRiAU4G/f/PWFSGuhL9rK89TKOPO0DDVT9iZCU+UU1h/
	RWnE+1G+3IpgGb5wirFZMJzHlChzwQvyrwPR++x9sFMDXK3cXfDY4QnbwAJTMeoMcP+2t6NGXmC
	S3Nz+uMVSa5y5bAnc9V/PK+UXjR7X/L58cVZj/zTW8SGb2enJ8S3E7cJpnWtBTwA=
X-Received: by 2002:ac8:12cc:: with SMTP id b12mr23038268qtj.90.1545941247567;
        Thu, 27 Dec 2018 12:07:27 -0800 (PST)
X-Google-Smtp-Source: AFSGD/U7F0Ti07ZO5U6yJWavIDYC8VX5smsRWIz3dcQ1ZXOPQP7d83BR3gC9g2KjFsCKtoJ91APv
X-Received: by 2002:ac8:12cc:: with SMTP id b12mr23038237qtj.90.1545941247012;
        Thu, 27 Dec 2018 12:07:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545941247; cv=none;
        d=google.com; s=arc-20160816;
        b=ZliDq9bqLTJZzMKvaC0LUVSmGNb+BLQZhhCMSxoUiuTm0rfXsxnoEvFFRUvWH9s2KC
         WyzuAA0cHy0DroI4NHKoJIafrEOC93IHYhORZyEVix0fSYNGXXcQhzchhVl5Taa7x01N
         +1ETkhst0wZvHIlFI3BytDK/Fs8BaIJX2qEdjPtre5IYl1XnyzJdX3Z9n1hY+LBjLajO
         n6fZakeVSu50YLLz4Hb4hM9h/xo4ynI9OsPjuR4tpyexJDIDmDO1LbVATGyXQJM92s41
         rRJqLTDuxe9Y5IufKJYYxbeR0pbvK6szsL06ihp0xRuOy/tcNXZjYYXcavjoe9lDMvuA
         qn5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=feedback-id:mime-version:user-agent:references:message-id
         :in-reply-to:subject:cc:to:from:date:dkim-signature;
        bh=QTawriguloQdF7CFQCrxqBobe3Vbqu3Bc8KBa60ZtJY=;
        b=RLInNs1e26oA+LgCOYmpcyH/FeFaAbaLJh5ZhkKwT3HONnx09p64ogy/JVRdO3kKrr
         wpo1T8euEAaBPb8vyP7TXkiGGS0dXS8hCJp0p69cho2qpHv/Jii5Iz7oL4dG3RUgmsk6
         GUh3q3nab1j7D43gl7p3mP/z1uMcLtwKwh/8KVPbCi+Y/OJ+MksSm2Ckst3SY/255sOz
         GN/0tc/rjkcsPeLKql9ieVWnT8y3cGrY4diL3QI+JN2Bcr6J0YWifkiH7NE7gKnWzfkE
         BaXPo/QdtktOFUNsE2+0wcITlBqSnmrg1yaRdioibhXDBSdy7nO8f8XniIcNPliZ+TYb
         ArwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=TOF2ro9U;
       spf=pass (google.com: domain of 01000167f14761d6-b1564081-0d5f-4752-86be-2e99c8375866-000000@amazonses.com designates 54.240.9.99 as permitted sender) smtp.mailfrom=01000167f14761d6-b1564081-0d5f-4752-86be-2e99c8375866-000000@amazonses.com
Received: from a9-99.smtp-out.amazonses.com (a9-99.smtp-out.amazonses.com. [54.240.9.99])
        by mx.google.com with ESMTPS id a24si1236089qth.308.2018.12.27.12.07.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 27 Dec 2018 12:07:27 -0800 (PST)
Received-SPF: pass (google.com: domain of 01000167f14761d6-b1564081-0d5f-4752-86be-2e99c8375866-000000@amazonses.com designates 54.240.9.99 as permitted sender) client-ip=54.240.9.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazonses.com header.s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug header.b=TOF2ro9U;
       spf=pass (google.com: domain of 01000167f14761d6-b1564081-0d5f-4752-86be-2e99c8375866-000000@amazonses.com designates 54.240.9.99 as permitted sender) smtp.mailfrom=01000167f14761d6-b1564081-0d5f-4752-86be-2e99c8375866-000000@amazonses.com
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/simple;
	s=ug7nbtf4gccmlpwj322ax3p6ow6yfsug; d=amazonses.com; t=1545941246;
	h=Date:From:To:cc:Subject:In-Reply-To:Message-ID:References:MIME-Version:Content-Type:Feedback-ID;
	bh=QTawriguloQdF7CFQCrxqBobe3Vbqu3Bc8KBa60ZtJY=;
	b=TOF2ro9UED8NSFyGorBRsg+X2DDadwH1nM2B9UdS6Bhj2/qGg+zM4pDa67jHnv16
	sqcbXF8yAOKi4/erGhfr/4AEEK/+b+zmwBDhpxj2i0ndnFLIfX/72SM2mYZ+rKoV21n
	MOE+VlpbpmatqS5fDdmrTqc2jcBtjLUH3HMFK8Rk=
Date: Thu, 27 Dec 2018 20:07:26 +0000
From: Christopher Lameter <cl@linux.com>
X-X-Sender: cl@nuc-kabylake
To: Fengguang Wu <fengguang.wu@intel.com>
cc: Andrew Morton <akpm@linux-foundation.org>, 
    Linux Memory Management List <linux-mm@kvack.org>, 
    Fan Du <fan.du@intel.com>, kvm@vger.kernel.org, 
    LKML <linux-kernel@vger.kernel.org>, Yao Yuan <yuan.yao@intel.com>, 
    Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, 
    Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, 
    Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, 
    Dan Williams <dan.j.williams@intel.com>
Subject: Re: [RFC][PATCH v2 08/21] mm: introduce and export pgdat peer_node
In-Reply-To: <20181226133351.521151384@intel.com>
Message-ID:
 <01000167f14761d6-b1564081-0d5f-4752-86be-2e99c8375866-000000@email.amazonses.com>
References: <20181226131446.330864849@intel.com> <20181226133351.521151384@intel.com>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-SES-Outgoing: 2018.12.27-54.240.9.99
Feedback-ID: 1.us-east-1.fQZZZ0Xtj2+TD7V5apTT/NrT6QKuPgzCT/IC7XYgDKI=:AmazonSES
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181227200726.7UkGDY1McWKeSEXrxrNP6JoNxSSnz7Uny21TPUH2DFU@z>

On Wed, 26 Dec 2018, Fengguang Wu wrote:

> Each CPU socket can have 1 DRAM and 1 PMEM node, we call them "peer nodes".
> Migration between DRAM and PMEM will by default happen between peer nodes.

Which one does numa_node_id() point to? I guess that is the DRAM node and
then we fall back to the PMEM node?

