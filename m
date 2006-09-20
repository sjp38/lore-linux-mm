Date: Wed, 20 Sep 2006 09:26:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch00/05]: Containers(V2)- Introduction
In-Reply-To: <4510D3F4.1040009@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0609200925280.30572@schroedinger.engr.sgi.com>
References: <1158718568.29000.44.camel@galaxy.corp.google.com>
 <4510D3F4.1040009@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: rohitseth@google.com, CKRM-Tech <ckrm-tech@lists.sourceforge.net>, devel@openvz.org, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Sep 2006, Nick Piggin wrote:

> I'm not sure about containers & workload management people, but from
> a core mm/ perspective I see no reason why this couldn't get in,
> given review and testing. Great!

Nack. We already have the ability to manage workloads. We may want to 
extend the existing functionality but this is duplicating what is already 
available through cpusets.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
