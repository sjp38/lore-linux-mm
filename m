Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0066D6B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 15:45:23 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c5so1211221pfn.17
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 12:45:23 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p86si6580363pfi.223.2018.04.06.12.45.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Apr 2018 12:45:22 -0700 (PDT)
Date: Fri, 6 Apr 2018 12:45:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] swap: divide-by-zero when zero length swap file on ssd
Message-Id: <20180406124521.410dbe99dcb4b5dea483f46a@linux-foundation.org>
In-Reply-To: <fdca1f72-8e51-7727-d1a0-4ccd60e80bd0@infradead.org>
References: <5AC747C1020000A7001FA82C@prv-mh.provo.novell.com>
	<fdca1f72-8e51-7727-d1a0-4ccd60e80bd0@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Tom Abraham <tabraham@suse.com>, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On Fri, 6 Apr 2018 09:52:50 -0700 Randy Dunlap <rdunlap@infradead.org> wrote:

> [adding linux-mm and akpm]

Thanks.

> ...

The patch is a huge mess, with leading and trailing whitespace.  I
fixed all that up, but we'd like to receive Tom's signed-off-by:, please. 
Documentation/process/submitting-patches.rst section 11 has the
details.
