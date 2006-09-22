Date: Fri, 22 Sep 2006 09:26:31 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060922092631.ae24a777.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.63.0609211510130.17417@chino.corp.google.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
	<20060914234926.9b58fd77.pj@sgi.com>
	<20060915002325.bffe27d1.akpm@osdl.org>
	<20060915004402.88d462ff.pj@sgi.com>
	<20060915010622.0e3539d2.akpm@osdl.org>
	<Pine.LNX.4.63.0609151601230.9416@chino.corp.google.com>
	<Pine.LNX.4.63.0609161734220.16748@chino.corp.google.com>
	<20060917041707.28171868.pj@sgi.com>
	<Pine.LNX.4.64.0609170540020.14516@schroedinger.engr.sgi.com>
	<20060917060358.ac16babf.pj@sgi.com>
	<Pine.LNX.4.63.0609171329540.25459@chino.corp.google.com>
	<20060917152723.5bb69b82.pj@sgi.com>
	<Pine.LNX.4.63.0609171643340.26323@chino.corp.google.com>
	<20060917192010.cc360ece.pj@sgi.com>
	<20060918093434.e66b8887.pj@sgi.com>
	<Pine.LNX.4.63.0609191222310.7790@chino.corp.google.com>
	<Pine.LNX.4.63.0609211510130.17417@chino.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: clameter@sgi.com, akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks for taking a shot at this.

David wrote:
> +	if (numa_emu_enabled)
> +		return 10;

The topology.h header has:
> #define LOCAL_DISTANCE               10

though -no-one- uses it, why I don't know ...

This simple forcing of distances to 10 is probably good enough for your
setup, but if this gets serious, we'll need to handle multiple arch's,
and hybrid systems with both fake and real numa.  That will take a bit
of work to get the SLIT table, node_distance and zonelist sorting
correct.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
