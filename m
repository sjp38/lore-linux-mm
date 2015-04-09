Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 83A1D6B0032
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 08:41:25 -0400 (EDT)
Received: by wgin8 with SMTP id n8so118787214wgi.0
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 05:41:25 -0700 (PDT)
Received: from smarthost01d.mail.zen.net.uk (smarthost01d.mail.zen.net.uk. [212.23.1.7])
        by mx.google.com with ESMTP id i2si4570696wjz.123.2015.04.09.05.41.23
        for <linux-mm@kvack.org>;
        Thu, 09 Apr 2015 05:41:24 -0700 (PDT)
Message-ID: <5526736B.2000504@cantab.net>
Date: Thu, 09 Apr 2015 13:41:15 +0100
From: David Vrabel <dvrabel@cantab.net>
MIME-Version: 1.0
References: <1428562542-28488-1-git-send-email-jgross@suse.com> <1428562542-28488-9-git-send-email-jgross@suse.com>
In-Reply-To: <1428562542-28488-9-git-send-email-jgross@suse.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Subject: Re: [Xen-devel] [Patch V2 08/15] xen: find unused contiguous memory
 area
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org

On 09/04/2015 07:55, Juergen Gross wrote:
> For being able to relocate pre-allocated data areas like initrd or
> p2m list it is mandatory to find a contiguous memory area which is
> not yet in use and doesn't conflict with the memory map we want to
> be in effect.
> 
> In case such an area is found reserve it at once as this will be
> required to be done in any case.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
