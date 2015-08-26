Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f43.google.com (mail-la0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 907176B0253
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 09:15:09 -0400 (EDT)
Received: by labia3 with SMTP id ia3so54512870lab.3
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 06:15:08 -0700 (PDT)
Received: from plane.gmane.org (plane.gmane.org. [80.91.229.3])
        by mx.google.com with ESMTPS id bh10si18746629lbc.100.2015.08.26.06.15.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 26 Aug 2015 06:15:07 -0700 (PDT)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1ZUaXg-0003ca-8M
	for linux-mm@kvack.org; Wed, 26 Aug 2015 15:15:05 +0200
Received: from 175.159.81.221 ([175.159.81.221])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 15:15:04 +0200
Received: from ameliafu1990 by 175.159.81.221 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 15:15:04 +0200
From: ameliafu1990 <ameliafu1990@gmail.com>
Subject: Questions about PASR patch
Date: Wed, 26 Aug 2015 13:06:37 +0000 (UTC)
Message-ID: <loom.20150826T150345-632@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Recently I've been reading the PASR patch, and I am really interested in 
that. Cause I am a total freshman to linux kernel, there are a few 
questions about the framework. I would very appreciate it if anyone 
could take a look at them and give me some suggestions.

Now I am trying to put several memory banks into no_refresh state on a 
real device, Nexus 9. Nexus 9 is based on Nvidia Tegra K1, with LPDDR3 
as the RAM. Its kernel version is tegra-flounder-3.10. From this kernel 
version, tegra 12 seems to support PASR. But tegra K1(tegra 132) does 
not have a supporting function like that.

static void tegra12_pasr_apply_mask(u16 *mem_reg, void *cookie)
{
	u32 val = 0;
	int device = (int)cookie;

	val = TEGRA_EMC_MODE_REG_17 | *mem_reg;
	val |= device << TEGRA_EMC_MRW_DEV_SHIFT;

	emc_writel(val, EMC_MRW);

	pr_debug("%s: cookie = %d mem_reg = 0x%04x val = 0x%08x\n", 
__func__,
			(int)cookie, *mem_reg, val);
}

1. Does tegra 12 really supports PASR?
2. Why doesn't tegra 132 have a PASR driver? Is it because of some 
hardware differences? Is it possible if I rewrite a similar driver on 
tegra 132, just like tegra 12?

Thanks very much!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
