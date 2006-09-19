Date: Tue, 19 Sep 2006 14:50:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
In-Reply-To: <Pine.LNX.4.64.0609191424310.7480@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.63.0609191446420.8493@chino.corp.google.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org> <20060914234926.9b58fd77.pj@sgi.com>
 <20060915002325.bffe27d1.akpm@osdl.org> <20060915004402.88d462ff.pj@sgi.com>
 <20060915010622.0e3539d2.akpm@osdl.org> <Pine.LNX.4.63.0609151601230.9416@chino.corp.google.com>
 <Pine.LNX.4.63.0609161734220.16748@chino.corp.google.com>
 <20060917041707.28171868.pj@sgi.com> <Pine.LNX.4.64.0609170540020.14516@schroedinger.engr.sgi.com>
 <20060917060358.ac16babf.pj@sgi.com> <Pine.LNX.4.63.0609171329540.25459@chino.corp.google.com>
 <20060917152723.5bb69b82.pj@sgi.com> <Pine.LNX.4.63.0609171643340.26323@chino.corp.google.com>
 <20060917192010.cc360ece.pj@sgi.com> <20060918093434.e66b8887.pj@sgi.com>
 <Pine.LNX.4.63.0609191222310.7790@chino.corp.google.com>
 <Pine.LNX.4.64.0609191424310.7480@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Paul Jackson <pj@sgi.com>, akpm@osdl.org, linux-mm@kvack.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

On Tue, 19 Sep 2006, Christoph Lameter wrote:

> I think that is true if you do not do weird things like creating 64 of 
> those containers on UMA. Or do you anticipate having hundreds of 
> containers?
> 

What I currently have running is a watered-down version of your suggestion 
about dynamic node allocation.  It does it in user-space by just 
allocating N number of fixed sized nodes and then when a particular cpuset 
feels memory pressure, it grabs another node and uses it until it is no 
longer needed.  It's a way that you can get simple resource management and 
throttle up processes that a more important.  This is how I've used NUMA 
emulation and cpusets to match a business goal of achieving certain 
objectives with a system goal in the form of limits.

Obviously it's not the most efficient way of handling such a policy and an 
implementation such as the one you've proposed that is supported by the 
kernel would be much more desirable.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
