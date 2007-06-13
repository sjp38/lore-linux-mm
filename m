Date: Wed, 13 Jun 2007 16:15:24 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/3] Fix GFP_THISNODE behavior for memoryless nodes
In-Reply-To: <20070613231153.GW3798@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706131613050.394@schroedinger.engr.sgi.com>
References: <20070612204843.491072749@sgi.com> <20070612205738.548677035@sgi.com>
 <1181769033.6148.116.camel@localhost> <Pine.LNX.4.64.0706131535200.32399@schroedinger.engr.sgi.com>
 <20070613231153.GW3798@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jun 2007, Nishanth Aravamudan wrote:

> I would like to roll up the patches and small fixes into a set of 4 or 5
> patches that Andrew can pick up, so once this is all stable, I'll post a
> fresh series. Sound good, Andrew?

NACK. This patchset is not ready for any inclusion and nothing like that 
should go into 2.6.22. We first need to assess the breakage that results 
if GFP_THISNODE now returns NULL for memoryless nodes. So far GFP_THISNODE 
returns memory on the nearest node and that seems to make lots of things 
keep working.

Plus the implementation of GFP_THISNODE that we have so far is a bit 
complex. It would be good if that could be simpler.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
