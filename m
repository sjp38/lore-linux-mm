Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f44.google.com (mail-qa0-f44.google.com [209.85.216.44])
	by kanga.kvack.org (Postfix) with ESMTP id 86E986B0031
	for <linux-mm@kvack.org>; Fri, 17 Jan 2014 09:58:21 -0500 (EST)
Received: by mail-qa0-f44.google.com with SMTP id w5so3410259qac.31
        for <linux-mm@kvack.org>; Fri, 17 Jan 2014 06:58:21 -0800 (PST)
Received: from qmta03.emeryville.ca.mail.comcast.net (qmta03.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:32])
        by mx.google.com with ESMTP id a10si1784661qab.97.2014.01.17.06.58.20
        for <linux-mm@kvack.org>;
        Fri, 17 Jan 2014 06:58:20 -0800 (PST)
Date: Fri, 17 Jan 2014 08:58:17 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 5/9] mm: rearrange struct page
In-Reply-To: <52D85D33.4080509@sr71.net>
Message-ID: <alpine.DEB.2.10.1401170857230.1943@nuc>
References: <20140114180042.C1C33F78@viggo.jf.intel.com> <20140114180055.21691733@viggo.jf.intel.com> <alpine.DEB.2.10.1401161233060.30036@nuc> <52D85D33.4080509@sr71.net>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org

On Thu, 16 Jan 2014, Dave Hansen wrote:

> Why does it matter *specifically* that "index shares space with
> freelist", or that "mapping shares space with s_mem"?  No data is ever
> handed off in those fields.

If the field is corrupted then one needs to figure out what other ways of
using this field exists. If one wants to change the page struct fields
then also knowlege about possible interconnections are important.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
