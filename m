Subject: Re: Audit of "all uses of node_online()"
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070802133341.74ce084a.akpm@linux-foundation.org>
References: <20070727194316.18614.36380.sendpatchset@localhost>
	 <20070727194322.18614.68855.sendpatchset@localhost>
	 <20070731192241.380e93a0.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
	 <20070731200522.c19b3b95.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
	 <20070731203203.2691ca59.akpm@linux-foundation.org>
	 <1185977011.5059.36.camel@localhost>
	 <Pine.LNX.4.64.0708011037510.20795@schroedinger.engr.sgi.com>
	 <1186085994.5040.98.camel@localhost>
	 <20070802133341.74ce084a.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Thu, 02 Aug 2007 16:45:35 -0400
Message-Id: <1186087535.5040.100.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-08-02 at 13:33 -0700, Andrew Morton wrote:
> On Thu, 02 Aug 2007 16:19:53 -0400
> Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> 
> > Note that the list includes a lot of architectural dependent files.
> > Shall I do a separate patch for each arch, so that arch maintainer can
> > focus on that [I assume they'll want to review], or a single "jumbo
> > patch" to reduce traffic?
> 
> Separate patches please, if they are independent.
> 
> Even if they are dependencies, a base patch plus a string of
> arch patches would be a nice presentation.
> 

Will do.  As I get to them.

I'll repost the file list with annotations as well.  I've already seen
that some files are probably OK as is.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
