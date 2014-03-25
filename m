Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id F28126B003B
	for <linux-mm@kvack.org>; Tue, 25 Mar 2014 12:18:00 -0400 (EDT)
Received: by mail-ig0-f175.google.com with SMTP id ur14so11070439igb.2
        for <linux-mm@kvack.org>; Tue, 25 Mar 2014 09:18:00 -0700 (PDT)
Received: from qmta04.emeryville.ca.mail.comcast.net (qmta04.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:40])
        by mx.google.com with ESMTP id nx5si19985694icb.134.2014.03.25.09.18.00
        for <linux-mm@kvack.org>;
        Tue, 25 Mar 2014 09:18:00 -0700 (PDT)
Date: Tue, 25 Mar 2014 11:17:57 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Bug in reclaim logic with exhausted nodes?
In-Reply-To: <20140324230550.GB18778@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.10.1403251116490.16557@nuc>
References: <20140311210614.GB946@linux.vnet.ibm.com> <20140313170127.GE22247@linux.vnet.ibm.com> <20140324230550.GB18778@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nishanth Aravamudan <nacc@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, rientjes@google.com, linuxppc-dev@lists.ozlabs.org, anton@samba.org, mgorman@suse.de

On Mon, 24 Mar 2014, Nishanth Aravamudan wrote:

> Anyone have any ideas here?

Dont do that? Check on boot to not allow exhausting a node with huge
pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
