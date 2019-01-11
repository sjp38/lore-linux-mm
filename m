Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A098EC43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 10:08:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37F2C20872
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 10:08:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pKS1rELE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37F2C20872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96CBC8E0002; Fri, 11 Jan 2019 05:08:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 91C198E0001; Fri, 11 Jan 2019 05:08:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8325D8E0002; Fri, 11 Jan 2019 05:08:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5A47C8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 05:08:39 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id s25so12642357ioc.14
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 02:08:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=LUPiDJ7lnfm6wI/6H7WU6hN/VwCa62q6oRlvnlQWtA4=;
        b=BdlMA4VRrePWZOSBX0DOT5PcDCkug5340Ixq0Y///RMYT5cQRftQTANNx7ZrsdjrdC
         KogDES1r1D3qOIK3mP6Y7Q3RYAV64xRM0pfOQtj2d6l6CPfzD5sQ02Ij3z4NOxtgjFWM
         JtHN9taEFZQo30dZOwi6AukmlQMOgriQ2LDaUeX+fta+I9wr2gahcdTbxY2STCK99qRh
         yrnaMOEjsUVZjLRzFQchN8tYB/impw6VIp5hRf2nrVnnpR2cxicnaoaGvRwQFD862V8Q
         36s/m6imZqUnbf/UFGiOiJB3pRa6n6aWAR1dywpiAidowQrgW8/yWL+jDZtKZ2DVo9xC
         DKKg==
X-Gm-Message-State: AJcUukfeMPROfy6QAStIjgR2sRIeD7Y43B+nvxSvpfUfP/3/oZXJgqft
	rxWqYMARg1yiu/o1uGbHTNinZZDX/h8CBcMRZyQ+Ni+4fujPg72kgconXgrmGV9ipWuthKgIEWD
	kmfyOKCy4DCs+XL48bhO3is8pU4Exh95zjk738gF505AP1HKj+tfm12O1XqNh/4xERObEgZ2o6i
	7axeLkXXnwi6aBYzBqMXIXz8tLrdrwdMahvogk4gcTcd+vRbCaodtQ00mFY3FALYHm+/sMf1nCk
	QxNGRMUOAJvMgGaKGuBZVN4v6WedC06CtnMsEgn1cPfjrd+v8NJLTs4wdO1RDWgBgxfvFimIS9i
	l8dgsWnLmJVn/PsMqEYVdmYTqJ4+TFGMaqkx+IMr0fRw8i0h5/ZkKZjZC0qS5wKGNjUzSMs3tsp
	a
X-Received: by 2002:a02:a15e:: with SMTP id m30mr9983761jah.143.1547201319070;
        Fri, 11 Jan 2019 02:08:39 -0800 (PST)
X-Received: by 2002:a02:a15e:: with SMTP id m30mr9983737jah.143.1547201318427;
        Fri, 11 Jan 2019 02:08:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547201318; cv=none;
        d=google.com; s=arc-20160816;
        b=U1ivHZBFGsyzMF5hhSjnjYyvbnFdbvCHuLRijr9zfrSPM8Mf7VQFytzglH50HEgeXs
         X2KASiQccLr2MyrywY+a580ro5/vHH/kYJG23mk20PEvjXxHDTxEg8raIo7AOG2EQA5e
         AfYnUqLfSb+L87gaywAIuRYoWtVAsa5pPzAb+uiJqhZ0woYXgMedBl0/2Y54T0Yd8ggO
         120ngcqE50aesAcg0yBlUZUvIikujYcuM9ysaNZW48q3Uxrf615e9L2bpROzh/BhxD1u
         pO2Ioa53Ol33bNX3Z7ijYua/X7aCNOvkq+nAciJsckDRRHrS22zQWcX8/per0RKpkc0v
         zqzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=LUPiDJ7lnfm6wI/6H7WU6hN/VwCa62q6oRlvnlQWtA4=;
        b=LA2dZ3+L+K3VdvgowtXQuI1h9zLjLwVhWIFRT3aGAdjGsqMY6q5ZQFl4CqQjCR16u2
         qjtV+b2fqH9xrjLCzPRCe9vk+5FWsELnURHsohbuJaRtn2RQzLRHYEY7c6NnqHNDldK1
         0mPhriBUvWh/+9/v3a++ipOiyTc9gcfZTGc4eugxSc2UpgeM9ZuwPzrtiKaUURPMYPzE
         SzMGjRXbMiXPZ+sDWq56OGrBRi038KPqqhjg58Tw+K4bb8JmZ3/tyABU0kmPlyRiwTQx
         bjzpD9wiVpmGf5+UQd44oI8fJi2UJ7o1Jmy4qVX857NyOvCdDvAri36rIY0qZQI9D8Vp
         60+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pKS1rELE;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u16sor32214230ior.37.2019.01.11.02.08.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 02:08:38 -0800 (PST)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pKS1rELE;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=LUPiDJ7lnfm6wI/6H7WU6hN/VwCa62q6oRlvnlQWtA4=;
        b=pKS1rELEFRWnEbgPRB33fqg4Ldf7pDMNfaJWJK6PiMwPiBUhTDbirHslHtkELzOgpS
         rhqnyqt0uCNkHo1dYwmIRvEq1dfumYu3VqyGs7TaQ77sfaeGVzznsCl6oE+ySWZg6uRE
         lcXFSJPjc1PmPi+qTm/TQ2+phaFZnLXZCq5cPS9OTqD6kepoo7AbNDSN0YhDYccacXCL
         +YQgVB2slDxHWxi5EDdKK7gTZ5sgzQiqueEuGmgymvVLDu9LwNuy8Mfh034yTCDlxg4s
         /Qmcza0Q2Gj9nyAvp2u7nK+HgQmHDThCgds5rtWP5f8LceXsWKH55q+a+Is8uQo/d+VY
         8N/Q==
X-Google-Smtp-Source: ALg8bN6WNs9URoD/NSCPCuBXeMSAJYykLzC0vXg1F0Wbe88bwpgBSntGdZZd1qx3KHGpRnmJFPd6BTU9VL+vpU+enrI=
X-Received: by 2002:a6b:3f06:: with SMTP id m6mr8569121ioa.117.1547201318130;
 Fri, 11 Jan 2019 02:08:38 -0800 (PST)
MIME-Version: 1.0
References: <1547183577-20309-1-git-send-email-kernelfans@gmail.com>
 <1547183577-20309-3-git-send-email-kernelfans@gmail.com> <20190111053036.GA13263@localhost.localdomain>
In-Reply-To: <20190111053036.GA13263@localhost.localdomain>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Fri, 11 Jan 2019 18:08:26 +0800
Message-ID:
 <CAFgQCTvWk6t_8fQG3OqNAQDX-23ZaRuCzRyM40-do1rPAhzwhw@mail.gmail.com>
Subject: Re: [PATCHv2 2/7] acpi: change the topo of acpi_table_upgrade()
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
Message-ID: <20190111100826.GueSD3oTkdAmKs_GdF9zx2P8BlNt1iV7oDLqPabI6aU@z>

On Fri, Jan 11, 2019 at 1:31 PM Chao Fan <fanc.fnst@cn.fujitsu.com> wrote:
>
> On Fri, Jan 11, 2019 at 01:12:52PM +0800, Pingfan Liu wrote:
> >The current acpi_table_upgrade() relies on initrd_start, but this var is
> >only valid after relocate_initrd(). There is requirement to extract the
> >acpi info from initrd before memblock-allocator can work(see [2/4]), hence
> >acpi_table_upgrade() need to accept the input param directly.
> >
> >Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> >Acked-by: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> >Cc: Thomas Gleixner <tglx@linutronix.de>
> >Cc: Ingo Molnar <mingo@redhat.com>
> >Cc: Borislav Petkov <bp@alien8.de>
> >Cc: "H. Peter Anvin" <hpa@zytor.com>
> >Cc: Dave Hansen <dave.hansen@linux.intel.com>
> >Cc: Andy Lutomirski <luto@kernel.org>
> >Cc: Peter Zijlstra <peterz@infradead.org>
> >Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> >Cc: Len Brown <lenb@kernel.org>
> >Cc: Yinghai Lu <yinghai@kernel.org>
> >Cc: Tejun Heo <tj@kernel.org>
> >Cc: Chao Fan <fanc.fnst@cn.fujitsu.com>
> >Cc: Baoquan He <bhe@redhat.com>
> >Cc: Juergen Gross <jgross@suse.com>
> >Cc: Andrew Morton <akpm@linux-foundation.org>
> >Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> >Cc: Vlastimil Babka <vbabka@suse.cz>
> >Cc: Michal Hocko <mhocko@suse.com>
> >Cc: x86@kernel.org
> >Cc: linux-acpi@vger.kernel.org
> >Cc: linux-mm@kvack.org
> >---
> > arch/arm64/kernel/setup.c | 2 +-
> > arch/x86/kernel/setup.c   | 2 +-
> > drivers/acpi/tables.c     | 4 +---
> > include/linux/acpi.h      | 4 ++--
> > 4 files changed, 5 insertions(+), 7 deletions(-)
> >
> >diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
> >index f4fc1e0..bc4b47d 100644
> >--- a/arch/arm64/kernel/setup.c
> >+++ b/arch/arm64/kernel/setup.c
> >@@ -315,7 +315,7 @@ void __init setup_arch(char **cmdline_p)
> >       paging_init();
> >       efi_apply_persistent_mem_reservations();
> >
> >-      acpi_table_upgrade();
> >+      acpi_table_upgrade((void *)initrd_start, initrd_end - initrd_start);
> >
> >       /* Parse the ACPI tables for possible boot-time configuration */
> >       acpi_boot_table_init();
> >diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
> >index ac432ae..dc8fc5d 100644
> >--- a/arch/x86/kernel/setup.c
> >+++ b/arch/x86/kernel/setup.c
> >@@ -1172,8 +1172,8 @@ void __init setup_arch(char **cmdline_p)
> >
> >       reserve_initrd();
> >
> >-      acpi_table_upgrade();
> >
> I wonder whether this will cause two blank lines together.
>
Yes, will fix it in next version.

Thanks,
Pingfan
> Thanks,
> Chao Fan
>
> >+      acpi_table_upgrade((void *)initrd_start, initrd_end - initrd_start);
> >       vsmp_init();
> >
> >       io_delay_init();
> >diff --git a/drivers/acpi/tables.c b/drivers/acpi/tables.c
> >index 61203ee..84e0a79 100644
> >--- a/drivers/acpi/tables.c
> >+++ b/drivers/acpi/tables.c
> >@@ -471,10 +471,8 @@ static DECLARE_BITMAP(acpi_initrd_installed, NR_ACPI_INITRD_TABLES);
> >
> > #define MAP_CHUNK_SIZE   (NR_FIX_BTMAPS << PAGE_SHIFT)
> >
> >-void __init acpi_table_upgrade(void)
> >+void __init acpi_table_upgrade(void *data, size_t size)
> > {
> >-      void *data = (void *)initrd_start;
> >-      size_t size = initrd_end - initrd_start;
> >       int sig, no, table_nr = 0, total_offset = 0;
> >       long offset = 0;
> >       struct acpi_table_header *table;
> >diff --git a/include/linux/acpi.h b/include/linux/acpi.h
> >index ed80f14..0b6e0b6 100644
> >--- a/include/linux/acpi.h
> >+++ b/include/linux/acpi.h
> >@@ -1254,9 +1254,9 @@ acpi_graph_get_remote_endpoint(const struct fwnode_handle *fwnode,
> > #endif
> >
> > #ifdef CONFIG_ACPI_TABLE_UPGRADE
> >-void acpi_table_upgrade(void);
> >+void acpi_table_upgrade(void *data, size_t size);
> > #else
> >-static inline void acpi_table_upgrade(void) { }
> >+static inline void acpi_table_upgrade(void *data, size_t size) { }
> > #endif
> >
> > #if defined(CONFIG_ACPI) && defined(CONFIG_ACPI_WATCHDOG)
> >--
> >2.7.4
> >
> >
> >
>
>

