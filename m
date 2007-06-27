Date: Wed, 27 Jun 2007 15:13:34 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [patch 4/4] oom: serialize for cpusets
Message-Id: <20070627151334.9348be8e.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.64.0706271452580.31852@schroedinger.engr.sgi.com>
References: <alpine.DEB.0.99.0706261947490.24949@chino.kir.corp.google.com>
	<alpine.DEB.0.99.0706261949140.24949@chino.kir.corp.google.com>
	<alpine.DEB.0.99.0706261949490.24949@chino.kir.corp.google.com>
	<alpine.DEB.0.99.0706261950140.24949@chino.kir.corp.google.com>
	<Pine.LNX.4.64.0706271452580.31852@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: andrea@suse.de, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Paul have you seen this?

I saw it, but I'm up to my eyeballs in unrelated stuff,
and had to avoid thinking about it enough to be of any
use.

I did have this vague recollection that I had seen something
like this before, and it got shot down, because even tasks
in entirely nonoverlapping cpusets might be holding memory
resources on the nodes where we're running out of memory.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
