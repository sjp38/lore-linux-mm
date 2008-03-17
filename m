Subject: Re: [RFC][PATCH] another swap controller for cgroup
In-Reply-To: Your message of "Mon, 17 Mar 2008 17:15:16 +0900"
	<47DE2894.6010306@mxp.nes.nec.co.jp>
References: <47DE2894.6010306@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080317085003.EA4511E7A77@siro.lan>
Date: Mon, 17 Mar 2008 17:50:03 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: nishimura@mxp.nes.nec.co.jp
Cc: minoura@valinux.co.jp, linux-mm@kvack.org, containers@lists.osdl.org, hugh@veritas.com, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

> > - anonymous objects (shmem) are not accounted.
> IMHO, shmem should be accounted.
> I agree it's difficult in your implementation,
> but are you going to support it?

it should be trivial to track how much swap an anonymous object is using.
i'm not sure how it should be associated with cgroups, tho.

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
