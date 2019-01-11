Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7EEA8C43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 10:07:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C54B20872
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 10:07:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cNX4uAlE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C54B20872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC77F8E0002; Fri, 11 Jan 2019 05:07:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C77918E0001; Fri, 11 Jan 2019 05:07:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B40AD8E0002; Fri, 11 Jan 2019 05:07:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 88FF48E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 05:07:07 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id i12so994018ita.3
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 02:07:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=0tV770gtlc+wsy+UJoYxGMN9qBxuKgWLEh7SlyYwABc=;
        b=ATogtG4lxx/oVnGoFsNZhFdX4KX2qycaFItp//yBxoSipcyK2m7B7NY50W8K0JpVdE
         V5C0xhjTSTCpGMhSZGA+tgv/YmD0xYMH71EJjbF7eHRKAx1yj4eiqbNvGMR/zHOpAtQb
         u7WwJ7GyBp93rHunTVdw2xbKmYN6w7x2Q1tTPN6884sTbyBXapNaZgcJQU3OFYy5SPAe
         LLBiNjxP+B6elOlXWJ6l4ASxg31jOVQ/qPsRFGZ9eg0qsqSHF7dEIFCo7NUrMuRF2DbW
         jvpxLuBCCDHJRLsnhN5awA1xAA7xxQ+kGUaBEGBfXxWdL2P2+ssQdo6H4zSBQ3Qn9adb
         vO2g==
X-Gm-Message-State: AJcUukfJZLsOa7Mc5+DkMyKRU+DVQogivq4zYY/NqqlYdDmHoNjdzR+Z
	LYPon6tEQjNGfx7Y9snkHozF4cjvfqwquqZKesTgEfgnz7MzC8SwOHTO/8FGMyufexau8q/428t
	xzAsFQzmN5vEhTGCjzujG74YMHksl0k5hI8rr5tcpv3F1Vhf98SyJJZlNhNgjmfRAuJ2M700pTT
	V9JV2euXL+nt4vM0wg/7dOWGfre4H3k+0XeiK8WUxpkWznilZqkzWGI3EdAd33lls+0oAaCvfbR
	YDJwyLzTBpdQ0YMACrG3HXdOL3ZOCZxC3NHaAiewkNURUG35CGjEl2gqdXTLqtHFzX1OXM0XeSB
	kC57c0mlYHd/o5Djaw8RLpZwlXsgfy96OsflnQE/bhYT74Cb9Nl+1DZp5KWEuH9j0XddpfZP7jX
	N
X-Received: by 2002:a02:c891:: with SMTP id m17mr4406582jao.45.1547201227320;
        Fri, 11 Jan 2019 02:07:07 -0800 (PST)
X-Received: by 2002:a02:c891:: with SMTP id m17mr4406567jao.45.1547201226675;
        Fri, 11 Jan 2019 02:07:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547201226; cv=none;
        d=google.com; s=arc-20160816;
        b=XeTwZnKCwIEQXNY/1RdQ6lPKq0GDTrt7KTqAtVSyzMAzKKXWDOEqKagmrtRGKCoA9L
         IaOcaoi5zWUIC5+cS0o5G8ctbm3e5EsjiBqoM4LeL1jYNMl5kWnk5axsbTypASgxb5UR
         tMB784c1l0R0LzWVYqHb8GFh8EcIPKNaEqnFxhXQrFCKHOzqxUY+q6/xLxtPE59gpkHU
         imCBQ25zMFChu4LovA8FiAlFCaBj8yGOKIP6n07G4nJn+Cbpiy94apcA+C/Oh++8LLv5
         59yigwJ129//ZLfWozGeqEJlPDM0LP8HQme+9GQ9Ow+CaU/ip1SZqaFsSUgNq44A0lW9
         8E5w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=0tV770gtlc+wsy+UJoYxGMN9qBxuKgWLEh7SlyYwABc=;
        b=Hs1o+x7X3H32IrL1MgFx4xpMdWViKeYSFvgDQQ5w4g0GenhI9zDnVOazmjTHfef3Rk
         UcB+cdc4cT3C27HsCj/2LKLw5n/glVc+LADNP9fxe6t6hMCMKCJtbItTux46Yq2KYci9
         Pp1l4DncQQ7eSIojSetSGhmI96uRv37xFzI94B4f9pVJ9jCPscbZRi9F/uz9FaTN5w8Z
         C64zGcevI1xEawIkmqsoR/onc5M4FLT94wCPt6mz5yH7nEcKFhcxyr02DEOFne+EMo5/
         A5hPFcRzsVffIjVEsu0U5HCNlNuMVwSlw1feBT+fPj2d1QtXES1ufGihbCFAKtRfS1V7
         Lmfw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cNX4uAlE;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m22sor28684487ioj.130.2019.01.11.02.07.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 02:07:06 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cNX4uAlE;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=0tV770gtlc+wsy+UJoYxGMN9qBxuKgWLEh7SlyYwABc=;
        b=cNX4uAlETZADN8aGRufMP3D/4vQLNg3X69OiSMjhjWYl7auJI9j39DuE573wzYBGPB
         Z54d5fPFgjAi6qVJ+oWkKC2s4Q8LQXwrsMqf/Xqe5JAX+Ih3hgn/w1hVd1LMrQ2RwSxm
         DLjcGH7rmc6U9CbplCjwBYbbNR1zJ3hBsKXnndGo291m4QEMvTkV2e+IiaOyqrAvm3l8
         sop06tgie9xWkc+XMY4MO8IzM3AiwyEGYDE02eCIDXqlt467X05ipHMqhcdd+jbMOH08
         +xEvlP6cymto4k/R9yxie0s814znsJDeXyjjXz5Zr4zPOaoYl0WaPUQVEZR3pA6WlABt
         4tfg==
X-Google-Smtp-Source: ALg8bN5Xzg+bZMposKlY51+EUlou7mGmeHx/TDH2StE42hULTAMczRfTbyGp2nwSeReF6n6voVc0KWtaO+hN0ViqkcQ=
X-Received: by 2002:a5e:de01:: with SMTP id e1mr9201968iok.137.1547201226390;
 Fri, 11 Jan 2019 02:07:06 -0800 (PST)
MIME-Version: 1.0
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
 <1547183577-20309-2-git-send-email-kernelfans@gmail.com> <20190111061221.GB13263@localhost.localdomain>
In-Reply-To: <20190111061221.GB13263@localhost.localdomain>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Fri, 11 Jan 2019 18:06:55 +0800
Message-ID:
 <CAFgQCTvhcNK_-b-eVFZY8Ua2C+GbOVM+h4kB1us2vNvvyNPCYg@mail.gmail.com>
Subject: Re: [PATCHv2 1/7] x86/mm: concentrate the code to memblock allocator enabled
To: Chao Fan <fanc.fnst@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, 
	Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, 
	Peter Zijlstra <peterz@infradead.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, 
	Yinghai Lu <yinghai@kernel.org>, Tejun Heo <tj@kernel.org>, Baoquan He <bhe@redhat.com>, 
	Juergen Gross <jgross@suse.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, 
	x86@kernel.org, linux-acpi@vger.kernel.org, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190111100655.sPqSyu8uniecXMrw7cjZ1Ntp6EJr_SirRdhLR9O3DdQ@z>

On Fri, Jan 11, 2019 at 2:13 PM Chao Fan <fanc.fnst@cn.fujitsu.com> wrote:
>
> On Fri, Jan 11, 2019 at 01:12:51PM +0800, Pingfan Liu wrote:
> >This patch identifies the point where memblock alloc start. It has no
> >functional.
> [...]
> >+#ifdef CONFIG_MEMORY_HOTPLUG
> >+      /*
> >+       * Memory used by the kernel cannot be hot-removed because Linux
> >+       * cannot migrate the kernel pages. When memory hotplug is
> >+       * enabled, we should prevent memblock from allocating memory
> >+       * for the kernel.
> >+       *
> >+       * ACPI SRAT records all hotpluggable memory ranges. But before
> >+       * SRAT is parsed, we don't know about it.
> >+       *
> >+       * The kernel image is loaded into memory at very early time. We
> >+       * cannot prevent this anyway. So on NUMA system, we set any
> >+       * node the kernel resides in as un-hotpluggable.
> >+       *
> >+       * Since on modern servers, one node could have double-digit
> >+       * gigabytes memory, we can assume the memory around the kernel
> >+       * image is also un-hotpluggable. So before SRAT is parsed, just
> >+       * allocate memory near the kernel image to try the best to keep
> >+       * the kernel away from hotpluggable memory.
> >+       */
> >+      if (movable_node_is_enabled())
> >+              memblock_set_bottom_up(true);
>
> Hi Pingfan,
>
> In my understanding, 'movable_node' is based on the that memory near
> kernel is considered as in the same node as kernel in high possibility.
>
> If SRAT has been parsed early, do we still need the kernel parameter
> 'movable_node'? Since you have got the memory information about hot-remove,
> so I wonder if it's OK to drop 'movable_node', and if memory-hotremove is
> enabled, change memblock allocation according to SRAT.
>
x86_32 still need this logic. Maybe it can be doable later.

Thanks,
Pingfan
> If there is something wrong in my understanding, please let me know.
>
> Thanks,
> Chao Fan
>
> >+#endif
> >       init_mem_mapping();
> >+      memblock_set_current_limit(get_max_mapped());
> >
> >       idt_setup_early_pf();
> >
> >@@ -1145,8 +1145,6 @@ void __init setup_arch(char **cmdline_p)
> >        */
> >       mmu_cr4_features = __read_cr4() & ~X86_CR4_PCIDE;
> >
> >-      memblock_set_current_limit(get_max_mapped());
> >-
> >       /*
> >        * NOTE: On x86-32, only from this point on, fixmaps are ready for use.
> >        */
> >--
> >2.7.4
> >
> >
> >
>
>

