From: Martin Diehl <lists@mdiehl.de>
Subject: Re: [2.6.0-test3-mm3] irda compile error
Date: Thu, 21 Aug 2003 21:42:00 +0200 (CEST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0308212120380.3006-100000@notebook.home.mdiehl.de>
References: <3F44A22D.6040005@lanil.mine.nu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
In-Reply-To: <3F44A22D.6040005@lanil.mine.nu>
To: Christian Axelsson <smiler@lanil.mine.nu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On Thu, 21 Aug 2003, Christian Axelsson wrote:

> Got this while doing  make. Config attached.
> Same config compiles fine under mm2
> 
>  CC      drivers/net/irda/vlsi_ir.o
> drivers/net/irda/vlsi_ir.c: In function `vlsi_proc_pdev':
> drivers/net/irda/vlsi_ir.c:167: structure has no member named `name'

Yep, Thanks. I'm aware of the problem which is due to the recent 
device->name removal. In fact a fix for this was already included in the 
latest resent of my big vlsi update patch pending since long.

Anyway, it was pointed out now the patch is too big so I'm currently 
working on splitting it up. Bunch of patches will follow soon :-)

Btw., are you actually using this driver? I'm always looking for testers 
with 2.6 to give better real life coverage...

Martin
