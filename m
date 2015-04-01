Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4193F6B0038
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 07:51:01 -0400 (EDT)
Received: by wgbdm7 with SMTP id dm7so50471286wgb.1
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 04:51:00 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.195])
        by mx.google.com with ESMTP id d11si12223780wic.37.2015.04.01.04.50.58
        for <linux-mm@kvack.org>;
        Wed, 01 Apr 2015 04:50:59 -0700 (PDT)
Date: Wed, 1 Apr 2015 14:50:54 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: use PageAnon() and PageKsm() helpers in
 page_anon_vma()
Message-ID: <20150401115054.GB17153@node.dhcp.inet.fi>
References: <1427802647-16764-1-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.11.1503310810320.13959@gentwo.org>
 <20150331143534.GA10808@node.dhcp.inet.fi>
 <20150331133338.ed4ab6cc9a5ab6f6ad4301eb@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150331133338.ed4ab6cc9a5ab6f6ad4301eb@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, Konstantin Khlebnikov <koct9i@gmail.com>, Rik van Riel <riel@redhat.com>

On Tue, Mar 31, 2015 at 01:33:38PM -0700, Andrew Morton wrote:
> On Tue, 31 Mar 2015 17:35:34 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > On Tue, Mar 31, 2015 at 08:11:02AM -0500, Christoph Lameter wrote:
> > > On Tue, 31 Mar 2015, Kirill A. Shutemov wrote:
> > > 
> > > > Let's use PageAnon() and PageKsm() helpers instead. It helps readability
> > > > and makes page_anon_vma() work correctly on tail pages.
> > > 
> > > But it adds a branch due to the use of ||.
> > 
> > Which caller is hot enough to care?
> > 
> 
> It's a surprisingly expensive patch.
> 
>    text    data     bss     dec     hex filename
> 
>   19984    1153   15192   36329    8de9 mm/ksm.o-before
>   20028    1153   15216   36397    8e2d mm/ksm.o-after
> 
>   14728     116    5168   20012    4e2c mm/rmap.o-before
>   14763     116    5192   20071    4e67 mm/rmap.o-after
> 
>   25723    1417    9776   36916    9034 mm/swapfile.o-before
>   25769    1417    9800   36986    907a mm/swapfile.o-after
> 
> 197 bytes more text+bss, 125 bytes more text.
> 
> (Why the heck do changes like this allegedly affect bss size?)

What about this?
