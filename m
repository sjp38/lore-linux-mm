From: Fabian Fenaut <fabian.fenaut@free.fr>
Subject: Re: 2.6.1-mm4
Date: Fri, 16 Jan 2004 15:49:51 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <S265351AbUAPOtx/20040116144953Z+7697@vger.kernel.org>
References: <20040115225948.6b994a48.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
In-Reply-To: <20040115225948.6b994a48.akpm@osdl.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Hi,

I got an error compiling -mm4 :

   [...]
   CC [M]  drivers/media/video/ir-kbd-gpio.o
drivers/media/video/ir-kbd-gpio.c:185: unknown field `name' specified i=
n
initializer
drivers/media/video/ir-kbd-gpio.c:185: warning: missing braces around
initializer
drivers/media/video/ir-kbd-gpio.c:185: warning: (near initialization fo=
r
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
=2Econfig : http://fabian.fenaut.free.fr/config-2.6.1-mm4

Any hint ?

Thank you
=46abian


Andrew Morton a =E9crit le 16.01.2004 07:59:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.1/2=
=2E6.1-mm4/
