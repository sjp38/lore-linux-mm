Date: Fri, 23 Jan 2004 10:46:53 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: keyboard and USB problems (Re: 2.6.2-rc1-mm2)
Message-Id: <20040123104653.53fe7667.akpm@osdl.org>
In-Reply-To: <20040123161946.GA6934@ucw.cz>
References: <20040123013740.58a6c1f9.akpm@osdl.org>
	<20040123160152.GA18073@ss1000.ms.mff.cuni.cz>
	<20040123161946.GA6934@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vojtech Pavlik <vojtech@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, john stultz <johnstul@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Vojtech Pavlik <vojtech@suse.cz> wrote:
>
> On Fri, Jan 23, 2004 at 05:01:52PM +0100, Rudo Thomas wrote:
>  > Hi.
>  > 
>  > I don't seem to be able to type anything on the keyboard in 2.6.2-rc1-mm2. It
>  > works fine in -rc1-mm1. There are a few differences in dmesg output of mm2
>  > compared to mm1.
>  > 
>  > BogoMIPS is figured out to be 8.19 (this was already reported by another user),
> 
>  ... this the root cause of the following problems.
> 
>  > and i8042.c complaints with this:
>  > i8042.c: Can't write CTR while closing AUX.
> 
>  ... bogomips is used in udelay() and that's used for waiting. If
>  bogomips is measured lower than real, the wait takes shorter and the
>  hardware doesn't do what it should in that short time.
> 
>  Try disabling ACPI for a start ...

Disabling CONFIG_X86_PM_TIMER should fix it up too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
