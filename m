Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 8CE0F6B0036
	for <linux-mm@kvack.org>; Sat,  2 Aug 2014 04:39:39 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id a1so5310599wgh.35
        for <linux-mm@kvack.org>; Sat, 02 Aug 2014 01:39:38 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.193])
        by mx.google.com with ESMTP id dw12si23839805wjb.138.2014.08.02.01.39.37
        for <linux-mm@kvack.org>;
        Sat, 02 Aug 2014 01:39:37 -0700 (PDT)
Date: Sat, 2 Aug 2014 11:39:29 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 0/2] faultaround updates
Message-ID: <20140802083929.GA17045@node.dhcp.inet.fi>
References: <1406893869-32739-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.02.1408011432100.11532@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1408011432100.11532@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org

On Fri, Aug 01, 2014 at 02:32:36PM -0700, David Rientjes wrote:
> On Fri, 1 Aug 2014, Kirill A. Shutemov wrote:
> 
> > One fix and one tweak for faultaround code.
> > 
> > As alternative, we could just drop debugfs interface and make
> > fault_around_bytes constant.
> > 
> 
> If we can remove the debugfs interface, then it seems better than 
> continuing to support it.  Any objections to removing it?

Andrew asked it initially. Up to him.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
