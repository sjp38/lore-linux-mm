Date: Fri, 16 Jan 2004 15:49:51 +0100
From: Fabian Fenaut <fabian.fenaut@free.fr>
MIME-Version: 1.0
Subject: Re: 2.6.1-mm4
References: <20040115225948.6b994a48.akpm@osdl.org>
In-Reply-To: <20040115225948.6b994a48.akpm@osdl.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Message-Id: <20040116145007Z26548-919+459@kvack.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I got an error compiling -mm4 :

   [...]
   CC [M]  drivers/media/video/ir-kbd-gpio.o
drivers/media/video/ir-kbd-gpio.c:185: unknown field `name' specified in
initializer
drivers/media/video/ir-kbd-gpio.c:185: warning: missing braces around
initializer
drivers/media/video/ir-kbd-gpio.c:185: warning: (near initialization for
`driver.drv')
drivers/media/video/ir-kbd-gpio.c:186: unknown field `drv' specified in
initializer
drivers/media/video/ir-kbd-gpio.c:187: unknown field `drv' specified in
initializer
drivers/media/video/ir-kbd-gpio.c:188: unknown field `gpio_irq'
specified in initializer
drivers/media/video/ir-kbd-gpio.c:188: warning: initialization from
incompatible pointer type
make[4]: *** [drivers/media/video/ir-kbd-gpio.o] Erreur 1
make[3]: *** [drivers/media/video] Erreur 2
make[2]: *** [drivers/media] Erreur 2
make[1]: *** [drivers] Erreur 2
make[1]: Leaving directory `/usr/src/linux-2.6.1'
make: *** [stamp-build] Erreur 2


Complete log : http://fabian.fenaut.free.fr/compile_error
.config : http://fabian.fenaut.free.fr/config-2.6.1-mm4

Any hint ?

Thank you
Fabian


Andrew Morton a ecrit le 16.01.2004 07:59:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.1/2.6.1-mm4/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
