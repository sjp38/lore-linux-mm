Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 42F196B0005
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 17:58:13 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id y7-v6so12736538plt.17
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 14:58:13 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l12-v6si23297619pfb.69.2018.06.11.14.58.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jun 2018 14:58:11 -0700 (PDT)
Date: Mon, 11 Jun 2018 14:58:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v11 3/7] mm: fix __gup_device_huge vs unmap
Message-Id: <20180611145809.c05f215b9b2e7dab9e808304@linux-foundation.org>
In-Reply-To: <152669370864.34337.13815113039455146564.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152669369110.34337.14271778212195820353.stgit@dwillia2-desk3.amr.corp.intel.com>
	<152669370864.34337.13815113039455146564.stgit@dwillia2-desk3.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, stable@vger.kernel.org, Jan Kara <jack@suse.cz>, david@fromorbit.com, hch@lst.de, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, 18 May 2018 18:35:08 -0700 Dan Williams <dan.j.williams@intel.com> wrote:

> get_user_pages_fast() for device pages is missing the typical validation
> that all page references have been taken while the mapping was valid.
> Without this validation truncate operations can not reliably coordinate
> against new page reference events like O_DIRECT.
> 
> Cc: <stable@vger.kernel.org>

I'm not seeing anything in the changelog which justifies a -stable
backport.  ie: a description of the end-user-visible effects of the
bug?
