From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC 5/8] Make writeout during reclaim cpuset aware
Date: Wed, 17 Jan 2007 09:07:14 +1100
References: <20070116054743.15358.77287.sendpatchset@schroedinger.engr.sgi.com> <20070116054809.15358.22246.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070116054809.15358.22246.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200701170907.14670.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Dave Chinner <dgc@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 16 January 2007 16:48, Christoph Lameter wrote:
> Direct reclaim: cpuset aware writeout
>
> During direct reclaim we traverse down a zonelist and are carefully
> checking each zone if its a member of the active cpuset. But then we call
> pdflush without enforcing the same restrictions. In a larger system this
> may have the effect of a massive amount of pages being dirtied and then
> either

Is there a reason this can't be just done by node, ignoring the cpusets? 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
