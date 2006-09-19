Date: Tue, 19 Sep 2006 08:39:23 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] mm: exempt pcp alloc from watermarks
In-Reply-To: <1158678324.23551.62.camel@twins>
Message-ID: <Pine.LNX.4.64.0609190838200.5034@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
 <20060914220011.2be9100a.akpm@osdl.org>  <20060914234926.9b58fd77.pj@sgi.com>
  <20060915002325.bffe27d1.akpm@osdl.org>  <20060915012810.81d9b0e3.akpm@osdl.org>
  <20060915203816.fd260a0b.pj@sgi.com>  <20060915214822.1c15c2cb.akpm@osdl.org>
  <20060916043036.72d47c90.pj@sgi.com>  <20060916081846.e77c0f89.akpm@osdl.org>
  <20060917022834.9d56468a.pj@sgi.com> <450D1A94.7020100@yahoo.com.au>
 <20060917041525.4ddbd6fa.pj@sgi.com> <450D434B.4080702@yahoo.com.au>
 <20060917061922.45695dcb.pj@sgi.com>  <450D5310.50004@yahoo.com.au>
 <1158583495.23551.53.camel@twins>  <45100028.90109@yahoo.com.au>
 <1158677483.23551.59.camel@twins>  <4510086C.4020101@yahoo.com.au>
 <1158678324.23551.62.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Paul Jackson <pj@sgi.com>, akpm@osdl.org, linux-mm@kvack.org, rientjes@google.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Nick, note that there is a PF_xx-flag that shows you if a process needs to 
consider policies and cpusets. Maybe checking that would allow a fast 
path.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
