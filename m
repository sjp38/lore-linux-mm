Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id E58446B006C
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 08:16:29 -0400 (EDT)
Received: by yhid80 with SMTP id d80so29385328yhi.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 05:16:29 -0700 (PDT)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id l126si624692ywg.176.2015.06.08.05.16.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 05:16:28 -0700 (PDT)
Message-ID: <5575878E.4040109@citrix.com>
Date: Mon, 8 Jun 2015 13:16:14 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [Patch V4 13/16] xen: add explicit memblock_reserve() calls for
 special pages
References: <1433765217-16333-1-git-send-email-jgross@suse.com>
 <1433765217-16333-14-git-send-email-jgross@suse.com>
In-Reply-To: <1433765217-16333-14-git-send-email-jgross@suse.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>, xen-devel@lists.xensource.com, konrad.wilk@oracle.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/06/15 13:06, Juergen Gross wrote:
> Some special pages containing interfaces to xen are being reserved
> implicitly only today. The memblock_reserve() call to reserve them is
> meant to reserve the p2m list supplied by xen. It is just reserving
> not only the p2m list itself, but some more pages up to the start of
> the xen built page tables.
> 
> To be able to move the p2m list to another pfn range, which is needed
> for support of huge RAM, this memblock_reserve() must be split up to
> cover all affected reserved pages explicitly.
> 
> The affected pages are:
> - start_info page
> - xenstore ring
> - console ring
> - shared_info page

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
