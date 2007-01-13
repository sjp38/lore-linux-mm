Date: Fri, 12 Jan 2007 17:11:16 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: High lock spin time for zone->lru_lock under extreme conditions
Message-Id: <20070112171116.a8f62ecb.akpm@osdl.org>
In-Reply-To: <20070113010039.GA8465@localhost.localdomain>
References: <20070112160104.GA5766@localhost.localdomain>
	<Pine.LNX.4.64.0701121137430.2306@schroedinger.engr.sgi.com>
	<20070112214021.GA4300@localhost.localdomain>
	<Pine.LNX.4.64.0701121341320.3087@schroedinger.engr.sgi.com>
	<20070113010039.GA8465@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ravikiran G Thirumalai <kiran@scalex86.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, "Shai Fultheim (Shai@scalex86.org)" <shai@scalex86.org>, pravin b shelar <pravin.shelar@calsoftinc.com>, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jan 2007 17:00:39 -0800
Ravikiran G Thirumalai <kiran@scalex86.org> wrote:

> But is
> lru_lock an issue is another question.

I doubt it, although there might be changes we can make in there to
work around it.

<mentions PAGEVEC_SIZE again>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
