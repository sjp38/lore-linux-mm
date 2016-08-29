Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 63BE683090
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 07:14:34 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id h186so296611587pfg.2
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 04:14:34 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0118.outbound.protection.outlook.com. [104.47.0.118])
        by mx.google.com with ESMTPS id y82si38716119pfd.118.2016.08.29.04.14.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 29 Aug 2016 04:14:33 -0700 (PDT)
Subject: Re: [PATCHv3 3/6] x86/arch_prctl/vdso: add ARCH_MAP_VDSO_*
References: <201608280218.a8uP3eSS%fengguang.wu@intel.com>
From: Dmitry Safonov <dsafonov@virtuozzo.com>
Message-ID: <5375a662-5541-5bde-1d03-e22665183598@virtuozzo.com>
Date: Mon, 29 Aug 2016 14:12:19 +0300
MIME-Version: 1.0
In-Reply-To: <201608280218.a8uP3eSS%fengguang.wu@intel.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, luto@kernel.org, oleg@redhat.com, tglx@linutronix.de, hpa@zytor.com, mingo@redhat.com, linux-mm@kvack.org, x86@kernel.org, gorcunov@openvz.org, xemul@virtuozzo.com

On 08/27/2016 09:09 PM, kbuild test robot wrote:
> Hi Dmitry,
>
> [auto build test ERROR on v4.8-rc3]
> [also build test ERROR on next-20160825]
> [cannot apply to tip/x86/core tip/x86/vdso linux/master]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> [Suggest to use git(>=2.9.0) format-patch --base=<commit> (or --base=auto for convenience) to record what (public, well-known) commit your patch series was built on]
> [Check https://git-scm.com/docs/git-format-patch for more information]
>
> url:    https://github.com/0day-ci/linux/commits/Dmitry-Safonov/x86-32-bit-compatible-C-R-on-x86_64/20160827-011727
> config: x86_64-randconfig-v0-08280034 (attached as .config)
> compiler: gcc-6 (Debian 6.1.1-9) 6.1.1 20160705
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
>
> All errors (new ones prefixed by >>):
>
>    arch/x86/built-in.o: In function `do_arch_prctl':
>>> (.text+0x29865): undefined reference to `vdso_image_32'
>    arch/x86/built-in.o: In function `do_arch_prctl':
>    (.text+0x29877): undefined reference to `vdso_image_32'
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
>

Right, that
+#if defined CONFIG_X86_32 || defined CONFIG_COMPAT
+	case ARCH_MAP_VDSO_32:
+		return prctl_map_vdso(&vdso_image_32, addr);
+#endif

should be:
#if defined CONFIG_X86_32 || defined CONFIG_IA32_EMULATION
// ...

will resend with this fixup.

-- 
              Dmitry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
