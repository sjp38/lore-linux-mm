Date: Fri, 21 Oct 2005 08:28:49 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 0/4] Swap migration V3: Overview
Message-Id: <20051021082849.45dafd27.pj@sgi.com>
In-Reply-To: <20051020234621.GL5490@w-mikek2.ibm.com>
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com>
	<20051020160638.58b4d08d.akpm@osdl.org>
	<20051020234621.GL5490@w-mikek2.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mike kravetz <kravetz@us.ibm.com>
Cc: akpm@osdl.org, clameter@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, magnus.damm@gmail.com, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

Mike wrote:
> Just to be clear, there are at least two distinct requirements for hotplug.
> One only wants to remove a quantity of memory (location unimportant). 

Could you describe this case a little more?  I wasn't aware
of this hotplug requirement, until I saw you comment just now.

The three reasons I knew of for wanting to move memory pages were:
 - offload some physical ram or node (avoid or unplug bad hardware)
 - task migration to another cpuset or moving an existing cpuset
 - various testing and performance motivations to optimize page location

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
