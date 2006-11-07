Subject: Re: default base page size on ia64 processor
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <53f38ab60611062345m6cfeda14v4f1f809fe55e95ef@mail.gmail.com>
References: <53f38ab60611062345m6cfeda14v4f1f809fe55e95ef@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 07 Nov 2006 10:46:10 +0100
Message-Id: <1162892771.3138.126.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: adheer chandravanshi <adheerchandravanshi@gmail.com>
Cc: kernelnewbies <kernelnewbies@nl.linux.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2006-11-07 at 13:15 +0530, adheer chandravanshi wrote:
> Hello all,
> 
> I am a linux newbie.
> 
> Can anyone tell me what is the default base page size supported  by
> ia64 processor on Linux?

Hi,

this is a compile time configurable property (kernel compile time), and
can be 4k, 8k, 16k and 64k, whatever you decide on. It's a kernel
configuration option because there is no "one right size" basically...
so you get to pick when you compile your kernel.

Hope this helps,
   Arjan van de Ven



-- 
if you want to mail me at work (you don't), use arjan (at) linux.intel.com
Test the interaction between Linux and your BIOS via http://www.linuxfirmwarekit.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
