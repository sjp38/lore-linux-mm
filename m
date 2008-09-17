Date: Wed, 17 Sep 2008 14:28:05 -0400
From: Rik van Riel <riel@redhat.com>
Subject: Re: Populating multiple ptes at fault time
Message-ID: <20080917142805.41e2b07e@bree.surriel.com>
In-Reply-To: <48D142B2.3040607@goop.org>
References: <48D142B2.3040607@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Hugh Dickens <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Sep 2008 10:47:30 -0700
Jeremy Fitzhardinge <jeremy@goop.org> wrote:

> Minor faults are easier; if the page already exists in memory, we should
> just create mappings to it.  If neighbouring pages are also already
> present, then we can can cheaply create mappings for them too.

This is especially true for mmaped files, where we do not have to
allocate anything to create the mapping.

Populating multiple PTEs at a time is questionable for anonymous
memory, where we'd have to allocate extra pages.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
