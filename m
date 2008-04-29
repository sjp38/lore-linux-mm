Received: by mu-out-0910.google.com with SMTP id w9so9268mue.6
        for <linux-mm@kvack.org>; Tue, 29 Apr 2008 13:28:14 -0700 (PDT)
Message-ID: <12c511ca0804291328v2f0b87csd0f2cf3accc6ad00@mail.gmail.com>
Date: Tue, 29 Apr 2008 13:28:14 -0700
From: "Tony Luck" <tony.luck@intel.com>
Subject: Re: [PATCH 1/8] Scaling msgmni to the amount of lowmem
In-Reply-To: <20080211141813.354484000@bull.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080211141646.948191000@bull.net>
	 <20080211141813.354484000@bull.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nadia.Derbey@bull.net
Cc: linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com, akpm@linux-foundation.org, linux-mm@kvack.org, containers@lists.linux-foundation.org, matthltc@us.ibm.com, cmm@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2008 at 7:16 AM,  <Nadia.Derbey@bull.net> wrote:
>  Index: linux-2.6.24-mm1/ipc/msg.c
>  ===================================================================
>  --- linux-2.6.24-mm1.orig/ipc/msg.c     2008-02-07 15:02:29.000000000 +0100
>  +++ linux-2.6.24-mm1/ipc/msg.c  2008-02-07 15:24:19.000000000 +0100
...
>  +out_callback:
>  +
>  +       printk(KERN_INFO "msgmni has been set to %d for ipc namespace %p\n",
>  +               ns->msg_ctlmni, ns);
>  +}

This patch has now made its way to mainline.  I can see how this printk
was really useful to you while developing this patch. But does it add
much value in a production system? It just looks like another piece of
clutter on the console to my uncontainerized eyes.

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
