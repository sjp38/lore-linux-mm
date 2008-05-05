Message-ID: <481EC917.6070808@bull.net>
Date: Mon, 05 May 2008 10:45:11 +0200
From: Nadia Derbey <Nadia.Derbey@bull.net>
MIME-Version: 1.0
Subject: Re: [PATCH 1/8] Scaling msgmni to the amount of lowmem
References: <20080211141646.948191000@bull.net>	 <20080211141813.354484000@bull.net> <12c511ca0804291328v2f0b87csd0f2cf3accc6ad00@mail.gmail.com>
In-Reply-To: <12c511ca0804291328v2f0b87csd0f2cf3accc6ad00@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com, akpm@linux-foundation.org, linux-mm@kvack.org, containers@lists.linux-foundation.org, matthltc@us.ibm.com, cmm@us.ibm.com
List-ID: <linux-mm.kvack.org>

Tony Luck wrote:
> On Mon, Feb 11, 2008 at 7:16 AM,  <Nadia.Derbey@bull.net> wrote:
> 
>> Index: linux-2.6.24-mm1/ipc/msg.c
>> ===================================================================
>> --- linux-2.6.24-mm1.orig/ipc/msg.c     2008-02-07 15:02:29.000000000 +0100
>> +++ linux-2.6.24-mm1/ipc/msg.c  2008-02-07 15:24:19.000000000 +0100
> 
> ...
> 
>> +out_callback:
>> +
>> +       printk(KERN_INFO "msgmni has been set to %d for ipc namespace %p\n",
>> +               ns->msg_ctlmni, ns);
>> +}
> 
> 
> This patch has now made its way to mainline.  I can see how this printk
> was really useful to you while developing this patch. But does it add
> much value in a production system? It just looks like another piece of
> clutter on the console to my uncontainerized eyes.
> 
> -Tony
> 
> 


Well, this printk had been suggested by somebody (sorry I don't remember 
who) when I first submitted the patch. Actually I think it might be 
useful for a sysadmin to be aware of a change in the msgmni value: we 
have the message not only at boot time, but also each time msgmni is 
recomputed because of a change in the amount of memory.
Also, at boot time, I think it's interesting to have the actual msgmni 
value: it used to unconditionally be set to 16. Some applications that 
used to need an initialization script setting msgmni to a higher value 
might not need that script anymore, since the new value might fit their 
needs.

Regards,
Nadia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
