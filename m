Date: Tue, 25 Jul 2006 16:03:36 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mm: inactive-clean list
In-Reply-To: <44C68F0E.2050100@redhat.com>
Message-ID: <Pine.LNX.4.64.0607251600001.32387@schroedinger.engr.sgi.com>
References: <1153167857.31891.78.camel@lappy> <44C30E33.2090402@redhat.com>
 <Pine.LNX.4.64.0607241109190.25634@schroedinger.engr.sgi.com>
 <44C518D6.3090606@redhat.com> <Pine.LNX.4.64.0607251324140.30939@schroedinger.engr.sgi.com>
 <44C68F0E.2050100@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 25 Jul 2006, Rik van Riel wrote:

> > An increment of a VM counter causes a state change in the hypervisor?
> 
> Christoph, please read more than the first 5 words in each
> email before replying.

Well, I read the whole thing before I replied and I could not figure this 
one out. Maybe I am too dumb to understand. Could you please explain 
yourself in more detail

I am also not sure why I should be running a hypervisor in the first place 
and so I may not be up to date on the whole technology.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
