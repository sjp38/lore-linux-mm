Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m7KGffa9006012
	for <linux-mm@kvack.org>; Wed, 20 Aug 2008 12:41:41 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7KGcvFl231966
	for <linux-mm@kvack.org>; Wed, 20 Aug 2008 12:38:57 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7KGcui1028106
	for <linux-mm@kvack.org>; Wed, 20 Aug 2008 12:38:57 -0400
Subject: Re: [discuss] memrlimit - potential applications that can use
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <a2776ec50808200625m5f6d9e6fs4d8e594bd259115a@mail.gmail.com>
References: <48AA73B5.7010302@linux.vnet.ibm.com>
	 <1219161525.23641.125.camel@nimitz>  <48AAF8C0.1010806@linux.vnet.ibm.com>
	 <1219167669.23641.156.camel@nimitz>
	 <a2776ec50808200625m5f6d9e6fs4d8e594bd259115a@mail.gmail.com>
Content-Type: text/plain
Date: Wed, 20 Aug 2008 09:38:54 -0700
Message-Id: <1219250334.8960.30.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: righiandr@users.sourceforge.net
Cc: balbir@linux.vnet.ibm.com, Paul Menage <menage@google.com>, Dave Hansen <haveblue@us.ibm.com>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Marco Sbrighi <m.sbrighi@cineca.it>, Linux Memory Management List <linux-mm@kvack.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2008-08-20 at 15:25 +0200, righi.andrea@gmail.com wrote:
> Memory overcommit protection, instead, is a way to *prevent* OOM
> conditions (problem 1).

I completely disagree. :)

Think of all the work Eric Biederman did on pid namespaces.  One of his
motivations was to keep /proc from being able to pin task structs.  That
is one great example of a way a process can pin lots of memory without
mapping it, and overcommit has no effect on this!

Eric had a couple of other good examples, but I think task structs were
the biggest.

As I said to Balbir, there probably are some large-scale solutions to
this: things like beancounters.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
