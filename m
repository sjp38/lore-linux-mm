Date: Tue, 20 Jun 2006 18:07:18 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 0/3] 2.6.17 radix-tree: updates and lockless
In-Reply-To: <1150850849.12507.10.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0606201806350.14643@schroedinger.engr.sgi.com>
References: <20060408134635.22479.79269.sendpatchset@linux.site>
 <20060620153555.0bd61e7b.akpm@osdl.org>  <1150844989.1901.52.camel@localhost.localdomain>
  <20060620163037.6ff2c8e7.akpm@osdl.org>  <1150847428.1901.60.camel@localhost.localdomain>
  <Pine.LNX.4.64.0606201732580.14331@schroedinger.engr.sgi.com>
 <1150850849.12507.10.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andrew Morton <akpm@osdl.org>, npiggin@suse.de, Paul.McKenney@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Jun 2006, Benjamin Herrenschmidt wrote:

> No, our hardware interrupt numbers are an encoded form containing the
> geographical location of the device :) so they are 24 bits at least (and
> we have a platform coming where they can be 64 bits).

PICs with build in GPSses? And I thought we had weird hardware....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
