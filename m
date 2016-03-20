Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id E32BF830AE
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 15:07:27 -0400 (EDT)
Received: by mail-pf0-f173.google.com with SMTP id n5so237889834pfn.2
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 12:07:27 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id be6si13514511pad.69.2016.03.20.12.07.22
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 12:07:22 -0700 (PDT)
Date: Sun, 20 Mar 2016 22:07:14 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 01/71] arc: get rid of PAGE_CACHE_* and
 page_cache_{get,release} macros
Message-ID: <20160320190714.GA1907@black.fi.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1458499278-1516-2-git-send-email-kirill.shutemov@linux.intel.com>
 <CA+55aFzSqbT+wQFmpaF+g8snk4AZ7oW7dheOUeqJq2qA5tytrw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFzSqbT+wQFmpaF+g8snk4AZ7oW7dheOUeqJq2qA5tytrw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Matthew Wilcox <willy@linux.intel.com>, Vineet Gupta <vgupta@synopsys.com>, linux-mm <linux-mm@kvack.org>

On Sun, Mar 20, 2016 at 11:54:56AM -0700, Linus Torvalds wrote:
> I'm OK with this, but let's not do this as a hundred small patches, OK?
> 
> It doesn't help legibility or testing, so let's just do it in one big go.

Okay, here's folded version of the patchset.
