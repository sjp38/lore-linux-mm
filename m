Date: Thu, 6 Mar 2008 13:49:10 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/8] Kbuild: Create a way to create preprocessor constants
 from C expressions
In-Reply-To: <20080306210005.GB29026@uranus.ravnborg.org>
Message-ID: <Pine.LNX.4.64.0803061348250.15083@schroedinger.engr.sgi.com>
References: <20080305223815.574326323@sgi.com> <20080305223845.436523065@sgi.com>
 <20080305200800.23ee10ec.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0803061217240.14140@schroedinger.engr.sgi.com>
 <20080306210005.GB29026@uranus.ravnborg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Sam Ravnborg <sam@ravnborg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, ak@suse.de, Mel Gorman <mel@csn.ul.ie>, apw@shadowen.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 6 Mar 2008, Sam Ravnborg wrote:

> Ehh - the file above is empty.
> I do not understand why we need an empty file to be present???

Its going to be populated in later patches of the patchset.

> We better tell make so - updated patch below.

I am very thankful for your help.... Will try that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
