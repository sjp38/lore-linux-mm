Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3DF7C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 17:56:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C35025ED6
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 17:56:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="GD12fY/w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C35025ED6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C14F6B000E; Thu, 30 May 2019 13:56:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 14CAC6B026D; Thu, 30 May 2019 13:56:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2EF86B026E; Thu, 30 May 2019 13:56:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9F6B26B000E
	for <linux-mm@kvack.org>; Thu, 30 May 2019 13:56:33 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l3so9696811edl.10
        for <linux-mm@kvack.org>; Thu, 30 May 2019 10:56:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=U+U+DBu1PHMClYLVKuULaBBhuiRxTzOsbylx088oPEM=;
        b=IgFPt9GIfuUXPpYBgPrfb7fFUi6FCMSYgvzgwWN2JO6dBP8r2VjdO3Se2o/SkoBcBq
         8BGEvBCQ2rEyCYojZJOMvEQlQZdrwx7Jf0hC5fMTa2XrUWyQ6ulLzWkqQPfLTrevdOE8
         J9Gmk2G1IL45OUMM5A6UuA9e6Jrp4PLCJ/r0ERyeT5K2FzEiyJ9djY55kR7yhWQtcKE+
         aUrgwHEKVNyFoGCO9euaFGrJJGbuMu+HhFwRbUUCDPa19wmtSQ/zhHyxAqjpr3pL7luj
         DUQ7lgFqPIvrliBOUm1A8JeJc1DdosHuTztB/AjbU7STezE0DH02LrRVipM6QFea6LOp
         3iwQ==
X-Gm-Message-State: APjAAAWylE39cJ4jn9pBIoUCHqxY5ovJe4LDymajwywxOEhNyWD7ybmp
	MsZFb1YIRkKIJK2fEGHOzKzEXxHRG0niLRg6kvDuetUOXHqwRTLArpUJ5/oyzJMP1w7t37jU0ll
	hhws5DIPC5o4hbWHhp37Hr9AuDlw40qM8r9HqpL78FcCZ/cX1PjSP0air/f6D7/FV9A==
X-Received: by 2002:a05:6402:1806:: with SMTP id g6mr3717863edy.30.1559238993243;
        Thu, 30 May 2019 10:56:33 -0700 (PDT)
X-Received: by 2002:a05:6402:1806:: with SMTP id g6mr3717821edy.30.1559238992638;
        Thu, 30 May 2019 10:56:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559238992; cv=none;
        d=google.com; s=arc-20160816;
        b=vzgt6y24TpveYdFBRFq4/GHAPbV6K2qb4OR998W5o38HhnAwMDgX2rOsqKbyrHRtCV
         zyeD46o2JOT9IaxjS6J74mposu9K+tNp57CuXDW88sniIbM/yNbV8W/rVGxn3ac0/OM0
         CgkBhfjVMzG/5NoOJgveDAYbeS06mg0lQT+Icf1Yvwk1YJCEAv549t4cDfy/d0As7Ld7
         i90hUabWfXlvyEzwbVA9ppTcOLZrqJiF1pscxpTLWX+lMrT5VY49rej0asaMqpj7qv6a
         AHzn3nO5Vu+mcrEKUz5SW7j9X/KMlIBfHoNX4UI1rqIDaY1fVTl4TPjzILKz4EgOcMiI
         WruA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=U+U+DBu1PHMClYLVKuULaBBhuiRxTzOsbylx088oPEM=;
        b=fQZ1wlSKFSYzofdHZs3ax17JNLtIAyJLBCMgqUAHrKrht9cpEkK3mWxkkEIWs7V5Uy
         D/j/gGSq+/hO3V70MOS+ssDVWb1yzu0jAPXbsAlDZGcFy5LLBgfBU8DDeFW07/zUyTDG
         5ZYaYP878CaEfqtQOgxdHp4fReKVZDpTFPcdIW8jKtKPivP4zqScxQZYDFUdgtQSFYQ7
         ltihQ3mzOrCAFfL5Y6YPaRqmdeAkQ+D1xE0g3XgSlg4VVlaR4lZrpRHMPDguYvSsb/3n
         eDHoYUlnPJDLwhWgC0y6mwKZaK1DlD3UvJOL+ugKRJ0OFWiDniGH1AKLdnIb3dWVUeP0
         NZCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="GD12fY/w";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y18sor1125851ejm.30.2019.05.30.10.56.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 10:56:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="GD12fY/w";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=U+U+DBu1PHMClYLVKuULaBBhuiRxTzOsbylx088oPEM=;
        b=GD12fY/wh1lP7eqxCKSGFE/8n6zDs6KFH9zv8unLZJQb7BhgoZ/FuQoVPPF2fsQzgg
         CP4pwp8bhVoGUfB+vL51iywyr3kIDSlR8GsTfT9wemkwoZexHA7mhilI3dLovAvK8UlZ
         WmM98gh2EDsHrLbcwkANG7giHH4EZKej0EVgBX6h5mJ7w6r0J6iGdcaGoDw+BEcRtybf
         M6GmqgGBcydEf0hivdeRt3lL9nkWceqr+jmzkKokhk6f2zfqVXSepgJam/5bBWa0FlYT
         rJtpSPZaRnje0lSClB0nZBDffZQG3XQFfZWdQU+gcIX04hnMxHSn4N0EkO8cYuK714PL
         hGjQ==
X-Google-Smtp-Source: APXvYqxEwoaKu7XqFiqqTJmX9C2mj8B1AaOe+c0aGjlSaAlY2tyiFn25bumPeidujxHuV6Nv1l+FdpXKbGDDMgHtxbo=
X-Received: by 2002:a17:906:a354:: with SMTP id bz20mr4942089ejb.209.1559238992200;
 Thu, 30 May 2019 10:56:32 -0700 (PDT)
MIME-Version: 1.0
References: <20190527111152.16324-1-david@redhat.com> <20190527111152.16324-7-david@redhat.com>
In-Reply-To: <20190527111152.16324-7-david@redhat.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 30 May 2019 13:56:21 -0400
Message-ID: <CA+CK2bBF-=+g76A19VfPdSNUJzd-X-P_6vcAiTTrf_JbPvHL+Q@mail.gmail.com>
Subject: Re: [PATCH v3 06/11] mm/memory_hotplug: Allow arch_remove_pages()
 without CONFIG_MEMORY_HOTREMOVE
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, 
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, 
	Wei Yang <richard.weiyang@gmail.com>, Igor Mammedov <imammedo@redhat.com>, 
	Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, 
	Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, 
	Rich Felker <dalias@libc.org>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, 
	Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
	"H. Peter Anvin" <hpa@zytor.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	"Rafael J. Wysocki" <rafael@kernel.org>, Michal Hocko <mhocko@suse.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Oscar Salvador <osalvador@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Alex Deucher <alexander.deucher@amd.com>, "David S. Miller" <davem@davemloft.net>, 
	Mark Brown <broonie@kernel.org>, Chris Wilson <chris@chris-wilson.co.uk>, 
	Christophe Leroy <christophe.leroy@c-s.fr>, Nicholas Piggin <npiggin@gmail.com>, 
	Vasily Gorbik <gor@linux.ibm.com>, Rob Herring <robh@kernel.org>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, "mike.travis@hpe.com" <mike.travis@hpe.com>, 
	Andrew Banman <andrew.banman@hpe.com>, Wei Yang <richardw.yang@linux.intel.com>, 
	Arun KS <arunks@codeaurora.org>, Qian Cai <cai@lca.pw>, Mathieu Malaterre <malat@debian.org>, 
	Baoquan He <bhe@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, 
	Anshuman Khandual <anshuman.khandual@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 7:12 AM David Hildenbrand <david@redhat.com> wrote:
>
> We want to improve error handling while adding memory by allowing
> to use arch_remove_memory() and __remove_pages() even if
> CONFIG_MEMORY_HOTREMOVE is not set to e.g., implement something like:
>
>         arch_add_memory()
>         rc = do_something();
>         if (rc) {
>                 arch_remove_memory();
>         }
>
> We won't get rid of CONFIG_MEMORY_HOTREMOVE for now, as it will require
> quite some dependencies for memory offlining.

I like this simplification, we should really get rid of CONFIG_MEMORY_HOTREMOVE.
Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>

