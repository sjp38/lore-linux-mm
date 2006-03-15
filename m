Message-ID: <441863AC.6050101@argo.co.il>
Date: Wed, 15 Mar 2006 20:57:48 +0200
From: Avi Kivity <avi@argo.co.il>
MIME-Version: 1.0
Subject: Re: [PATCH/RFC] AutoPage Migration - V0.1 - 0/8 Overview
References: <1142019195.5204.12.camel@localhost.localdomain>	<20060311154113.c4358e40.kamezawa.hiroyu@jp.fujitsu.com>	<1142270857.5210.50.camel@localhost.localdomain>	<Pine.LNX.4.64.0603131541330.13713@schroedinger.engr.sgi.com>	<44183B64.3050701@argo.co.il>	<20060315095426.b70026b8.pj@sgi.com>	<Pine.LNX.4.64.0603151008570.27212@schroedinger.engr.sgi.com> <20060315101402.3b19330c.pj@sgi.com>
In-Reply-To: <20060315101402.3b19330c.pj@sgi.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, lee.schermerhorn@hp.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:

>>a page if a certain mapcount is reached.
>>    
>>
>
>He said "accessed", not "referenced".
>
>The point was to copy pages that receive many
>load and store instructions from far away nodes.
>
>  
>
Only loads, please. Writable pages should not be duplicated.

>This has only minimal to do with the number of
>memory address spaces mapping the region
>holding that page.
>
>  
>

For starters, you could indicate which files need duplication manually. 
You would duplicate your main binaries and associated shared objects. 
Presumably large numas have plenty of memory so over-duplication would 
not be a huge problem.

Is the kernel text duplicated?

-- 
Do not meddle in the internals of kernels, for they are subtle and quick to panic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
