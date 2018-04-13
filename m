Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 49A4C6B0005
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:23:24 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id v11-v6so2792834plo.14
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 03:23:24 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 75si3780465pga.647.2018.04.13.03.23.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 13 Apr 2018 03:23:23 -0700 (PDT)
Date: Fri, 13 Apr 2018 03:23:21 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: Requesting to share current work items
Message-ID: <20180413102321.GA32172@bombadil.infradead.org>
References: <CADYJ94f8ObREJu7pW9zWqtTCuiT2TygjWA7n1Uv-8YC7aehDAw@mail.gmail.com>
 <20180406205828.GA9618@bombadil.infradead.org>
 <6b35abac-1939-96af-4fc9-639525eaa311@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6b35abac-1939-96af-4fc9-639525eaa311@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: Chandan Vn <vn.chandan@gmail.com>, linux-mm@kvack.org

On Fri, Apr 13, 2018 at 02:45:46PM +0530, Anshuman Khandual wrote:
> On 04/07/2018 02:28 AM, Matthew Wilcox wrote:
> > On Fri, Apr 06, 2018 at 07:20:47AM +0000, Chandan Vn wrote:
> >> Hi,
> >>
> >> I would like to start contributing to linux-mm community.
> >> Could you please let me know the current work items which I can start
> >> working on.
> >>
> >> Please note that I have been working on linux-mm from past 4 years but
> >> mostly proprietary or not yet mainlined vendor codebase.
> > 
> > We had a report of a problem a few weeks ago that I don't know if anybody
> > is looking at yet.  Perhaps you'd like to try fixing it.
> 
> Do you have any reference or link to the bug report some where ?

https://marc.info/?l=linux-mm&m=151972700711879&w=2
