Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 216C36B00E5
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 13:39:30 -0400 (EDT)
Date: Thu, 21 Jun 2012 10:40:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm 4/7] mm: make page colouring code generic
Message-Id: <20120621104005.604fa9cc.akpm@linux-foundation.org>
In-Reply-To: <4FE33002.6040703@redhat.com>
References: <1340057126-31143-1-git-send-email-riel@redhat.com>
	<1340057126-31143-5-git-send-email-riel@redhat.com>
	<1340277624.21745.173.camel@twins>
	<4FE33002.6040703@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, aarcange@redhat.com, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>

On Thu, 21 Jun 2012 10:30:26 -0400 Rik van Riel <riel@redhat.com> wrote:

> On 06/21/2012 07:20 AM, Peter Zijlstra wrote:
> > On Mon, 2012-06-18 at 18:05 -0400, Rik van Riel wrote:
> >> Fix the x86-64 page colouring code to take pgoff into account.
> >
> > Shouldn't that be a separate patch?
> 
> My idea was that it would be easier to review
> these two nearly identical functions together.
> 
> Andrew, do you have any strong opinions?

It depends on the significance of the change.  I suspect it's one of
things which speeds up many workloads by 1.5% and slows down a few
weird/important ones by 11%.  Which makes it a thing to be put under
the microscope and poked at.  Some people might end up reverting it,
making it tunable/configurable etc etc.

If any of that is true then yes, I guess it should be a standalone thing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
