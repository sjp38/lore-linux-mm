Message-ID: <44183B64.3050701@argo.co.il>
Date: Wed, 15 Mar 2006 18:05:56 +0200
From: Avi Kivity <avi@argo.co.il>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC] AutoPage Migration - V0.1 - 0/8 Overview
References: <1142019195.5204.12.camel@localhost.localdomain>  <20060311154113.c4358e40.kamezawa.hiroyu@jp.fujitsu.com> <1142270857.5210.50.camel@localhost.localdomain> <Pine.LNX.4.64.0603131541330.13713@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0603131541330.13713@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:

>cpusets uses _MOVE_ALL because Paul wanted it that way. I still think it 
>is a bad idea to move shared libraries etc. _MOVE only moves the pages used
>by the currently executing process. If you do a MOVE_ALL then you may 
>cause delays in other processes because they have to wait for their pages 
>to become available again. Also they may have to generate additional 
>faults to restore their PTEs. So you are negatively impacting other 
>processes. Note that these wait times can be extensive if _MOVE_ALL is 
>f.e. just migrating a critical glibc page that all processes use.
>  
>
Doesn't it make sense to duplicate heavily accessed shared read-only pages?

Something like page migration, but keeping the original page intact. 
Unfortunately, for threaded applications, it means page table bases 
(cr3) can't be shared among threads.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
