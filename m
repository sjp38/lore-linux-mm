Date: Thu, 16 Aug 2007 14:13:44 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC] memoryless nodes - fixup uses of node_online_map in
 generic code
In-Reply-To: <1187298621.5900.64.camel@localhost>
Message-ID: <Pine.LNX.4.64.0708161412100.18530@schroedinger.engr.sgi.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
 <20070727194322.18614.68855.sendpatchset@localhost>
 <20070731192241.380e93a0.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
 <20070731200522.c19b3b95.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
 <20070731203203.2691ca59.akpm@linux-foundation.org>  <1185977011.5059.36.camel@localhost>
  <Pine.LNX.4.64.0708011037510.20795@schroedinger.engr.sgi.com>
 <1186085994.5040.98.camel@localhost>  <Pine.LNX.4.64.0708021323390.9711@schroedinger.engr.sgi.com>
  <1186611582.5055.95.camel@localhost>  <Pine.LNX.4.64.0708081638270.17335@schroedinger.engr.sgi.com>
 <1187298621.5900.64.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, ak@suse.de, linux-mm@kvack.org, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

I wonder if we could also add some /proc field to display the mask?

Something like

/proc/numainfo

Which contains

Online:	<nodelist>
Possible: <nodelist>
Regular memory: <nodelist>
High memory: <nodelist>

?

That way user space can figure out what is possible on each node.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
