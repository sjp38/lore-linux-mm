From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v7)
Date: Thu, 3 Apr 2008 11:30:00 -0700
Message-ID: <6599ad830804031130s666368a8v2b31ee6db493b501@mail.gmail.com>
References: <20080403174433.26356.42121.sendpatchset@localhost.localdomain>
	 <1207247113.21922.63.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758483AbYDCSa3@vger.kernel.org>
In-Reply-To: <1207247113.21922.63.camel@nimitz.home.sr71.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

On Thu, Apr 3, 2008 at 11:25 AM, Dave Hansen <dave@linux.vnet.ibm.com> wrote:
>  > +     /*
>  > +      * Search through everything else. We should not get
>  > +      * here often
>  > +      */
>  > +     do_each_thread(g, c) {
>  > +             if (c->mm == mm)
>  > +                     goto assign_new_owner;
>  > +     } while_each_thread(g, c);
>
>  What is the case in which we get here?  Threading that's two deep where
>  none of the immeidate siblings or children is still alive?

Probably the most likely case of this would be a LinuxThreads process
where the manager thread exits, and then the main thread, while other
threads still exist.

Paul
