Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f180.google.com (mail-yk0-f180.google.com [209.85.160.180])
	by kanga.kvack.org (Postfix) with ESMTP id 6552D6B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 09:42:36 -0400 (EDT)
Received: by yken206 with SMTP id n206so52066913yke.2
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 06:42:36 -0700 (PDT)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id l10si1196028ykd.24.2015.06.08.06.42.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 06:42:35 -0700 (PDT)
Message-ID: <55759BC8.50100@citrix.com>
Date: Mon, 8 Jun 2015 14:42:32 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] [Patch V4 00/16] xen: support pv-domains larger than
 512GB
References: <1433765217-16333-1-git-send-email-jgross@suse.com>
In-Reply-To: <1433765217-16333-1-git-send-email-jgross@suse.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Juergen Gross <jgross@suse.com>, xen-devel@lists.xensource.com, konrad.wilk@oracle.com, david.vrabel@citrix.com, boris.ostrovsky@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/06/15 13:06, Juergen Gross wrote:
> Support 64 bit pv-domains with more than 512GB of memory.
> 
> Tested with 64 bit dom0 on machines with 8GB and 1TB and 32 bit dom0 on a
> 8GB machine. Conflicts between E820 map and different hypervisor populated
> memory areas have been tested via a fake E820 map reserved area on the
> 8GB machine.

Do you have a git tree I can pull this from?

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
