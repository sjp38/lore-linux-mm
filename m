Date: Sat, 12 Apr 2003 20:10:11 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.67-mm2
Message-Id: <20030412201011.0d3dfa62.akpm@digeo.com>
In-Reply-To: <200304130303.h3D33kkr031006@sith.maoz.com>
References: <1050198928.597.6.camel@teapot.felipe-alfaro.com>
	<200304130303.h3D33kkr031006@sith.maoz.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeremy Hall <jhall@maoz.com>
Cc: felipe_alfaro@linuxmail.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jeremy Hall <jhall@maoz.com> wrote:
>
> I dunno about that, but mm2 locks in the boot process and doesn't display 
> anything to me through gdb even though it is supposed to.  I have gdb 
> console=gdb but that doesn't make the messages flow.
> 

You want "gdb console=gdb".  It changed.

What CPU type?

Try just 2.5.67 plus 
ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.67/2.5.67-mm2/broken-out/linus.patch

try disabling kgdb in config.

etcetera.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
