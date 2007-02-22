Date: Wed, 21 Feb 2007 16:06:04 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Take anonymous pages off the LRU if we have no swap
In-Reply-To: <45DCD309.5010109@redhat.com>
Message-ID: <Pine.LNX.4.64.0702211600430.28364@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702211409001.27422@schroedinger.engr.sgi.com>
 <45DCD309.5010109@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Feb 2007, Rik van Riel wrote:

> I am working on a VM design that would take care of this issue in
> a somewhat cleaner way.  I'm writing up the bits and pieces as I
> find easy ways to explain them.
>
> Want to help out with brainstorming and implementing?
> 
> http://linux-mm.org/PageReplacementDesign

I do not see how this issue would be solved there. Sounds like an attempt 
to come up with requirements and some design ideas.

The patch here is just the leftover from last weeks discussion in which 
the ability to remove anonymous pages was requested. Which can be done
in the limited form presented here within the current code in mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
