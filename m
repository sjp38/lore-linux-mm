Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC59C8E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 13:05:03 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id r130-v6so4392534pgr.13
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 10:05:03 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id e10-v6si26848291pln.161.2018.09.20.10.05.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Sep 2018 10:05:02 -0700 (PDT)
Date: Thu, 20 Sep 2018 11:04:58 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v4 0/3] docs/core-api: add memory allocation guide
Message-ID: <20180920110458.07d5a1c7@lwn.net>
In-Reply-To: <20180920042930.GA19495@rapoport-lnx>
References: <1536917278-31191-1-git-send-email-rppt@linux.vnet.ibm.com>
	<20180920042930.GA19495@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>, Randy Dunlap <rdunlap@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, 20 Sep 2018 07:29:30 +0300
Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> Ping?
> 
> On Fri, Sep 14, 2018 at 12:27:55PM +0300, Mike Rapoport wrote:
> > Hi,
> > 
> > As Vlastimil mentioned at [1], it would be nice to have some guide about
> > memory allocation. This set adds such guide that summarizes the "best
> > practices". 
> > 
> > The changes from the RFC include additions and corrections from Michal and
> > Randy. I've also added markup to cross-reference the kernel-doc
> > documentation.
> > 
> > I've split the patch into three to separate labels addition to the exiting
> > files from the new contents.
> > 
> > v3 -> v4:
> >   * make GFP_*USER* description less confusing

Sorry...but it's been less than a week.  And this week has been ...
busy ...

Anyway, I've applied the set now, thanks.

jon
