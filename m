Date: Sun, 3 Aug 2003 01:48:12 -0400 (EDT)
From: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Subject: Re: 2.6.0-test2-mm3
In-Reply-To: <Pine.LNX.4.53.0308030118580.3473@montezuma.mastecende.com>
Message-ID: <Pine.LNX.4.53.0308030146300.3473@montezuma.mastecende.com>
References: <20030802152202.7d5a6ad1.akpm@osdl.org>
 <Pine.LNX.4.53.0308030106380.3473@montezuma.mastecende.com>
 <20030802222839.1904a247.akpm@osdl.org> <Pine.LNX.4.53.0308030118580.3473@montezuma.mastecende.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 3 Aug 2003, Zwane Mwaikambo wrote:

> > err, that's a bug isn't it?
> 
> I've had a hard time following the saga behind the synaptics code. I know 
> there is some external thing you have to download but never got round to 
> doing it. I'll give that a go now too with CONFIG_MOUSE_PS2_SYNAPTICS. 
> Colour me lazy...

Ok after downloading the XFree86 driver and enabling 
CONFIG_MOUSE_PS2_SYNAPTICS everything is peachy, plus i get to use the 
scroll buttons.

So its confirmed working on my formerly 'broken' setup.

Thanks,
	Zwane

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
