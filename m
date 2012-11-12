Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id E9BB76B0072
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 18:49:18 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id xa7so1012281pbc.14
        for <linux-mm@kvack.org>; Mon, 12 Nov 2012 15:49:18 -0800 (PST)
Date: Mon, 12 Nov 2012 15:49:15 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: RE: [PATCH 1/1] mm: Export a function to read vm_committed_as
In-Reply-To: <c04bb062-bbce-4980-b2b3-fbbb18e64b66@default>
Message-ID: <alpine.DEB.2.00.1211121547450.3841@chino.kir.corp.google.com>
References: <1352600728-17766-1-git-send-email-kys@microsoft.com> <alpine.DEB.2.00.1211101830250.18494@chino.kir.corp.google.com> <426367E2313C2449837CD2DE46E7EAF930E35B45@SN2PRD0310MB382.namprd03.prod.outlook.com> <alpine.DEB.2.00.1211121349130.23347@chino.kir.corp.google.com>
 <426367E2313C2449837CD2DE46E7EAF930E39FBC@SN2PRD0310MB382.namprd03.prod.outlook.com> <c04bb062-bbce-4980-b2b3-fbbb18e64b66@default>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: KY Srinivasan <kys@microsoft.com>, Konrad Wilk <konrad.wilk@oracle.com>, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyuki@gmail.com, mhocko@suse.cz, hannes@cmpxchg.org, yinghan@google.com

On Mon, 12 Nov 2012, Dan Magenheimer wrote:

> > > Why?  Is xen using it for a different inference?
> > 
> > I think it is good to separate these patches. Dan (copied here) wrote the code for the
> > Xen self balloon driver. If it is ok with him I can submit the patch for Xen as well.
> 
> Hi KY --
> 
> If I understand correctly, this would be only a cosmetic (function renaming) change
> to the Xen selfballooning code.  If so, then I will be happy to Ack when I
> see the patch.  However, Konrad (konrad.wilk@oracle.com) is the maintainer
> for all Xen code so you should ask him... and (from previous painful experience)
> it can be difficult to sync even very simple interdependent changes going through
> different maintainers without breaking linux-next.  So I can't offer any
> help with that process, only commiseration. :-(
> 

I think this should be done in the same patch as the function getting 
introduced with a cc to Konrad and routed through -mm; even better, 
perhaps he'll have some useful comments for how this is used for xen that 
can be included for context.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
