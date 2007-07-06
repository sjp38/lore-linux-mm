Date: Fri, 6 Jul 2007 10:32:29 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUGFIX][PATCH] DO flush icache before set_pte() on ia64.
In-Reply-To: <20070705125427.9a3b8e8b.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0707061032040.30575@schroedinger.engr.sgi.com>
References: <20070704150504.423f6c54.kamezawa.hiroyu@jp.fujitsu.com>
 <468B3EAA.9070905@yahoo.com.au> <20070704163826.d0b7465b.kamezawa.hiroyu@jp.fujitsu.com>
 <468C51A7.3070505@yahoo.com.au> <20070705114726.2449f270.kamezawa.hiroyu@jp.fujitsu.com>
 <468C634D.9050306@yahoo.com.au> <20070705125427.9a3b8e8b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, "tony.luck@intel.com" <tony.luck@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Mike.stroya@hp.com, GOTO <y-goto@jp.fujitsu.com>, dmosberger@gmail.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

I am a bit worried about the performance impact of all this flushing? What 
is the worst case scenario here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
