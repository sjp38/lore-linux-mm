Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D8EDC282DD
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 22:02:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 55F45217FA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 22:02:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 55F45217FA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F38666B0005; Wed, 17 Apr 2019 18:02:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE6DD6B0006; Wed, 17 Apr 2019 18:02:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D96686B0007; Wed, 17 Apr 2019 18:02:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A100F6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 18:02:04 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id v9so9242pgg.8
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 15:02:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gUpncewlGFYhGyrpxZN0ms6nXrEVeQp6D9ZBVG4nf58=;
        b=mEChQtRk10No5VeE59iAU++icmb1t7IlPkNcfolZZo28s0YZjmpPlDJVVnOavpuhNs
         4dxIZqaQLDMs2TDMiR2rI/AnFSl1z4TQCcNVE0oJaK9ilkPt1gsUo2ywxpYBu9qWAbzG
         ctAmozk0kqo0368zBqPIJ5yet6wGZk74+SOUcrKZxe0Ri61/RCWmFvfHK8/IPKfDu+MC
         ubQF4Z3Uci5DqP5O1rQKoJUywKUVArWRvmy1nsp7sheRGj9ceWZIp15hWXVUSiQQfC1s
         wzfD0hy+ghdbas6/UzkFzxHyrI0FOYIqHrUMDcXwoJlfzH+ywpNhtbl401h82oJLju0u
         m+gQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAWzc2nsbJYc6b0vBmvzq/TpzeMS2JqMOWll9Mrb8rtUKUZ5auSL
	oVBMs7m9M2qD/R01yeoWNKIUNujLYrNGYyClDCr/XPQKNlMJvJ/83tAbqMWJgZpP7Te749G9pDG
	+EXM4sjdEnK2Ctt+pPRgxVvSfd9Zw7DT9qWjflOT8QmpcFFHc1+3886k0lyuaexrpxg==
X-Received: by 2002:a17:902:22f:: with SMTP id 44mr88278777plc.175.1555538524319;
        Wed, 17 Apr 2019 15:02:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYUfECT3F3XsOU3Eh2XwTP9kDU/DZEwjVoYRU45b2X2hJd8fnSFwzpjsc5jKlTsgZgpaFI
X-Received: by 2002:a17:902:22f:: with SMTP id 44mr88278701plc.175.1555538523637;
        Wed, 17 Apr 2019 15:02:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555538523; cv=none;
        d=google.com; s=arc-20160816;
        b=BqS5n1BzDVO8cOYr5O+zY5c98UbdJrHh4bfocuj5lbSK+6o7Q+zGkbDMUaLsCHrlDb
         eZykEzghOf2ofnkVbkYM31oIwUvK+rEJOSJ0CRVvauVcwlHH0y0gDythbMcd7qAgUzaN
         zMeg7Qa6aAJaAPLQ2ccONMd0yqQlAz3NFB/kkkUaU0CYpmnBAZH1VGk5F9++TvRaBsg6
         jmUoKLiz4eP1I6+104LBRwCcOu4Y3gD7lMrwpMwbkxm0ZrxGpzJdhH0fdCQbUCa144hX
         3nnQ+H+EBEj8iYH392Wwp4y2ltkhi/5DvF0mFHlMnkHoxOIctRPpsrUHpQbzkRBfZrHV
         O+mg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=gUpncewlGFYhGyrpxZN0ms6nXrEVeQp6D9ZBVG4nf58=;
        b=QVXfm0JmeY6qGi3hoftyZIHQU3blJlT/pxzVfkH9jqKWignN3CPtSlE7GWQ9XvDmIl
         MFC5NntE+bfa+h4VnJP1sDMBQHBUB+h+ZwrspmSBfqHZkUrYDyaW1UvHMjoMl//5HCm7
         8fmVNAfj4HgdbZ0elMprD95ewXNr4AyiNURPygMTeGg2h6y5OPjFN+0VF7U0k3Tm+iFT
         pHukw/wUWnTnUWQILO4MQW9pXuE8AHUcBTDGD0mwq5va2ltwZXcV30MKmpbO3EqGiLVW
         ccitaAL6+TF2+feuRX/HmUkeCf4dEWG/V2nL3vMxEEnfPqnXO6qSOUagFWaSAU8ay7rm
         iTQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t17si5051pgv.493.2019.04.17.15.02.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 15:02:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 18633C2A;
	Wed, 17 Apr 2019 22:02:03 +0000 (UTC)
Date: Wed, 17 Apr 2019 15:02:02 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: stable@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org,
 linux-kernel@vger.kernel.org, mhocko@suse.com, david@redhat.com
Subject: Re: [PATCH v6 11/12] libnvdimm/pfn: Fix fsdax-mode namespace
 info-block zero-fields
Message-Id: <20190417150202.b7cec444cf81ed44a150ea9d@linux-foundation.org>
In-Reply-To: <155552639290.2015392.17304211251966796338.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
	<155552639290.2015392.17304211251966796338.stgit@dwillia2-desk3.amr.corp.intel.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Apr 2019 11:39:52 -0700 Dan Williams <dan.j.williams@intel.com> wrote:

> At namespace creation time there is the potential for the "expected to
> be zero" fields of a 'pfn' info-block to be filled with indeterminate
> data. While the kernel buffer is zeroed on allocation it is immediately
> overwritten by nd_pfn_validate() filling it with the current contents of
> the on-media info-block location. For fields like, 'flags' and the
> 'padding' it potentially means that future implementations can not rely
> on those fields being zero.
> 
> In preparation to stop using the 'start_pad' and 'end_trunc' fields for
> section alignment, arrange for fields that are not explicitly
> initialized to be guaranteed zero. Bump the minor version to indicate it
> is safe to assume the 'padding' and 'flags' are zero. Otherwise, this
> corruption is expected to benign since all other critical fields are
> explicitly initialized.
> 
> Fixes: 32ab0a3f5170 ("libnvdimm, pmem: 'struct page' for pmem")
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>

Buried at the end of a 12 patch series.  Should this be a standalone
patch, suitable for a prompt merge?

