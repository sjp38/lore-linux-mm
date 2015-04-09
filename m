Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f50.google.com (mail-vn0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id AADBE6B0032
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 04:25:09 -0400 (EDT)
Received: by vnbg129 with SMTP id g129so20761155vnb.4
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 01:25:09 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id f33si6845351yha.66.2015.04.09.01.25.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Apr 2015 01:25:09 -0700 (PDT)
Message-ID: <5526374F.50401@citrix.com>
Date: Thu, 9 Apr 2015 09:24:47 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] [Patch V2 02/15] xen: save linear p2m list address
 in shared info structure
References: <1428562542-28488-1-git-send-email-jgross@suse.com>
 <1428562542-28488-3-git-send-email-jgross@suse.com>
In-Reply-To: <1428562542-28488-3-git-send-email-jgross@suse.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org

On 09/04/15 07:55, Juergen Gross wrote:
> The virtual address of the linear p2m list should be stored in the
> shared info structure read by the Xen tools to be able to support
> 64 bit pv-domains larger than 512 GB. Additionally the linear p2m
> list interface includes a generation count which is changed prior
> to and after each mapping change of the p2m list. Reading the
> generation count the Xen tools can detect changes of the mappings
> and re-read the p2m list eventually.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
