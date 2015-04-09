Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id E8C186B006C
	for <linux-mm@kvack.org>; Thu,  9 Apr 2015 08:42:13 -0400 (EDT)
Received: by wiun10 with SMTP id n10so96397241wiu.1
        for <linux-mm@kvack.org>; Thu, 09 Apr 2015 05:42:13 -0700 (PDT)
Received: from smarthost01b.mail.zen.net.uk (smarthost01b.mail.zen.net.uk. [212.23.1.3])
        by mx.google.com with ESMTP id kw4si23918581wjb.84.2015.04.09.05.42.12
        for <linux-mm@kvack.org>;
        Thu, 09 Apr 2015 05:42:12 -0700 (PDT)
Message-ID: <5526739F.1080904@cantab.net>
Date: Thu, 09 Apr 2015 13:42:07 +0100
From: David Vrabel <dvrabel@cantab.net>
MIME-Version: 1.0
References: <1428562542-28488-1-git-send-email-jgross@suse.com> <1428562542-28488-10-git-send-email-jgross@suse.com>
In-Reply-To: <1428562542-28488-10-git-send-email-jgross@suse.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Subject: Re: [Xen-devel] [Patch V2 09/15] xen: check for kernel memory conflicting
 with memory layout
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org

On 09/04/2015 07:55, Juergen Gross wrote:
> Checks whether the pre-allocated memory of the loaded kernel is in
> conflict with the target memory map. If this is the case, just panic
> instead of run into problems later, as there is nothing we can do
> to repair this situation.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
