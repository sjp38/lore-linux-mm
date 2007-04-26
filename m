Date: Thu, 26 Apr 2007 09:40:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] syctl for selecting global zonelist[] order
Message-Id: <20070426094051.0f3c5875.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070426093112.ec2ecb00.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070425121946.9eb27a79.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0704251211070.17886@schroedinger.engr.sgi.com>
	<20070426093112.ec2ecb00.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: clameter@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 26 Apr 2007 09:31:12 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > So a IA64 platform with i386 sicknesses? And pretty bad case of it since I 
> > assume that the memory sizes per node are equal. Your solution of taking 
> > 4G off node 0 and then going to node 1 first must hurt some 
> > processes running on node 0. 
> I think so, too. It is because I made this as selectable option.
                        ^^^^^^^^^
                         why...

sorry.
-Kame                  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
