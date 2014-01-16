Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f53.google.com (mail-qa0-f53.google.com [209.85.216.53])
	by kanga.kvack.org (Postfix) with ESMTP id 6ABA86B0031
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 13:35:09 -0500 (EST)
Received: by mail-qa0-f53.google.com with SMTP id cm18so2473093qab.12
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 10:35:09 -0800 (PST)
Received: from qmta06.emeryville.ca.mail.comcast.net (qmta06.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:56])
        by mx.google.com with ESMTP id n4si10718492qeu.23.2014.01.16.10.35.01
        for <linux-mm@kvack.org>;
        Thu, 16 Jan 2014 10:35:02 -0800 (PST)
Date: Thu, 16 Jan 2014 12:34:59 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 5/9] mm: rearrange struct page
In-Reply-To: <20140114180055.21691733@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.10.1401161233060.30036@nuc>
References: <20140114180042.C1C33F78@viggo.jf.intel.com> <20140114180055.21691733@viggo.jf.intel.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org

On Tue, 14 Jan 2014, Dave Hansen wrote:

>
> This makes it *MUCH* more clear how the first few fields of
> 'struct page' get used by the slab allocators.

I think this adds to the confusion. What you want to know is which other
fields overlap a certain field. After this patch you wont have that
anymore.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
