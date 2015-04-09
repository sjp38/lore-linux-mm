Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 518CB6B0032
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 08:59:05 -0400 (EDT)
Received: by wiun10 with SMTP id n10so96976952wiu.1
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 05:59:04 -0700 (PDT)
Received: from smarthost01d.mail.zen.net.uk (smarthost01d.mail.zen.net.uk. [212.23.1.7])
        by mx.google.com with ESMTP id x4si17144232wjr.105.2015.04.09.05.59.03
        for <linux-mm@kvack.org>;
        Thu, 09 Apr 2015 05:59:04 -0700 (PDT)
Message-ID: <55267790.6090705@cantab.net>
Date: Thu, 09 Apr 2015 13:58:56 +0100
From: David Vrabel <dvrabel@cantab.net>
MIME-Version: 1.0
References: <1428562542-28488-1-git-send-email-jgross@suse.com> <1428562542-28488-12-git-send-email-jgross@suse.com>
In-Reply-To: <1428562542-28488-12-git-send-email-jgross@suse.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Subject: Re: [Xen-devel] [Patch V2 11/15] xen: check for initrd conflicting
 with e820 map
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org

On 09/04/2015 07:55, Juergen Gross wrote:
> Check whether the initrd is placed at a location which is conflicting
> with the target E820 map. If this is the case relocate it to a new
> area unused up to now and compliant to the E820 map.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
