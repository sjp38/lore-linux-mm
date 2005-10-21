Date: Fri, 21 Oct 2005 08:47:42 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 4/4] Swap migration V3: sys_migrate_pages interface
In-Reply-To: <20051021081553.50716b97.pj@sgi.com>
Message-ID: <Pine.LNX.4.62.0510210845140.23212@schroedinger.engr.sgi.com>
References: <20051020225935.19761.57434.sendpatchset@schroedinger.engr.sgi.com>
 <20051020225955.19761.53060.sendpatchset@schroedinger.engr.sgi.com>
 <4358588D.1080307@jp.fujitsu.com> <Pine.LNX.4.61.0510210901380.17098@openx3.frec.bull.fr>
 <435896CA.1000101@jp.fujitsu.com> <20051021081553.50716b97.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Simon.Derr@bull.net, akpm@osdl.org, kravetz@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, magnus.damm@gmail.com, marcelo.tosatti@cyclades.com
List-ID: <linux-mm.kvack.org>

On Fri, 21 Oct 2005, Paul Jackson wrote:

>  * Christoph - what is the permissions check on sys_migrate_pages()?
>    It would seem inappropriate for 'guest' to be able to move the
>    memory of 'root'.

The check is missing. 

Maybe we could add:

 if (!capable(CAP_SYS_RESOURCE))
                return -EPERM;

Then we may also decide that root can move any process anywhere and drop 
the retrieval of the mems_allowed from the other task.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
