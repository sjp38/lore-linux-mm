Subject: Re: [patch 0/3] 2.6.17 radix-tree: updates and lockless
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.64.0606201806350.14643@schroedinger.engr.sgi.com>
References: <20060408134635.22479.79269.sendpatchset@linux.site>
	 <20060620153555.0bd61e7b.akpm@osdl.org>
	 <1150844989.1901.52.camel@localhost.localdomain>
	 <20060620163037.6ff2c8e7.akpm@osdl.org>
	 <1150847428.1901.60.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0606201732580.14331@schroedinger.engr.sgi.com>
	 <1150850849.12507.10.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0606201806350.14643@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 21 Jun 2006 11:33:49 +1000
Message-Id: <1150853629.12507.55.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@osdl.org>, npiggin@suse.de, Paul.McKenney@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2006-06-20 at 18:07 -0700, Christoph Lameter wrote:
> On Wed, 21 Jun 2006, Benjamin Herrenschmidt wrote:
> 
> > No, our hardware interrupt numbers are an encoded form containing the
> > geographical location of the device :) so they are 24 bits at least (and
> > we have a platform coming where they can be 64 bits).
> 
> PICs with build in GPSses? And I thought we had weird hardware....

hehehe :) Well, domain/bus/slot number if you prefer but yeah, a GPS
would be much more cool !

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
