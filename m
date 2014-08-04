Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id 71F0F6B0035
	for <linux-mm@kvack.org>; Mon,  4 Aug 2014 18:21:02 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id r2so7955786igi.4
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 15:21:02 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p10si672853igx.56.2014.08.04.15.21.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Aug 2014 15:21:01 -0700 (PDT)
Date: Mon, 4 Aug 2014 15:20:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] faultaround updates
Message-Id: <20140804152059.fc9effe1989072d37214ab7f@linux-foundation.org>
In-Reply-To: <20140802083929.GA17045@node.dhcp.inet.fi>
References: <1406893869-32739-1-git-send-email-kirill.shutemov@linux.intel.com>
	<alpine.DEB.2.02.1408011432100.11532@chino.kir.corp.google.com>
	<20140802083929.GA17045@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org

On Sat, 2 Aug 2014 11:39:29 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Fri, Aug 01, 2014 at 02:32:36PM -0700, David Rientjes wrote:
> > On Fri, 1 Aug 2014, Kirill A. Shutemov wrote:
> > 
> > > One fix and one tweak for faultaround code.
> > > 
> > > As alternative, we could just drop debugfs interface and make
> > > fault_around_bytes constant.
> > > 
> > 
> > If we can remove the debugfs interface, then it seems better than 
> > continuing to support it.  Any objections to removing it?
> 
> Andrew asked it initially. Up to him.

Well, we had a bunch of magic constants in there which may not be
optimized.  The idea is to make them tunable so that interested parties
can determine the best settings without having to rebuild the kernel. 
Once that's all done we can remove the tunable (because it's debugfs)
and hard-wire the optimised constants.

But I don't think anyone has done this tuning work yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
