Date: Tue, 12 Jun 2007 12:04:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Add populated_map to account for memoryless nodes
Message-Id: <20070612120446.8a75b238.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0706111952580.25390@schroedinger.engr.sgi.com>
References: <20070611202728.GD9920@us.ibm.com>
	<20070612112757.e2d511e0.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706111952580.25390@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007 19:53:10 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> > Thank you, I like this work.
> > 
> > > +extern nodemask_t node_populated_map;
> > please add /* node has memory */ here.
> > 
> > I don't think "populated node" means "node-with-memory" if there is no comments.
> 
> What else could it mean?
> 
"a node has cpu(s) or device(s)" is not populated ?

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
