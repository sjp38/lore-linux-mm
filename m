Message-ID: <43590789.1070309@jp.fujitsu.com>
Date: Sat, 22 Oct 2005 00:21:45 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] Swap migration V3: sys_migrate_pages interface
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com>	<20051020225955.19761.53060.sendpatchset@schroedinger.engr.sgi.com>	<4358588D.1080307@jp.fujitsu.com>	<Pine.LNX.4.61.0510210901380.17098@openx3.frec.bull.fr>	<435896CA.1000101@jp.fujitsu.com> <20051021081553.50716b97.pj@sgi.com>
In-Reply-To: <20051021081553.50716b97.pj@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Simon.Derr@bull.net, clameter@sgi.com, akpm@osdl.org, kravetz@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, magnus.damm@gmail.com, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
> I agree with Simon that sys_migrate_pages() does not want to get in
> the business of replicating the checks on updating mems_allowed that
> are in the cpuset code.
> 
Hm.. okay.
I'm just afraid of swapped-out pages will goes back to original nodes

-- Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
