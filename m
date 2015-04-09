Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f49.google.com (mail-vn0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id CA04A6B006C
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 04:26:03 -0400 (EDT)
Received: by vnbg62 with SMTP id g62so20771876vnb.7
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 01:26:03 -0700 (PDT)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id f42si6834936yho.125.2015.04.09.01.26.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Apr 2015 01:26:03 -0700 (PDT)
Message-ID: <55263798.5080501@citrix.com>
Date: Thu, 9 Apr 2015 09:26:00 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] [Patch V2 03/15] xen: don't build mfn tree if tools
 don't need it
References: <1428562542-28488-1-git-send-email-jgross@suse.com>
 <1428562542-28488-4-git-send-email-jgross@suse.com>
In-Reply-To: <1428562542-28488-4-git-send-email-jgross@suse.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org

On 09/04/15 07:55, Juergen Gross wrote:
> In case the Xen tools indicate they don't need the p2m 3 level tree
> as they support the virtual mapped linear p2m list, just omit building
> the tree.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
