Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 040396B0031
	for <linux-mm@kvack.org>; Mon, 13 Jan 2014 23:30:19 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id g10so2131661pdj.28
        for <linux-mm@kvack.org>; Mon, 13 Jan 2014 20:30:19 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id s7si17613245pae.301.2014.01.13.20.30.17
        for <linux-mm@kvack.org>;
        Mon, 13 Jan 2014 20:30:18 -0800 (PST)
Date: Mon, 13 Jan 2014 20:32:03 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] powerpc: thp: Fix crash on mremap
Message-Id: <20140113203203.f8cb0bed.akpm@linux-foundation.org>
In-Reply-To: <1389672810.6933.0.camel@pasglop>
References: <1388570027-22933-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
	<1388572145.4373.41.camel@pasglop>
	<20140102021951.GA26369@node.dhcp.inet.fi>
	<20140113141748.0b851e1573e41bf26de7c0ae@linux-foundation.org>
	<1389672810.6933.0.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, paulus@samba.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Tue, 14 Jan 2014 15:13:30 +1100 Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:

> On Mon, 2014-01-13 at 14:17 -0800, Andrew Morton wrote:
> 
> > Did this get fixed?
> 
> Any chance you can Ack the patch on that thread ?
> 
> http://thread.gmane.org/gmane.linux.kernel.mm/111809
> 
> So I can put it in powerpc -next with a CC stable ? Or if you tell me
> tat Kirill Ack is sufficient then I'll go for it.

yup, it looks OK to me from a non-ppc perspective.  Please proceed as
described.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
