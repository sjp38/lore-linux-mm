Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 138936B4139
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 03:47:36 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id m13so21196703pls.15
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 00:47:36 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m3si34578480pfh.58.2018.11.26.00.47.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 00:47:35 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAQ8eG1L117596
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 03:47:34 -0500
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p0b5g5s96-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 03:47:34 -0500
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 26 Nov 2018 08:47:31 -0000
Date: Mon, 26 Nov 2018 10:47:20 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH 5/5] arch: simplify several early memory allocations
References: <1543182277-8819-1-git-send-email-rppt@linux.ibm.com>
 <1543182277-8819-6-git-send-email-rppt@linux.ibm.com>
 <20181126082134.GA10530@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126082134.GA10530@infradead.org>
Message-Id: <20181126084719.GC14863@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Greentime Hu <green.hu@gmail.com>, Jonas Bonn <jonas@southpole.se>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Mark Salter <msalter@redhat.com>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org

On Mon, Nov 26, 2018 at 12:21:34AM -0800, Christoph Hellwig wrote:
> >  static void __init *early_alloc_aligned(unsigned long sz, unsigned long align)
> >  {
> > -	void *ptr = __va(memblock_phys_alloc(sz, align));
> > -	memset(ptr, 0, sz);
> > -	return ptr;
> > +	return memblock_alloc(sz, align);
> >  }
> 
> What is the point of keeping this wrapper?

No point indeed. I'll remove it in v2.
 
> >  static void __init *early_alloc(unsigned long sz)
> >  {
> > -	void *ptr = __va(memblock_phys_alloc(sz, sz));
> > -	memset(ptr, 0, sz);
> > -	return ptr;
> > +	return memblock_alloc(sz, sz);
> >  }
> 
> Same here.
> 

Here it provides a shortcut for allocations with align == size, but can be
removed as well.

-- 
Sincerely yours,
Mike.
