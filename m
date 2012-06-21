Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id E86AA6B00D1
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 10:31:56 -0400 (EDT)
Message-ID: <4FE33002.6040703@redhat.com>
Date: Thu, 21 Jun 2012 10:30:26 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 4/7] mm: make page colouring code generic
References: <1340057126-31143-1-git-send-email-riel@redhat.com>  <1340057126-31143-5-git-send-email-riel@redhat.com> <1340277624.21745.173.camel@twins>
In-Reply-To: <1340277624.21745.173.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com, minchan@gmail.com, kosaki.motohiro@gmail.com, andi@firstfloor.org, hannes@cmpxchg.org, mel@csn.ul.ie, linux-kernel@vger.kernel.org, Rik van Riel <riel@surriel.com>

On 06/21/2012 07:20 AM, Peter Zijlstra wrote:
> On Mon, 2012-06-18 at 18:05 -0400, Rik van Riel wrote:
>> Fix the x86-64 page colouring code to take pgoff into account.
>
> Shouldn't that be a separate patch?

My idea was that it would be easier to review
these two nearly identical functions together.

Andrew, do you have any strong opinions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
