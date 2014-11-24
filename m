Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4116B00A5
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 10:03:45 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id l15so5950591wiw.14
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 07:03:44 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id mc20si12675753wic.30.2014.11.24.07.03.44
        for <linux-mm@kvack.org>;
        Mon, 24 Nov 2014 07:03:44 -0800 (PST)
Date: Mon, 24 Nov 2014 17:03:42 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH] mm/thp: Always allocate transparent hugepages on
 local node
Message-ID: <20141124150342.GA3889@node.dhcp.inet.fi>
References: <1416838791-30023-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1416838791-30023-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 24, 2014 at 07:49:51PM +0530, Aneesh Kumar K.V wrote:
> This make sure that we try to allocate hugepages from local node. If
> we can't we fallback to small page allocation based on
> mempolicy. This is based on the observation that allocating pages
> on local node is more beneficial that allocating hugepages on remote node.

Local node on allocation is not necessary local node for use.
If policy says to use a specific node[s], we should follow.

I think it makes sense to force local allocation if policy is interleave
or if current node is in preferred or bind set.
 
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
