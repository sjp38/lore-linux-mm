Message-ID: <390192188.07822@ustc.edu.cn>
Date: Wed, 19 Sep 2007 16:56:25 +0800
From: Fengguang Wu <wfg@mail.ustc.edu.cn>
Subject: Re: [PATCH][RESEND] maps: PSS(proportional set size) accounting in
	smaps
Message-ID: <20070919085625.GA5910@mail.ustc.edu.cn>
References: <389996856.30386@ustc.edu.cn> <20070916235120.713c6102.akpm@linux-foundation.org> <20070917161027.GY4219@waste.org> <57d8e7a0709190137v3d90d8e4r40eb254b657e9a94@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57d8e7a0709190137v3d90d8e4r40eb254b657e9a94@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Berthels <jjberthels@gmail.com>
Cc: Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Denys Vlasenko <vda.linux@googlemail.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Sep 19, 2007 at 09:37:21AM +0100, John Berthels wrote:
[...]
> Also exmap (I don't know if pagemap does this) grovels through ELF and
> /proc/<pid>/maps so you can see which section+symbol of your shared
> lib is hurting you. You're generally going to want this info in order
> to do anything about bad PSS numbers, so I'm not sure raw PSS numbers
> are directly useful.

Basically,
- getting the list of used/unused symbols are great for developers;
- getting the list of applications with their PSS numbers are good for users.

One is for 'analysis' and another is about 'accounting'.

> Is map2 -mm tree only (I didn't get anything on a grep of mainline
> 2.6.22.6)? Sorry, I'm a bit out of touch. If I could drop the kernel
> module from exmap and use an existing interface that would be great.

Yes.
It could be the right time for an early tryout and early feedbacks ;-)

Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
