From: Andi Kleen <ak@suse.de>
Subject: Re: One idea to free up page flags on NUMA
Date: Sat, 23 Sep 2006 18:04:40 +0200
References: <Pine.LNX.4.64.0609221936520.13362@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0609221936520.13362@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200609231804.40348.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, haveblue@us.ibm.com
List-ID: <linux-mm.kvack.org>

 
> By that scheme we would win 6 bits on NUMAQ (32bit) 

NUMAsaurus is total legacy and I'm just waiting for the last one to die to 
remove the code ;-)

> and would save around  
> 20-30 bits on 64 bit machine.

And what would we use them for?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
