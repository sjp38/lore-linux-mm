Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id AFB996B0047
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 07:47:06 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id 19so179222fgg.8
        for <linux-mm@kvack.org>; Fri, 05 Mar 2010 04:47:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100305062002.GV8653@laptop>
References: <alpine.DEB.2.00.1002240949140.26771@router.home>
	 <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1002251228140.18861@router.home>
	 <20100226114136.GA16335@basil.fritz.box>
	 <alpine.DEB.2.00.1002260904311.6641@router.home>
	 <20100226155755.GE16335@basil.fritz.box>
	 <alpine.DEB.2.00.1002261123520.7719@router.home>
	 <alpine.DEB.2.00.1002261555030.32111@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1003010224170.26824@chino.kir.corp.google.com>
	 <20100305062002.GV8653@laptop>
Date: Fri, 5 Mar 2010 14:47:04 +0200
Message-ID: <c1fb08351003050447w17175bbdy15e1e9bb78c2e40@mail.gmail.com>
Subject: Re: [patch] slab: add memory hotplug support
From: Anca Emanuel <anca.emanuel@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "haicheng.li" <haicheng.li@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Dumb question: it is possible to hot remove the (bad) memory ? And add
an good one ?
Where is the detection code for the bad module ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
