Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f174.google.com (mail-ve0-f174.google.com [209.85.128.174])
	by kanga.kvack.org (Postfix) with ESMTP id 3051A6B0031
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 23:13:48 -0500 (EST)
Received: by mail-ve0-f174.google.com with SMTP id c14so377787vea.5
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 20:13:47 -0800 (PST)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id dp3si337084vcb.96.2014.01.13.20.13.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 13 Jan 2014 20:13:45 -0800 (PST)
Message-ID: <1389672810.6933.0.camel@pasglop>
Subject: Re: [PATCH] powerpc: thp: Fix crash on mremap
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 14 Jan 2014 15:13:30 +1100
In-Reply-To: <20140113141748.0b851e1573e41bf26de7c0ae@linux-foundation.org>
References: 
	<1388570027-22933-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	 <1388572145.4373.41.camel@pasglop>
	 <20140102021951.GA26369@node.dhcp.inet.fi>
	 <20140113141748.0b851e1573e41bf26de7c0ae@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, paulus@samba.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Mon, 2014-01-13 at 14:17 -0800, Andrew Morton wrote:

> Did this get fixed?

Any chance you can Ack the patch on that thread ?

http://thread.gmane.org/gmane.linux.kernel.mm/111809

So I can put it in powerpc -next with a CC stable ? Or if you tell me
tat Kirill Ack is sufficient then I'll go for it.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
