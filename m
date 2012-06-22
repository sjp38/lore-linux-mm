Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id D49F76B0153
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 04:14:34 -0400 (EDT)
Message-ID: <4FE42964.8050404@arm.com>
Date: Fri, 22 Jun 2012 09:14:28 +0100
From: viresh kumar <viresh.kumar2@arm.com>
MIME-Version: 1.0
Subject: Re: mmotm 2012-06-21-16-20 uploaded
References: <20120621232149.F0286A026A@akpm.mtv.corp.google.com>
In-Reply-To: <20120621232149.F0286A026A@akpm.mtv.corp.google.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>

On 22/06/12 00:21, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2012-06-21-16-20 has been uploaded to
>
>    http://www.ozlabs.org/~akpm/mmotm/
>
> It contains the following patches against 3.5-rc3:
> (patches marked "*" will be included in linux-next)
>
> * clk-add-non-config_have_clk-routines.patch
> * clk-remove-redundant-depends-on-from-drivers-kconfig.patch
> * i2c-i2c-pxa-remove-conditional-compilation-of-clk-code.patch
> * usb-marvell-remove-conditional-compilation-of-clk-code.patch
> * usb-musb-remove-conditional-compilation-of-clk-code.patch
> * ata-pata_arasan-remove-conditional-compilation-of-clk-code.patch
> * net-c_can-remove-conditional-compilation-of-clk-code.patch
> * net-stmmac-remove-conditional-compilation-of-clk-code.patch
> * gadget-m66592-remove-conditional-compilation-of-clk-code.patch
> * gadget-r8a66597-remove-conditional-compilation-of-clk-code.patch
> * usb-host-r8a66597-remove-conditional-compilation-of-clk-code.patch

Hi Andrew,

You need

http://permalink.gmane.org/gmane.linux.ports.arm.kernel/172024

to make above patchset complete.

--
Viresh

-- IMPORTANT NOTICE: The contents of this email and any attachments are con=
fidential and may also be privileged. If you are not the intended recipient=
, please notify the sender immediately and do not disclose the contents to =
any other person, use it for any purpose, or store or copy the information =
in any medium.  Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
