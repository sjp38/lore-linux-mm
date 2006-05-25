From: Matt Taggart <taggart@debian.org>
Subject: Re: dropping CONFIG_IA32_SUPPORT from ia64 
In-reply-to: <200605241438.34303.bjorn.helgaas@hp.com> 
References: <B8E391BBE9FE384DAA4C5C003888BE6F0693FC5B@scsmsx401.amr.corp.intel.com> <200605241438.34303.bjorn.helgaas@hp.com>
Date: Wed, 24 May 2006 19:32:44 -0600
Message-Id: <20060525013244.C2F5937F81@carmen.fc.hp.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-ia64@vger.kernel.org, linux-mm@kvack.org, debian-ia64@lists.debian.org
List-ID: <linux-mm.kvack.org>

Bjorn Helgaas writes...

> If we remove CONFIG_IA32_SUPPORT, every ia64 box will require
> the Intel emulator (or QEMU or some other ill-defined solution)
> in order to run ia32 code, even though every processor in the
> field today supports ia32 in hardware.
> 
> It doesn't feel right to me to remove functionality from machines
> in the field and offer only a proprietary alternative.

Debian is looking at implementing "multiarch", a way to have libraries
for multiple binary targets install in the same system root.

  http://wiki.debian.org/multiarch

After amd64 systems, ia64 can benefit the most from multiarch. It would
be a shame to see this not happen.

I also agree with Bjorn that the propriatary tool shouldn't be the only
way. To the Intel people on the lists that work on this, what is Intel's
position on open sourcing this technology?

Thanks,

-- 
Matt Taggart
taggart@debian.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
