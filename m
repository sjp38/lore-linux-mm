Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id EB4A96B0032
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 15:44:34 -0500 (EST)
Received: by pdbfl12 with SMTP id fl12so15633617pdb.4
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 12:44:34 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id gi5si2568165pbc.115.2015.02.26.12.44.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Feb 2015 12:44:34 -0800 (PST)
Date: Thu, 26 Feb 2015 12:44:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 7/197] ak8975.c:undefined reference to
 `i2c_smbus_write_byte_data'
Message-Id: <20150226124432.2220a6bfd14cc9ce154f8a62@linux-foundation.org>
In-Reply-To: <201502261516.PXhQgKP2%fengguang.wu@intel.com>
References: <201502261516.PXhQgKP2%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, kbuild-all@01.org, Johannes Weiner <hannes@cmpxchg.org>, Linux Memory Management List <linux-mm@kvack.org>

On Thu, 26 Feb 2015 15:36:18 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> It's probably a bug fix that unveils the link errors.
> 
> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   87bf5bee8749a1d3c82d12a55a1e33f6a22da8ed
> commit: 7d789876f1a932dfa1a70ae8eeba270aa34358ad [7/197] rtc: ds1685: fix ds1685_rtc_alarm_irq_enable build error
> config: i386-randconfig-nexr0-0226 (attached as .config)
> reproduce:
>   git checkout 7d789876f1a932dfa1a70ae8eeba270aa34358ad
>   # save the attached .config to linux build tree
>   make ARCH=i386 
> 
> All error/warnings:
> 
>    drivers/built-in.o: In function `ak8975_set_mode':
> >> ak8975.c:(.text+0x16c108): undefined reference to `i2c_smbus_write_byte_data'
>    drivers/built-in.o: In function `ak8975_probe':
> >> ak8975.c:(.text+0x16c29b): undefined reference to `i2c_smbus_read_i2c_block_data'
> >> ak8975.c:(.text+0x16c348): undefined reference to `i2c_smbus_read_i2c_block_data'
>    drivers/built-in.o: In function `ak8975_read_raw':
> >> ak8975.c:(.text+0x16c66b): undefined reference to `i2c_smbus_read_byte_data'
> >> ak8975.c:(.text+0x16c6a2): undefined reference to `i2c_smbus_read_byte_data'
> >> ak8975.c:(.text+0x16c6c6): undefined reference to `i2c_smbus_read_byte_data'
> >> ak8975.c:(.text+0x16c751): undefined reference to `i2c_smbus_read_word_data'
>    drivers/built-in.o: In function `ak8975_driver_init':
> >> ak8975.c:(.init.text+0x10e35): undefined reference to `i2c_register_driver'
>    drivers/built-in.o: In function `ak8975_driver_exit':
> >> ak8975.c:(.exit.text+0x1841): undefined reference to `i2c_del_driver'

Yes, something seems to have gone spectacularly wrong here.  "rtc:
ds1685: fix ds1685_rtc_alarm_irq_enable build error" has nothing to do
with i2c or with drivers/iio/magnetometer/ak8975.c.

And CONFIG_AK8975 depends on CONFIG_I2C.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
