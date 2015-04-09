Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f50.google.com (mail-vn0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id 7CF1E6B0032
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 04:23:40 -0400 (EDT)
Received: by vnbg1 with SMTP id g1so17884783vnb.2
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 01:23:40 -0700 (PDT)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id 64si6846353ykl.53.2015.04.09.01.23.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Apr 2015 01:23:39 -0700 (PDT)
Message-ID: <55263708.1080906@citrix.com>
Date: Thu, 9 Apr 2015 09:23:36 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] [Patch V2 01/15] xen: sync with xen headers
References: <1428562542-28488-1-git-send-email-jgross@suse.com>
 <1428562542-28488-2-git-send-email-jgross@suse.com>
In-Reply-To: <1428562542-28488-2-git-send-email-jgross@suse.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org

On 09/04/15 07:55, Juergen Gross wrote:
> Use the newest headers from the xen tree to get some new structure
> layouts.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
