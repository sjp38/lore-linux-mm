From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC] My research agenda for 2.7
Date: Sun, 29 Jun 2003 01:18:18 +0200
References: <200306250111.01498.phillips@arcor.de> <200306282354.43153.phillips@arcor.de> <20030629220756.GB26348@holomorphy.com>
In-Reply-To: <20030629220756.GB26348@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200306290118.18266.phillips@arcor.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Mel Gorman <mel@csn.ul.ie>, "Martin J. Bligh" <mbligh@aracnet.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Monday 30 June 2003 00:07, William Lee Irwin III wrote:
> On Sunday 29 June 2003 23:26, Mel Gorman wrote:
> > ...I will occupy myself with the
> > gritty details of how to move pages without making the system crater.
>
> This sounds like it's behind dependent on physically scanning slabs,
> since one must choose slab pages for replacement on the basis of their
> potential to restore contiguity, not merely "dump whatever's replaceable
> and check how much got freed".

Though I'm not sure what "behind dependent" means, and I'm not the one 
advocating slab for this, it's quite correct that scanning strategy would 
need to change, at least when the system runs into cross-order imbalances.  
But this isn't much different from the kinds of things we do already.

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
