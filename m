Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id BEA5B6B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 14:31:13 -0500 (EST)
Received: by mail-qc0-f177.google.com with SMTP id i8so59481qcq.36
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 11:31:13 -0800 (PST)
Received: from qmta12.emeryville.ca.mail.comcast.net (qmta12.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:227])
        by mx.google.com with ESMTP id g2si1812093qag.173.2014.01.14.11.31.12
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 11:31:12 -0800 (PST)
Date: Tue, 14 Jan 2014 13:31:09 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 1/9] mm: slab/slub: use page->list consistently
 instead of page->lru
In-Reply-To: <20140114180044.1E401C47@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.10.1401141330440.19618@nuc>
References: <20140114180042.C1C33F78@viggo.jf.intel.com> <20140114180044.1E401C47@viggo.jf.intel.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org

On Tue, 14 Jan 2014, Dave Hansen wrote:

> This patch makes the slab and slub code use page->lru
> universally instead of mixing ->list and ->lru.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
