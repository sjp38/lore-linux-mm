Message-ID: <4682A9B6.8070003@google.com>
Date: Wed, 27 Jun 2007 14:17:26 -0400
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: [RFC 1/7] cpuset write dirty map
References: <465FB6CF.4090801@google.com>	<Pine.LNX.4.64.0706041138410.24412@schroedinger.engr.sgi.com>	<46646A33.6090107@google.com>	<Pine.LNX.4.64.0706041250440.25535@schroedinger.engr.sgi.com>	<468023CA.2090401@google.com>	<Pine.LNX.4.64.0706261216110.20282@schroedinger.engr.sgi.com> <20070626152204.b6b4bc3f.akpm@google.com>
In-Reply-To: <20070626152204.b6b4bc3f.akpm@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@google.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> 
> One open question is the interaction between these changes and with Peter's
> per-device-dirty-throttling changes.  They also are in my queue somewhere. 

	I looked over it at one point. Most of the code doesn't conflict, but I
believe that the code path which calculates the dirty limits will need
some merging. Doable but non-trivial.
	-- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
