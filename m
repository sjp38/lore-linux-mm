Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [PATCH 1/8] Scaling msgmni to the amount of lowmem
Date: Tue, 6 May 2008 09:42:25 -0700
Message-ID: <1FE6DD409037234FAB833C420AA843EC014392F9@orsmsx424.amr.corp.intel.com>
In-Reply-To: <481EC917.6070808@bull.net>
References: <20080211141646.948191000@bull.net>	 <20080211141813.354484000@bull.net> <12c511ca0804291328v2f0b87csd0f2cf3accc6ad00@mail.gmail.com> <481EC917.6070808@bull.net>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nadia Derbey <Nadia.Derbey@bull.net>
Cc: linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com, akpm@linux-foundation.org, linux-mm@kvack.org, containers@lists.linux-foundation.org, matthltc@us.ibm.com, cmm@us.ibm.com
List-ID: <linux-mm.kvack.org>

> Well, this printk had been suggested by somebody (sorry I don't remember 
> who) when I first submitted the patch. Actually I think it might be 
> useful for a sysadmin to be aware of a change in the msgmni value: we 
> have the message not only at boot time, but also each time msgmni is 
> recomputed because of a change in the amount of memory.

If the message is directed at the system administrator, then it would
be nice if there were some more meaningful way to show the namespace
that is affected than just printing the hex address of the kernel structure.

As the sysadmin for my test systems, printing the hex address is mildly
annoying ... I now have to add a new case to my scripts that look at
dmesg output for unusual activity.

Is there some better "name for a namespace" than the address? Perhaps
the process id of the process that instantiated the namespace???

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
