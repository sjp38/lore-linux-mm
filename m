Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A94CC6B0047
	for <linux-mm@kvack.org>; Wed,  3 Mar 2010 10:50:20 -0500 (EST)
Date: Wed, 3 Mar 2010 09:46:34 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] slab: add memory hotplug support
In-Reply-To: <20100303143450.GA25500@basil.fritz.box>
Message-ID: <alpine.DEB.2.00.1003030946140.17922@router.home>
References: <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com> <alpine.DEB.2.00.1002251228140.18861@router.home> <20100226114136.GA16335@basil.fritz.box> <alpine.DEB.2.00.1002260904311.6641@router.home> <20100226155755.GE16335@basil.fritz.box>
 <alpine.DEB.2.00.1002261123520.7719@router.home> <alpine.DEB.2.00.1002261555030.32111@chino.kir.corp.google.com> <alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com> <20100302125306.GD19208@basil.fritz.box> <84144f021003020704s3abafc24t9b8ab34234094b79@mail.gmail.com>
 <20100303143450.GA25500@basil.fritz.box>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 3 Mar 2010, Andi Kleen wrote:

> > But anyway, if you have real technical concerns over the patch, please
> > make them known; otherwise I'd much appreciate a Tested-by tag from
> > you for David's patch.
>
> If it works it would be ok for me. The main concern would be to actually
> get it fixed.

You do not have a testcase? This is a result of code review?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
