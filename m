Message-ID: <41D9ACB4.3080103@sgi.com>
Date: Mon, 03 Jan 2005 14:36:04 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: page migration
References: <41D98556.8050605@sgi.com> <1104776733.25994.11.camel@localhost> <41D99743.5000601@sgi.com> <1104781061.25994.19.camel@localhost> <41D9A7DB.2020306@sgi.com> <20050103201707.GQ29332@holomorphy.com>
In-Reply-To: <20050103201707.GQ29332@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:

> 
> Please don't limit the scope of page migration to that; cross-zone page
> migration is needed to resolve pathologies arising in swapless systems.
> 
> 
> -- wli
>

I'm not proposing to simplify the memory migration code for what I need.
I'm just proposing to build what I need on top of the memory migration
code from the hotplug patch.  Support for cross-zone migration would
still be there, AFAIK.


-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
