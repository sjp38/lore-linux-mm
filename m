Date: Wed, 13 Jun 2007 16:26:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/3] Fix GFP_THISNODE behavior for memoryless nodes
In-Reply-To: <20070613232005.GY3798@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706131626250.698@schroedinger.engr.sgi.com>
References: <20070612204843.491072749@sgi.com> <20070612205738.548677035@sgi.com>
 <1181769033.6148.116.camel@localhost> <Pine.LNX.4.64.0706131535200.32399@schroedinger.engr.sgi.com>
 <20070613231153.GW3798@us.ibm.com> <Pine.LNX.4.64.0706131613050.394@schroedinger.engr.sgi.com>
 <20070613232005.GY3798@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Wed, 13 Jun 2007, Nishanth Aravamudan wrote:

> Who the heck said anything about mainline?

Well we do have discovered issues that are bugs. Handling of memoryless 
nodes is rather strange.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
