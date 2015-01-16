Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id A26CB6B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 07:27:29 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id bs8so3727243wib.5
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 04:27:29 -0800 (PST)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id l5si3905039wiy.6.2015.01.16.04.27.28
        for <linux-mm@kvack.org>;
        Fri, 16 Jan 2015 04:27:28 -0800 (PST)
Date: Fri, 16 Jan 2015 14:27:24 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V3] mm/thp: Allocate transparent hugepages on local node
Message-ID: <20150116122724.GB29085@node.dhcp.inet.fi>
References: <1421393196-20915-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1421393196-20915-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jan 16, 2015 at 12:56:36PM +0530, Aneesh Kumar K.V wrote:
> This make sure that we try to allocate hugepages from local node if
> allowed by mempolicy. If we can't, we fallback to small page allocation
> based on mempolicy. This is based on the observation that allocating pages
> on local node is more beneficial than allocating hugepages on remote node.
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Looks good to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
