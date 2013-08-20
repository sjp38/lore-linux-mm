Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id B94FB6B0034
	for <linux-mm@kvack.org>; Tue, 20 Aug 2013 10:48:20 -0400 (EDT)
Message-ID: <521381A9.4020501@intel.com>
Date: Tue, 20 Aug 2013 07:48:09 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [BUG REPORT]kernel panic with kmemcheck config
References: <5212D7F2.3020308@huawei.com>
In-Reply-To: <5212D7F2.3020308@huawei.com>
Content-Type: text/plain; charset=gb18030
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Libin <huawei.libin@huawei.com>
Cc: Vegard Nossum <vegardno@ifi.uio.no>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Li Zefan <lizefan@huawei.com>, guohanjun@huawei.com, zhangdianfang@huawei.com

On 08/19/2013 07:44 PM, Libin wrote:
> When kmemcheck kernel support configuredGBP!we encountered random kernel panic
> (sometimes can be booted) during system boot process in our environment. I
> have tested the mainline kernel version from v3.0 to v3.11-rc6, they also
> have this problem. And the memory limit within 4G also tested.

Could you provide a more complete oops?  Doing it properly usually
requires either a remote console of some kind (netconsole, serial, usb
debug, etc...).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
