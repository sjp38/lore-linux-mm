Date: Tue, 16 Jan 2007 10:51:56 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/29] Page Table Interface Explanation
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Message-ID: <Pine.LNX.4.64.0701161050330.30540@schroedinger.engr.sgi.com>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Davies <pauld@gelato.unsw.edu.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 13 Jan 2007, Paul Davies wrote:

> INSTRUCTIONS,BENCHMARKS and further information at the site below:

The benchmarks seem to be a mixed bag. Mostly up to the same speed, some 
minor improvements in some operations some minor regressions in others. If 
we cannot find any major regressions on other platforms then I would 
think that the patchset is acceptable on that ground.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
