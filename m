Date: Wed, 13 Oct 2004 05:33:40 +1000
From: Anton Blanchard <anton@samba.org>
Subject: Re: NUMA: Patch for node based swapping
Message-ID: <20041012193340.GA3315@krispykreme.ozlabs.ibm.com>
References: <Pine.LNX.4.58.0410120751010.11558@schroedinger.engr.sgi.com> <Pine.LNX.4.44.0410121126390.13693-100000@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0410121126390.13693-100000@chimarrao.boston.redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel@vger.kernel.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 
> That sounds like an extraordinarily bad idea for eg. AMD64
> systems, which have a very low numa factor.

Same with ppc64.

Anton
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
