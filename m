Date: Sat, 2 Aug 2003 22:28:39 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.0-test2-mm3
Message-Id: <20030802222839.1904a247.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.53.0308030106380.3473@montezuma.mastecende.com>
References: <20030802152202.7d5a6ad1.akpm@osdl.org>
	<Pine.LNX.4.53.0308030106380.3473@montezuma.mastecende.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zwane Mwaikambo <zwane@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Zwane Mwaikambo <zwane@arm.linux.org.uk> wrote:
>
> On Sat, 2 Aug 2003, Andrew Morton wrote:
> 
> > . I don't think anyone has reported on whether 2.6.0-test2-mm2 fixed any
> >   PS/2 or synaptics problems.  You are all very bad.
> 
> It works now by disabling CONFIG_MOUSE_PS2_SYNAPTICS
> 

err, that's a bug isn't it?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
