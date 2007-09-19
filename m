Date: Wed, 19 Sep 2007 12:06:44 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 8/8] oom: do not check cpuset in badness scoring
In-Reply-To: <alpine.DEB.0.9999.0709190352030.23538@chino.kir.corp.google.com>
Message-ID: <Pine.LNX.4.64.0709191206120.2241@schroedinger.engr.sgi.com>
References: <alpine.DEB.0.9999.0709181950170.25510@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350001.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350240.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350410.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190350560.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190351140.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190351290.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190351460.23538@chino.kir.corp.google.com>
 <alpine.DEB.0.9999.0709190352030.23538@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Sep 2007, David Rientjes wrote:

> It is no longer necessary to check whether a task's cpuset nodes overlap
> with current because the tasklist has already been filtered with respect
> to zones shared in the zonelist.

I doubt it. You would have to scan over all pages mapped by a process and 
build zonelists to check that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
