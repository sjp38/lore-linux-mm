Return-Path: <SRS0=xdO8=RV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFB72C10F00
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:53:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 857BF20863
	for <linux-mm@archiver.kernel.org>; Mon, 18 Mar 2019 16:53:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="vhygi2in"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 857BF20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B8F76B0003; Mon, 18 Mar 2019 12:53:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1441C6B0006; Mon, 18 Mar 2019 12:53:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F273E6B0007; Mon, 18 Mar 2019 12:53:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id AA9346B0003
	for <linux-mm@kvack.org>; Mon, 18 Mar 2019 12:53:14 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id j10so19704280pfn.13
        for <linux-mm@kvack.org>; Mon, 18 Mar 2019 09:53:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Vs0GZwImU6CsIFzm114RTXl1boU0bAYEV2fL9XPHMXI=;
        b=hkPY7MLMzyUf97IkrpavpFHUpzpxkS4XVsBT4bO5NowSeM3KokH+LmXJZh1bR0T6gM
         sVNjTnYqHUdTOkzW3QTwNcVf/5Fqd4MUWDl8+46TLJ2usVr3xAhN0BQXrD2EdqGeg3dp
         EhZ5Hrmm2gTWjQe/h2lEzSDlnbvklq0T2jmFMKVMv/aJjogx9NeeSmXTWYHZVzU/4KmB
         kIvJLZP1b1LeySb7SohVeDnr7f2Wt+3igdV5IbtVqHJZ4mM3y0PLk9cM/YXKZQwd0dVi
         rUrCjRppTQcx48ZEuBd05YK2d4QJKl+KiTK3Q90Sa9hhn9JHhA0FggsQPqp0/hJ9w686
         b7cg==
X-Gm-Message-State: APjAAAVhTaJ7j6nHiKIEjCYggMSOzDVMXxyCdfd+PlcBiJeS66hMFtry
	bg69CCO3tuIVY2xs07BbBaEOQTbNThWTd3YiA4OkoVstwiMLQAX2ZGpLthIVEdCpk8z4E0pPWgw
	TqSp/GR05xFdd6SASO8MLIS4qErsg6kTLjRC+zLDqbjnf9NdblKS/1vwB+OLx1LjAgA==
X-Received: by 2002:aa7:8589:: with SMTP id w9mr8374454pfn.97.1552927994240;
        Mon, 18 Mar 2019 09:53:14 -0700 (PDT)
X-Received: by 2002:aa7:8589:: with SMTP id w9mr8374380pfn.97.1552927993081;
        Mon, 18 Mar 2019 09:53:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552927993; cv=none;
        d=google.com; s=arc-20160816;
        b=RFqLtBqNBojl7XqX39NG36wtIgeaf8R9BOePr59D++r+bouTCHlkRPfoL4ZqMmfo4M
         1e40pn7eJsY8jpGzuyP/3CvyVSFhEZggEnqLLdl9Y0qwTZfpJXSfOqz4Ggf9Xqe5W/p2
         UPyYwJUpJ5Ed899EAPBawnPr6kC8FRCMrCSh7ZiMMa/onXuK2XgonIg7BbATyWuzQlF5
         E+9ZNCirL5DD1GsCc6ijp/eTHzOOTpZ3BmGagtIWdgHDrWhyKnvsfNrOxZAiLGclPUGl
         C/J4Vj9M2fXt28AV6y2ZKqSyuZ8z/CTsmoJIH80Tn43QQ+bLZtPppaBhFBrOBEXOK+1O
         /kDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Vs0GZwImU6CsIFzm114RTXl1boU0bAYEV2fL9XPHMXI=;
        b=kAkRHRFwTsSfIxFBYc3C9WdOnfXBJ3y+uHZWB8xO4vE24AucJv2L6tARZ4ZVS3Eh/R
         mynI/30d+tFNDp4c4KQ2GUp1wS5DFec02rN7OVeuOtmF0IznfuopvrojCG4NRqOe9tkh
         oeK1JD75I7gUAxZKU0O7nwAlomgAmUyAUExkQaR3yGGwNExTj8TKtQ4A/R/m1NQE4BbA
         HWx5Fby2f60bVfgmbf7sYZMU6UsyTsx3lVTo5dgEyFWz3N6xylUVuZxNC1XsvSDSEznT
         LGisT0LiJeLXnOfcPgXbh+rBoZDflkbVoquT4v/3KbUUUx4Rc2r/lRiTUy+gOAzM8tU+
         w/nA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vhygi2in;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c1sor156744pgt.58.2019.03.18.09.53.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 18 Mar 2019 09:53:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=vhygi2in;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Vs0GZwImU6CsIFzm114RTXl1boU0bAYEV2fL9XPHMXI=;
        b=vhygi2inIY6QcoMUgdkRT9Nhi0bhC4doWtBXddCRepRu/Td+bIk+Vbe8EZn4ZeJ8jF
         Y2qpNC1dZoVWnQ3xz7Nw7zSQp/FvsAG0Mek+QVyTz7cIULVbIRBatVy3ph8oxnjZDvXj
         WwriDsizH4FtV3nQUnWVGkBnVci2/xZITRCJh69AV7aHHRlRas8vRIgSpMHTyU/NG3la
         0ngh5cQYgDcmAYshLWMtVg5K/robxWQboPv3FXrNJ25FlCTlfdzPmYV5pquOqJbVCfPa
         X34Yrfpq2gV+vNusESF32Kv1JqOd45AEM8y6dtjMDqjgEquUQPk4an4fl0N6gqH80Dro
         o5BA==
X-Google-Smtp-Source: APXvYqxjNgN9sIYOiyZeqjvMuq2HFIgtjxjqmHqTY67i9O6W1n/r6vzQ3VEsl0EX1xI6PaaCdE03fjo9slNsUTi5jUU=
X-Received: by 2002:a63:fd03:: with SMTP id d3mr18189137pgh.359.1552927991651;
 Mon, 18 Mar 2019 09:53:11 -0700 (PDT)
MIME-Version: 1.0
References: <c4d65de9867cb3349af6800242da0de751260c6c.1552679409.git.andreyknvl@google.com>
 <201903170317.IWsOYXBe%lkp@intel.com>
In-Reply-To: <201903170317.IWsOYXBe%lkp@intel.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 18 Mar 2019 17:53:00 +0100
Message-ID: <CAAeHK+wo5pC2W_zRYMYTAXQbh2a_2=ifgJhMDBZ7p1m=chfSbw@mail.gmail.com>
Subject: Re: [PATCH v11 09/14] kernel, arm64: untag user pointers in prctl_set_mm*
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Catalin Marinas <catalin.marinas@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Robin Murphy <robin.murphy@arm.com>, Kees Cook <keescook@chromium.org>, 
	Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	"open list:DOCUMENTATION" <linux-doc@vger.kernel.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, 
	netdev <netdev@vger.kernel.org>, bpf <bpf@vger.kernel.org>, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, 
	Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Mar 16, 2019 at 8:32 PM kbuild test robot <lkp@intel.com> wrote:
>
> Hi Andrey,
>
> Thank you for the patch! Yet something to improve:
>
> [auto build test ERROR on linus/master]
> [also build test ERROR on v5.0 next-20190306]
> [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
>
> url:    https://github.com/0day-ci/linux/commits/Andrey-Konovalov/uaccess-add-untagged_addr-definition-for-other-arches/20190317-015913
> config: x86_64-randconfig-x012-201911 (attached as .config)
> compiler: gcc-7 (Debian 7.3.0-1) 7.3.0
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
>
> All errors (new ones prefixed by >>):
>
>    kernel/sys.c: In function 'prctl_set_mm_map':
> >> kernel/sys.c:1996:11: error: invalid type argument of '->' (have 'struct prctl_mm_map')
>      prctl_map->start_code = untagged_addr(prctl_map.start_code);
>               ^~
>    kernel/sys.c:1997:11: error: invalid type argument of '->' (have 'struct prctl_mm_map')
>      prctl_map->end_code = untagged_addr(prctl_map.end_code);
>               ^~
>    kernel/sys.c:1998:11: error: invalid type argument of '->' (have 'struct prctl_mm_map')
>      prctl_map->start_data = untagged_addr(prctl_map.start_data);
>               ^~
>    kernel/sys.c:1999:11: error: invalid type argument of '->' (have 'struct prctl_mm_map')
>      prctl_map->end_data = untagged_addr(prctl_map.end_data);
>               ^~
>    kernel/sys.c:2000:11: error: invalid type argument of '->' (have 'struct prctl_mm_map')
>      prctl_map->start_brk = untagged_addr(prctl_map.start_brk);
>               ^~
>    kernel/sys.c:2001:11: error: invalid type argument of '->' (have 'struct prctl_mm_map')
>      prctl_map->brk  = untagged_addr(prctl_map.brk);
>               ^~
>    kernel/sys.c:2002:11: error: invalid type argument of '->' (have 'struct prctl_mm_map')
>      prctl_map->start_stack = untagged_addr(prctl_map.start_stack);
>               ^~
>    kernel/sys.c:2003:11: error: invalid type argument of '->' (have 'struct prctl_mm_map')
>      prctl_map->arg_start = untagged_addr(prctl_map.arg_start);
>               ^~
>    kernel/sys.c:2004:11: error: invalid type argument of '->' (have 'struct prctl_mm_map')
>      prctl_map->arg_end = untagged_addr(prctl_map.arg_end);
>               ^~
>    kernel/sys.c:2005:11: error: invalid type argument of '->' (have 'struct prctl_mm_map')
>      prctl_map->env_start = untagged_addr(prctl_map.env_start);
>               ^~
>    kernel/sys.c:2006:11: error: invalid type argument of '->' (have 'struct prctl_mm_map')
>      prctl_map->env_end = untagged_addr(prctl_map.env_end);
>               ^~
>
> vim +1996 kernel/sys.c

Right, I didn't have the related config options enabled when I did the
testing...

>
>   1974
>   1975  #ifdef CONFIG_CHECKPOINT_RESTORE
>   1976  static int prctl_set_mm_map(int opt, const void __user *addr, unsigned long data_size)
>   1977  {
>   1978          struct prctl_mm_map prctl_map = { .exe_fd = (u32)-1, };
>   1979          unsigned long user_auxv[AT_VECTOR_SIZE];
>   1980          struct mm_struct *mm = current->mm;
>   1981          int error;
>   1982
>   1983          BUILD_BUG_ON(sizeof(user_auxv) != sizeof(mm->saved_auxv));
>   1984          BUILD_BUG_ON(sizeof(struct prctl_mm_map) > 256);
>   1985
>   1986          if (opt == PR_SET_MM_MAP_SIZE)
>   1987                  return put_user((unsigned int)sizeof(prctl_map),
>   1988                                  (unsigned int __user *)addr);
>   1989
>   1990          if (data_size != sizeof(prctl_map))
>   1991                  return -EINVAL;
>   1992
>   1993          if (copy_from_user(&prctl_map, addr, sizeof(prctl_map)))
>   1994                  return -EFAULT;
>   1995
> > 1996          prctl_map->start_code   = untagged_addr(prctl_map.start_code);
>   1997          prctl_map->end_code     = untagged_addr(prctl_map.end_code);
>   1998          prctl_map->start_data   = untagged_addr(prctl_map.start_data);
>   1999          prctl_map->end_data     = untagged_addr(prctl_map.end_data);
>   2000          prctl_map->start_brk    = untagged_addr(prctl_map.start_brk);
>   2001          prctl_map->brk          = untagged_addr(prctl_map.brk);
>   2002          prctl_map->start_stack  = untagged_addr(prctl_map.start_stack);
>   2003          prctl_map->arg_start    = untagged_addr(prctl_map.arg_start);
>   2004          prctl_map->arg_end      = untagged_addr(prctl_map.arg_end);
>   2005          prctl_map->env_start    = untagged_addr(prctl_map.env_start);
>   2006          prctl_map->env_end      = untagged_addr(prctl_map.env_end);
>   2007
>   2008          error = validate_prctl_map(&prctl_map);
>   2009          if (error)
>   2010                  return error;
>   2011
>   2012          if (prctl_map.auxv_size) {
>   2013                  memset(user_auxv, 0, sizeof(user_auxv));
>   2014                  if (copy_from_user(user_auxv,
>   2015                                     (const void __user *)prctl_map.auxv,
>   2016                                     prctl_map.auxv_size))
>   2017                          return -EFAULT;
>   2018
>   2019                  /* Last entry must be AT_NULL as specification requires */
>   2020                  user_auxv[AT_VECTOR_SIZE - 2] = AT_NULL;
>   2021                  user_auxv[AT_VECTOR_SIZE - 1] = AT_NULL;
>   2022          }
>   2023
>   2024          if (prctl_map.exe_fd != (u32)-1) {
>   2025                  error = prctl_set_mm_exe_file(mm, prctl_map.exe_fd);
>   2026                  if (error)
>   2027                          return error;
>   2028          }
>   2029
>   2030          /*
>   2031           * arg_lock protects concurent updates but we still need mmap_sem for
>   2032           * read to exclude races with sys_brk.
>   2033           */
>   2034          down_read(&mm->mmap_sem);
>   2035
>   2036          /*
>   2037           * We don't validate if these members are pointing to
>   2038           * real present VMAs because application may have correspond
>   2039           * VMAs already unmapped and kernel uses these members for statistics
>   2040           * output in procfs mostly, except
>   2041           *
>   2042           *  - @start_brk/@brk which are used in do_brk but kernel lookups
>   2043           *    for VMAs when updating these memvers so anything wrong written
>   2044           *    here cause kernel to swear at userspace program but won't lead
>   2045           *    to any problem in kernel itself
>   2046           */
>   2047
>   2048          spin_lock(&mm->arg_lock);
>   2049          mm->start_code  = prctl_map.start_code;
>   2050          mm->end_code    = prctl_map.end_code;
>   2051          mm->start_data  = prctl_map.start_data;
>   2052          mm->end_data    = prctl_map.end_data;
>   2053          mm->start_brk   = prctl_map.start_brk;
>   2054          mm->brk         = prctl_map.brk;
>   2055          mm->start_stack = prctl_map.start_stack;
>   2056          mm->arg_start   = prctl_map.arg_start;
>   2057          mm->arg_end     = prctl_map.arg_end;
>   2058          mm->env_start   = prctl_map.env_start;
>   2059          mm->env_end     = prctl_map.env_end;
>   2060          spin_unlock(&mm->arg_lock);
>   2061
>   2062          /*
>   2063           * Note this update of @saved_auxv is lockless thus
>   2064           * if someone reads this member in procfs while we're
>   2065           * updating -- it may get partly updated results. It's
>   2066           * known and acceptable trade off: we leave it as is to
>   2067           * not introduce additional locks here making the kernel
>   2068           * more complex.
>   2069           */
>   2070          if (prctl_map.auxv_size)
>   2071                  memcpy(mm->saved_auxv, user_auxv, sizeof(user_auxv));
>   2072
>   2073          up_read(&mm->mmap_sem);
>   2074          return 0;
>   2075  }
>   2076  #endif /* CONFIG_CHECKPOINT_RESTORE */
>   2077
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

